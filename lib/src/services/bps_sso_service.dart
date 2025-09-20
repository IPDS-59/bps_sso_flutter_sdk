// need to add that async
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:bps_sso_sdk/src/config/config.dart';
import 'package:bps_sso_sdk/src/exceptions/exceptions.dart';
import 'package:bps_sso_sdk/src/models/models.dart';
import 'package:bps_sso_sdk/src/security/security.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

/// Internal SSO authentication service
class BPSSsoService {
  BPSSsoService({
    required this.config,
    this.linkStream,
    Dio? dio,
  }) : _dio = dio ?? Dio(),
       _securityManager = BPSSsoSecurityManager() {
    _dio.options.connectTimeout = config.securityConfig.tokenTimeoutDuration;
    _dio.options.receiveTimeout = config.securityConfig.tokenTimeoutDuration;

    // Initialize security manager with configuration
    _securityManager.initialize(config.securityConfig);
  }

  final BPSSsoConfig config;
  final Stream<String>? linkStream;
  final Dio _dio;
  final BPSSsoSecurityManager _securityManager;

  /// Authenticate user using webview OAuth2 flow
  Future<BPSUser> loginWithWebview({
    required BuildContext context,
    required BPSRealmType realmType,
  }) async {
    try {
      final realmConfig = config.getConfig(realmType);

      // Generate PKCE parameters for security using secure manager
      final codeVerifier = _securityManager.generateSecureCodeVerifier();
      final codeChallenge = _securityManager.generateCodeChallenge(
        codeVerifier,
      );
      final state = _securityManager.generateSecureState();

      // Build authorization URL
      final authUrl = realmConfig.buildAuthUrl(
        codeChallenge: codeChallenge,
        state: state,
      );

      // Show Custom Tabs for authentication
      final authCode = await _showCustomTabsAuth(
        context,
        authUrl,
        state,
        realmConfig,
      );

      if (authCode == null) {
        throw const AuthenticationCancelledException();
      }

      // Exchange authorization code for tokens
      final tokenData = await _exchangeCodeForTokens(
        config: realmConfig,
        authCode: authCode,
        codeVerifier: codeVerifier,
      );

      // Get user info from access token
      final userInfo = await _getUserInfo(
        accessToken: tokenData['access_token'] as String,
        config: realmConfig,
      );

      // Combine token and user data
      final userData = {
        ...userInfo,
        ...tokenData,
      };

      return BPSUser.fromJson(userData, realmType);
    } catch (e) {
      // Handle errors with security manager
      final errorConfig = config.errorConfig;
      if (errorConfig.onError != null && e is Exception) {
        errorConfig.onError!(e, StackTrace.current);
      }

      if (e is BPSSsoException) {
        // Re-throw SDK exceptions, but sanitize them
        final sanitized = _securityManager.sanitizeError(
          e,
          isProduction: !errorConfig.enableDetailedErrorMessages,
        );
        throw sanitized;
      }

      // Sanitize unknown errors
      final sanitized = _securityManager.sanitizeError(
        NetworkException('Authentication failed: $e'),
        isProduction: !errorConfig.enableDetailedErrorMessages,
      );
      throw sanitized;
    }
  }

