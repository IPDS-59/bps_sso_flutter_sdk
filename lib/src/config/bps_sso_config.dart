import 'package:bps_sso_sdk/src/config/config.dart';
import 'package:dio/dio.dart';

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
    this.interceptors = const <Interceptor>[],
  });

  /// Factory constructor to create BPS SSO config with sensible defaults
  factory BPSSsoConfig.create({
    required String appName,
    required String internalClientId,
    required String externalClientId,
    String baseUrl = 'https://sso.bps.go.id',
    List<String> responseTypes = const ['code'],
    List<String> scopes = const ['openid', 'profile', 'email'],
    String codeChallengeMethod = 'S256',
    BPSSsoCustomTabsConfig? customTabsConfig,
    BPSSsoErrorConfig? errorConfig,
    BPSSsoSecurityConfig? securityConfig,
    BPSSsoAuthCallback? authCallbacks,
    List<Interceptor> interceptors = const <Interceptor>[],
  }) {
    return BPSSsoConfig(
      baseUrl: baseUrl,
      internal: BPSRealmConfig(
        clientId: internalClientId,
        redirectUri: 'id.go.bps://$appName-sso-internal',
        realmType: BPSRealmType.internal,
        baseUrl: baseUrl,
        responseTypes: responseTypes,
        scopes: scopes,
        codeChallengeMethod: codeChallengeMethod,
      ),
      external: BPSRealmConfig(
        clientId: externalClientId,
        redirectUri: 'id.go.bps://$appName-sso-eksternal',
        realmType: BPSRealmType.external,
        baseUrl: baseUrl,
        responseTypes: responseTypes,
        scopes: scopes,
        codeChallengeMethod: codeChallengeMethod,
      ),
      customTabsConfig: customTabsConfig ?? const BPSSsoCustomTabsConfig(),
      errorConfig: errorConfig ?? const BPSSsoErrorConfig(),
      securityConfig: securityConfig ?? BPSSsoSecurityConfig.iso27001,
      authCallbacks: authCallbacks ?? BPSSsoAuthCallback.none,
      interceptors: interceptors,
    );
  }

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

  /// Custom Dio interceptors for HTTP requests
  ///
  /// Use this to add logging, retry logic, SSL pinning, etc.
  /// Example:
  /// ```dart
  /// import 'package:dio/dio.dart';
  ///
  /// final config = BPSSsoConfig.create(
  ///   appName: 'MyApp',
  ///   internalClientId: 'client_id',
  ///   externalClientId: 'external_id',
  ///   interceptors: [
  ///     LogInterceptor(requestBody: true, responseBody: true),
  ///     // Custom SSL pinning interceptor
  ///     // Retry interceptor
  ///   ],
  /// );
  /// ```
  final List<Interceptor> interceptors;

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
