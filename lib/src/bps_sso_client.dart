import 'package:bps_sso_sdk/src/config/config.dart';
import 'package:bps_sso_sdk/src/exceptions/exceptions.dart';
import 'package:bps_sso_sdk/src/models/models.dart';
import 'package:bps_sso_sdk/src/services/services.dart';
import 'package:flutter/material.dart';

/// Main client for BPS SSO authentication
class BPSSsoClient {
  BPSSsoClient._internal();

  static final BPSSsoClient _instance = BPSSsoClient._internal();

  /// Get singleton instance
  static BPSSsoClient get instance => _instance;

  late final BPSSsoService _ssoService;
  late final BPSSsoConfig _config;
  bool _initialized = false;

  /// Initialize the BPS SSO client
  ///
  /// This must be called before using any other methods.
  ///
  /// [config] - SSO configuration with your app's client IDs and redirect URIs.
  ///            This is required and must be provided.
  /// [linkStream] - Stream of incoming deep links for handling OAuth callbacks.
  ///                Must be provided for Chrome Custom Tabs authentication to
  /// work.
  void initialize({
    required BPSSsoConfig config,
    Stream<String>? linkStream,
  }) {
    if (_initialized) return;

    _config = config;
    _ssoService = BPSSsoService(
      config: _config,
      linkStream: linkStream,
    );
    _initialized = true;
  }

  /// Authenticate user with BPS SSO using webview
  ///
  /// [context] - BuildContext for showing webview
  /// [realmType] - Type of BPS realm (internal or external)
  ///
  /// Returns [BPSUser] on successful authentication
  /// Throws [BPSSsoException] on failure
  Future<BPSUser> login({
    required BuildContext context,
    required BPSRealmType realmType,
  }) async {
    _ensureInitialized();

    return _ssoService.loginWithWebview(
      context: context,
      realmType: realmType,
    );
  }

  /// Refresh the access token for a user
  ///
  /// [user] - Current user with refresh token
  ///
  /// Returns [BPSUser] with updated tokens
  /// Throws [BPSSsoException] on failure
  Future<BPSUser> refreshToken(BPSUser user) async {
    _ensureInitialized();

    return _ssoService.refreshToken(user);
  }

  /// Logout user from BPS SSO
  ///
  /// [user] - User to logout
  ///
  /// This will revoke the refresh token on the server.
  /// Note: This method does not throw exceptions on failure,
  /// as logout should always succeed from the client perspective.
  Future<void> logout(BPSUser user) async {
    _ensureInitialized();

    await _ssoService.logout(user);
  }

  /// Validate if the user's access token is still valid
  ///
  /// [user] - User to validate
  ///
  /// Returns true if token is valid, false otherwise
  Future<bool> validateToken(BPSUser user) async {
    _ensureInitialized();

    // Check if token is expired locally first
    if (user.isTokenExpired) {
      return false;
    }

    // Validate with server
    return _ssoService.validateToken(user);
  }

  /// Check if a user needs token refresh
  ///
  /// [user] - User to check
  /// [bufferMinutes] - Minutes before expiry to consider as expired
  /// (default: 5)
  ///
  /// Returns true if token should be refreshed
  bool shouldRefreshToken(BPSUser user, {int bufferMinutes = 5}) {
    final buffer = Duration(minutes: bufferMinutes);
    final expiryWithBuffer = user.tokenExpiry.subtract(buffer);
    return DateTime.now().isAfter(expiryWithBuffer);
  }

  /// Get the configuration for a specific realm type
  ///
  /// [realmType] - Type of BPS realm
  ///
  /// Returns [BPSRealmConfig] for the specified realm
  BPSRealmConfig getRealmConfig(BPSRealmType realmType) {
    _ensureInitialized();
    return _config.getConfig(realmType);
  }

  /// Check if the SDK is initialized
  bool get isInitialized => _initialized;

  void _ensureInitialized() {
    if (!_initialized) {
      throw Exception(
        'BPSSsoClient is not initialized. Call initialize() first.',
      );
    }
  }
}

/// Extension methods for BPSUser to provide additional convenience methods
extension BPSUserExtensions on BPSUser {
  /// Get display name for the user
  String get displayName {
    if (fullName.isNotEmpty) return fullName;
    if (firstName != null && lastName != null) {
      return '${firstName!} ${lastName!}';
    }
    return username;
  }

  /// Get short display name (first name or username)
  String get shortDisplayName {
    return firstName ?? username;
  }

  /// Check if user is from internal BPS realm
  bool get isInternalUser => realm == BPSRealmType.internal;

  /// Check if user is from external BPS realm
  bool get isExternalUser => realm == BPSRealmType.external;

  /// Get realm display name
  String get realmDisplayName {
    switch (realm) {
      case BPSRealmType.internal:
        return 'Internal BPS';
      case BPSRealmType.external:
        return 'External BPS';
    }
  }

  /// Check if user has a photo
  bool get hasPhoto => photo != null && photo!.isNotEmpty;

  /// Get initials from the user's name
  String get initials {
    final name = displayName;
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words.first[0]}${words[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}