  /// Refresh access token using refresh token
  Future<BPSUser> refreshToken(BPSUser user) async {
    try {
      final realmConfig = config.getConfig(user.realm);

      final response = await _dio.post<dynamic>(
        realmConfig.tokenUrl,
        data: {
          'grant_type': 'refresh_token',
          'client_id': realmConfig.clientId,
          'refresh_token': user.refreshToken,
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      if (response.statusCode == 200) {
        final tokenData = response.data as Map<String, dynamic>;

        final newAccessToken = tokenData['access_token'] as String?;
        final newRefreshToken = tokenData['refresh_token'] as String?;

        if (newAccessToken == null) {
          throw const TokenExchangeException(
            'Access token is null in refresh response',
          );
        }

        // Get updated user info
        final userInfo = await _getUserInfo(
          accessToken: newAccessToken,
          config: realmConfig,
        );

        final userData = {
          ...userInfo,
          'access_token': newAccessToken,
          'refresh_token': newRefreshToken ?? user.refreshToken,
          'expires_in': tokenData['expires_in'],
        };

        // Clean up old tokens before returning new ones
        _securityManager.secureClearSensitiveData(user.accessToken);
        if (newRefreshToken != null) {
          _securityManager.secureClearSensitiveData(user.refreshToken);
        }

        return BPSUser.fromJson(userData, user.realm);
      } else {
        throw TokenExchangeException.fromStatusCode(response.statusCode!);
      }
    } catch (e) {
      if (e is BPSSsoException) rethrow;
      throw NetworkException('Token refresh failed: $e');
    }
  }

  /// Logout user by revoking tokens
  Future<void> logout(BPSUser user) async {
    try {
      final realmConfig = config.getConfig(user.realm);

      await _dio.post<dynamic>(
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
      _securityManager
        ..secureClearSensitiveData(user.accessToken)
        ..secureClearSensitiveData(user.refreshToken);
    } on Exception catch (e) {
      // Always clean up sensitive data even if logout fails
      _securityManager
        ..secureClearSensitiveData(user.accessToken)
        ..secureClearSensitiveData(user.refreshToken);

      // Handle error with security manager
      final errorConfig = config.errorConfig;
      errorConfig.onError?.call(
        LogoutException('Logout failed: $e'),
        StackTrace.current,
      );

      // Don't throw on logout failure in production
      if (errorConfig.enableDetailedErrorMessages) {
        debugPrint('Logout request failed: $e');
      }
    }
  }

  /// Validate access token
  Future<bool> validateToken(BPSUser user) async {
    try {
      final realmConfig = config.getConfig(user.realm);

      final response = await _dio.get<dynamic>(
        realmConfig.userInfoUrl,
        options: Options(
          headers: {'Authorization': 'Bearer ${user.accessToken}'},
        ),
      );

      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }

  /// Get user information from access token
  Future<Map<String, dynamic>> _getUserInfo({
    required String accessToken,
    required BPSRealmConfig config,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        config.userInfoUrl,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw UserInfoException(
          'Failed to get user info: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is BPSSsoException) rethrow;

      // Fallback: decode JWT token manually
      try {
        return _decodeJwtToken(accessToken);
      } on Exception {
        throw UserInfoException('Failed to get user info: $e');
      }
    }
  }

  /// Decode JWT token manually to extract user information
  Map<String, dynamic> _decodeJwtToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw const UserInfoException('Invalid JWT token format');
      }

      // Decode the payload (second part)
      var payload = parts[1];

      // Add padding if needed
      switch (payload.length % 4) {
        case 2:
          payload += '==';
        case 3:
          payload += '=';
      }

      final bytes = base64Url.decode(payload);
      final decoded = utf8.decode(bytes);
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      throw UserInfoException('Failed to decode JWT token: $e');
    }
  }

  /// Exchange authorization code for access tokens
  Future<Map<String, dynamic>> _exchangeCodeForTokens({
    required BPSRealmConfig config,
    required String authCode,
    required String codeVerifier,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        config.tokenUrl,
        data: {
          'grant_type': 'authorization_code',
          'client_id': config.clientId,
          'code': authCode,
          'redirect_uri': config.redirectUri,
          'code_verifier': codeVerifier,
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw TokenExchangeException.fromStatusCode(response.statusCode!);
      }
    } catch (e) {
      if (e is BPSSsoException) rethrow;
      throw TokenExchangeException('Token exchange failed: $e');
    }
  }

  /// Show Chrome Custom Tabs for authentication and capture authorization code
  Future<String?> _showCustomTabsAuth(
    BuildContext context,
    String authUrl,
    String expectedState,
    BPSRealmConfig config,
  ) async {
    try {
      final completer = Completer<String?>();
      StreamSubscription<String>? linkSubscription;

      // Listen for incoming deep links
      linkSubscription = linkStream?.listen((String link) async {
        // Validate deep link using security manager
        if (!_securityManager.validateDeepLink(link, expectedState)) {
          await linkSubscription?.cancel();
          completer.complete(null);
          final sanitizedError = _securityManager.sanitizeError(
            const SecurityException('Invalid deep link received'),
            isProduction: !this.config.errorConfig.enableDetailedErrorMessages,
          );
          _showErrorSnackBar(context, _getErrorMessage(sanitizedError));
          return;
        }

        final uri = Uri.parse(link);
        final redirectUri = Uri.parse(config.redirectUri);

        // Check if this is our callback URL
        if (uri.scheme == redirectUri.scheme && uri.host == redirectUri.host) {
          final code = uri.queryParameters['code'];
          final state = uri.queryParameters['state'];
          final error = uri.queryParameters['error'];

          linkSubscription?.cancel();

          if (error != null) {
            completer.complete(null);
            final sanitizedError = _securityManager.sanitizeError(
              NetworkException('Authentication failed: $error'),
              isProduction:
                  !this.config.errorConfig.enableDetailedErrorMessages,
            );
            _showErrorSnackBar(context, _getErrorMessage(sanitizedError));
            return;
          }

          if (code != null && state == expectedState) {
            completer.complete(code);
          } else {
            completer.complete(null);
            final sanitizedError = _securityManager.sanitizeError(
              const InvalidStateException(),
              isProduction:
                  !this.config.errorConfig.enableDetailedErrorMessages,
            );
            _showErrorSnackBar(context, _getErrorMessage(sanitizedError));
          }
        }
      });

      // Launch Custom Tabs with configuration
      await launchUrl(
        Uri.parse(authUrl),
        customTabsOptions: _buildCustomTabsOptions(),
        safariVCOptions: _buildSafariOptions(),
      );

      // Wait for the auth code or timeout
      return await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          linkSubscription?.cancel();
          return null;
        },
      );
    } catch (e) {
      debugPrint('Custom Tabs auth failed: $e');
      return null;
    }
  }

