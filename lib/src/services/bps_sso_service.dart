import 'dart:async';

import 'package:bps_sso_sdk/src/config/config.dart';
import 'package:bps_sso_sdk/src/core/token_cache.dart';
import 'package:bps_sso_sdk/src/exceptions/exceptions.dart';
import 'package:bps_sso_sdk/src/models/models.dart';
import 'package:bps_sso_sdk/src/security/security.dart';
import 'package:bps_sso_sdk/src/services/mixins/custom_tabs_mixin.dart';
import 'package:bps_sso_sdk/src/services/mixins/token_operations_mixin.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Internal SSO authentication service
class BPSSsoService with TokenOperationsMixin, CustomTabsMixin {
  BPSSsoService({
    required this.config,
    this.linkStream,
    Dio? dio,
  }) : _dio = dio ?? Dio(),
       _securityManager = BPSSsoSecurityManager() {
    _dio.options.connectTimeout = config.securityConfig.tokenTimeoutDuration;
    _dio.options.receiveTimeout = config.securityConfig.tokenTimeoutDuration;

    // Add custom interceptors from configuration
    config.interceptors.forEach(_dio.interceptors.add);

    // Initialize security manager with configuration
    _securityManager.initialize(config.securityConfig);
  }

  @override
  final BPSSsoConfig config;

  @override
  final Stream<String>? linkStream;

  final Dio _dio;
  final BPSSsoSecurityManager _securityManager;

  @override
  Dio get dio => _dio;

  @override
  BPSSsoSecurityManager get securityManager => _securityManager;

  /// Authenticate user using webview OAuth2 flow
  ///
  /// Opens Custom Tabs (Android) or SFSafariViewController (iOS) for
  /// authentication. The browser will automatically close after successful
  /// authentication or on error.
  Future<BPSUser> loginWithWebview({
    required BuildContext context,
    required BPSRealmType realmType,
  }) async {
    try {
      final realmConfig = config.getConfig(realmType);

      // Generate PKCE parameters for security using secure manager
      final codeVerifier = securityManager.generateSecureCodeVerifier();
      final codeChallenge = securityManager.generateCodeChallenge(codeVerifier);
      final state = securityManager.generateSecureState();

      // Build authorization URL
      final authUrl = realmConfig.buildAuthUrl(
        codeChallenge: codeChallenge,
        state: state,
      );

      // Show Custom Tabs for authentication
      final authCode = await showCustomTabsAuth(
        context,
        authUrl,
        state,
        realmConfig,
      );

      if (authCode == null) {
        throw const AuthenticationCancelledException();
      }

      // Exchange authorization code for tokens
      final tokenData = await exchangeCodeForTokens(
        realmConfig: realmConfig,
        authCode: authCode,
        codeVerifier: codeVerifier,
      );

      // Get user info from access token
      final userInfo = await getUserInfo(
        accessToken: tokenData['access_token'] as String,
        config: realmConfig,
      );

      // Combine token and user data
      final userData = {
        ...userInfo,
        ...tokenData,
      };

      final user = BPSUser.fromJson(userData, realmType);

      // Call success callback
      config.authCallbacks.onLoginSuccess?.call(user, realmType);

      return user;
    } on Exception catch (e) {
      _handleLoginError(e, realmType);
      rethrow;
    }
  }

  void _handleLoginError(Exception e, BPSRealmType realmType) {
    final errorConfig = config.errorConfig;
    errorConfig.onError?.call(e, StackTrace.current);

    Exception sanitized;
    if (e is BPSSsoException) {
      sanitized = securityManager.sanitizeError(
        e,
        isProduction: !errorConfig.enableDetailedErrorMessages,
      );
    } else {
      sanitized = securityManager.sanitizeError(
        NetworkException('Authentication failed: $e'),
        isProduction: !errorConfig.enableDetailedErrorMessages,
      );
    }

    if (e is AuthenticationCancelledException) {
      config.authCallbacks.onLoginCancelled?.call(realmType);
    } else {
      config.authCallbacks.onLoginFailed?.call(sanitized, realmType);
    }
  }

  /// Logout user by revoking tokens
  Future<void> logout(BPSUser user) async {
    try {
      final realmConfig = config.getConfig(user.realm);

      await dio.post<dynamic>(
        realmConfig.logoutUrl,
        data: {
          'client_id': realmConfig.clientId,
          'refresh_token': user.refreshToken,
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      // Secure memory cleanup after successful logout
      _clearUserTokens(user);

      // Call success callback
      config.authCallbacks.onLogoutSuccess?.call(user);
    } on Exception catch (e) {
      // Always clean up sensitive data even if logout fails
      _clearUserTokens(user);

      // Handle error with security manager
      final errorConfig = config.errorConfig;
      final logoutError = LogoutException('Logout failed: $e');

      errorConfig.onError?.call(logoutError, StackTrace.current);

      // Call failure callback
      config.authCallbacks.onLogoutFailed?.call(logoutError, user);

      // Don't throw on logout failure in production
      if (errorConfig.enableDetailedErrorMessages) {
        debugPrint('Logout request failed: $e');
      }
    }
  }

  void _clearUserTokens(BPSUser user) {
    securityManager
      ..secureClearSensitiveData(user.accessToken)
      ..secureClearSensitiveData(user.refreshToken);

    // Clear token validation cache for this user
    TokenValidationCache.instance.clearUserCache(user.id);
  }
}
