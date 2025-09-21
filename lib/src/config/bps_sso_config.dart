import 'package:bps_sso_sdk/src/config/config.dart';

/// Configuration class for BPS SSO settings
class BPSSsoConfig {
  /// Create an instance of [BPSSsoConfig]
  const BPSSsoConfig({
    required this.internal,
    required this.external,
    this.baseUrl = 'https://sso.bps.go.id',
    this.customTabsConfig = const BPSSsoCustomTabsConfig(),
    this.errorConfig = const BPSSsoErrorConfig(),
    this.securityConfig = BPSSsoSecurityConfig.iso27001,
    this.authCallbacks = BPSSsoAuthCallback.none,
  });

  /// Base URL for BPS SSO server
  final String baseUrl;

  /// Internal BPS realm configuration (for BPS employees)
  final BPSRealmConfig internal;

  /// External BPS realm configuration (for external users)
  final BPSRealmConfig external;

  /// Chrome Custom Tabs UI configuration
  final BPSSsoCustomTabsConfig customTabsConfig;

  /// Error handling configuration
  final BPSSsoErrorConfig errorConfig;

  /// Security configuration
  final BPSSsoSecurityConfig securityConfig;

  /// Authentication callbacks
  final BPSSsoAuthCallback authCallbacks;

  /// Get configuration for specific realm type
  BPSRealmConfig getConfig(BPSRealmType realmType) {
    switch (realmType) {
      case BPSRealmType.internal:
        return internal;
      case BPSRealmType.external:
        return external;
    }
  }
}