  /// Show error snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Build Custom Tabs options from configuration
  CustomTabsOptions _buildCustomTabsOptions() {
    final uiConfig = config.customTabsConfig;

    return CustomTabsOptions(
      colorSchemes: CustomTabsColorSchemes(
        defaultPrams: CustomTabsColorSchemeParams(
          toolbarColor: uiConfig.toolbarColor ?? const Color(0xFF1E3A8A),
          navigationBarColor: uiConfig.navigationBarColor,
        ),
        lightParams:
            uiConfig.enableColorScheme &&
                uiConfig.colorScheme == BPSSsoColorScheme.light
            ? CustomTabsColorSchemeParams(
                toolbarColor: uiConfig.toolbarColor ?? const Color(0xFF1E3A8A),
                navigationBarColor: uiConfig.navigationBarColor,
              )
            : null,
        darkParams:
            uiConfig.enableColorScheme &&
                uiConfig.colorScheme == BPSSsoColorScheme.dark
            ? CustomTabsColorSchemeParams(
                toolbarColor: uiConfig.toolbarColor ?? const Color(0xFF0F172A),
                navigationBarColor:
                    uiConfig.navigationBarColor ?? const Color(0xFF0F172A),
              )
            : null,
      ),
      shareState: uiConfig.enableDefaultShare
          ? CustomTabsShareState.on
          : CustomTabsShareState.off,
      urlBarHidingEnabled: uiConfig.enableUrlBarHiding,
      showTitle: uiConfig.showTitle,
      instantAppsEnabled: uiConfig.enableInstantApps,
      // Note: Custom menu items would need native implementation
    );
  }

  /// Build Safari View Controller options from configuration
  SafariViewControllerOptions _buildSafariOptions() {
    final uiConfig = config.customTabsConfig;

    return SafariViewControllerOptions(
      preferredBarTintColor: uiConfig.toolbarColor ?? const Color(0xFF1E3A8A),
      preferredControlTintColor: Colors.white,
      barCollapsingEnabled: uiConfig.enableUrlBarHiding,
      entersReaderIfAvailable: false,
    );
  }

  /// Get user-friendly error message from exception
  String _getErrorMessage(Exception error) {
    final errorConfig = config.errorConfig;

    // Use custom error messages if configured
    if (errorConfig.customErrorMessages.containsKey(error.runtimeType)) {
      return errorConfig.customErrorMessages[error.runtimeType]!;
    }

    // Default user-friendly messages
    if (error is AuthenticationCancelledException) {
      return 'Authentication was cancelled';
    } else if (error is NetworkException) {
      return 'Network connection failed. '
          'Please check your internet connection.';
    } else if (error is SecurityException) {
      return 'Security validation failed. Please try again.';
    } else if (error is InvalidStateException) {
      return 'Authentication security check failed. '
          'Please restart the login process.';
    } else {
      return 'Authentication failed. Please try again.';
    }
  }
}
