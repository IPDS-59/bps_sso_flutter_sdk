import 'dart:convert';

import 'package:bps_sso_sdk/src/config/bps_realm_config.dart';
import 'package:bps_sso_sdk/src/config/bps_sso_config.dart';
import 'package:bps_sso_sdk/src/core/constants.dart';
import 'package:bps_sso_sdk/src/core/token_cache.dart';
import 'package:bps_sso_sdk/src/core/token_utils.dart';
import 'package:bps_sso_sdk/src/exceptions/exceptions.dart';
import 'package:bps_sso_sdk/src/models/bps_user.dart';
import 'package:bps_sso_sdk/src/security/bps_sso_security_manager.dart';
import 'package:dio/dio.dart';

/// Mixin providing token-related operations for BPS SSO service
mixin TokenOperationsMixin {
  /// Get the Dio client instance
  Dio get dio;

  /// Get the SSO configuration
  BPSSsoConfig get config;

  /// Get the security manager
  BPSSsoSecurityManager get securityManager;

  /// Refresh access token using refresh token
  Future<BPSUser> refreshToken(BPSUser user) async {
    try {
      final realmConfig = config.getConfig(user.realm);

      final response = await dio.post<dynamic>(
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

      if (response.statusCode == HttpStatusCodes.ok) {
        final tokenData = response.data as Map<String, dynamic>;

        final newAccessToken = tokenData['access_token'] as String?;
        final newRefreshToken = tokenData['refresh_token'] as String?;

        if (newAccessToken == null) {
          throw const TokenExchangeException(
            'Access token is null in refresh response',
          );
        }

        // Get updated user info
        final userInfo = await getUserInfo(
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
        securityManager.secureClearSensitiveData(user.accessToken);
        if (newRefreshToken != null) {
          securityManager.secureClearSensitiveData(user.refreshToken);
        }

        final updatedUser = BPSUser.fromJson(userData, user.realm);

        // Call success callback
        config.authCallbacks.onTokenRefreshSuccess?.call(updatedUser);

        return updatedUser;
      } else {
        throw TokenExchangeException.fromStatusCode(response.statusCode!);
      }
    } on Exception catch (e) {
      // Handle token refresh failure
      Exception error;
      if (e is BPSSsoException) {
        error = e;
      } else {
        error = NetworkException('Token refresh failed: $e');
      }

      // Call token refresh failed callback
      config.authCallbacks.onTokenRefreshFailed?.call(error, user);

      // Check if this is an authentication failure
      if (e is TokenExchangeException ||
          (e is DioException &&
              (e.response?.statusCode == 401 ||
                  e.response?.statusCode == 403))) {
        config.authCallbacks.onAuthenticationFailure?.call(error, user);
      }

      throw error;
    }
  }

  /// Validate access token with caching for improved performance
  Future<bool> validateToken(BPSUser user) async {
    try {
      // Quick local check first - if token is expired, no need to validate
      if (user.isTokenExpired) {
        return false;
      }

      // Check if token is near expiry using buffer time
      final tokenExpiry = TokenUtils.extractTokenExpiry(user.accessToken);
      if (tokenExpiry != null &&
          TokenUtils.isTokenNearExpiry(
            tokenExpiry,
            SecurityConstants.tokenExpiryBuffer,
          )) {
        return false;
      }

      // Check cache for recent validation result
      final tokenHash = TokenUtils.hashToken(user.accessToken);
      final cachedResult = TokenValidationCache.instance.getCachedValidation(
        userId: user.id,
        tokenHash: tokenHash,
      );

      if (cachedResult != null) {
        return cachedResult;
      }

      // Perform network validation
      final realmConfig = config.getConfig(user.realm);
      final response = await dio.get<dynamic>(
        realmConfig.userInfoUrl,
        options: Options(
          headers: {'Authorization': 'Bearer ${user.accessToken}'},
        ),
      );

      bool isValid;
      if (response.statusCode == HttpStatusCodes.ok) {
        isValid = true;
      } else if (response.statusCode == HttpStatusCodes.unauthorized ||
          response.statusCode == HttpStatusCodes.forbidden) {
        config.authCallbacks.onAuthenticationFailure?.call(
          SecurityException('Token validation failed: ${response.statusCode}'),
          user,
        );
        isValid = false;
      } else {
        isValid = false;
      }

      // Cache the validation result
      TokenValidationCache.instance.cacheValidation(
        userId: user.id,
        tokenHash: tokenHash,
        isValid: isValid,
      );

      return isValid;
    } on Exception catch (e) {
      if (e is DioException &&
          (e.response?.statusCode == HttpStatusCodes.unauthorized ||
              e.response?.statusCode == HttpStatusCodes.forbidden)) {
        config.authCallbacks.onAuthenticationFailure?.call(
          SecurityException(
            'Token validation failed: ${e.response?.statusCode}',
          ),
          user,
        );

        final tokenHash = TokenUtils.hashToken(user.accessToken);
        TokenValidationCache.instance.cacheValidation(
          userId: user.id,
          tokenHash: tokenHash,
          isValid: false,
        );
      }
      return false;
    }
  }

  /// Exchange authorization code for access tokens
  Future<Map<String, dynamic>> exchangeCodeForTokens({
    required BPSRealmConfig realmConfig,
    required String authCode,
    required String codeVerifier,
  }) async {
    try {
      final response = await dio.post<dynamic>(
        realmConfig.tokenUrl,
        data: {
          'grant_type': 'authorization_code',
          'client_id': realmConfig.clientId,
          'code': authCode,
          'redirect_uri': realmConfig.redirectUri,
          'code_verifier': codeVerifier,
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      if (response.statusCode == HttpStatusCodes.ok) {
        return response.data as Map<String, dynamic>;
      } else {
        throw TokenExchangeException.fromStatusCode(response.statusCode!);
      }
    } catch (e) {
      if (e is BPSSsoException) rethrow;
      throw TokenExchangeException('Token exchange failed: $e');
    }
  }

  /// Get user information from access token
  Future<Map<String, dynamic>> getUserInfo({
    required String accessToken,
    required BPSRealmConfig config,
  }) async {
    try {
      final response = await dio.get<dynamic>(
        config.userInfoUrl,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode == HttpStatusCodes.ok) {
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
        return decodeJwtToken(accessToken);
      } on Exception {
        throw UserInfoException('Failed to get user info: $e');
      }
    }
  }

  /// Decode JWT token manually to extract user information
  Map<String, dynamic> decodeJwtToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw const UserInfoException('Invalid JWT token format');
      }

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
}
