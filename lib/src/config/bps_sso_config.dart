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
    this.authTimeout = const Duration(minutes: 5),
  });

  /// Factory constructor to create BPS SSO config with sensible defaults
  ///
  /// Parameters:
  /// - [internalRealmName]: Custom realm name for internal BPS realm.
  ///   If null, defaults to 'pegawai-bps' (BPSRealmType.internal.value)
  /// - [externalRealmName]: Custom realm name for external BPS realm.
  ///   If null, defaults to 'eksternal' (BPSRealmType.external.value)
  factory BPSSsoConfig.create({
    required String appName,
    required String internalClientId,
    required String externalClientId,
    String baseUrl = 'https://sso.bps.go.id',
    List<BPSOAuthResponseType> responseTypes = const [
      BPSOAuthResponseType.code,
    ],
    List<BPSOAuthScope> scopes = const [
      BPSOAuthScope.openid,
      BPSOAuthScope.profile,
      BPSOAuthScope.email,
    ],
    BPSCodeChallengeMethod codeChallengeMethod = BPSCodeChallengeMethod.s256,
    String? internalRealmName,
    String? externalRealmName,
    BPSSsoCustomTabsConfig? customTabsConfig,
    BPSSsoErrorConfig? errorConfig,
    BPSSsoSecurityConfig? securityConfig,
    BPSSsoAuthCallback? authCallbacks,
    List<Interceptor> interceptors = const <Interceptor>[],
    Duration authTimeout = const Duration(minutes: 5),
  }) {
    return BPSSsoConfig(
      baseUrl: baseUrl,
      internal: BPSRealmConfig(
        clientId: internalClientId,
        redirectUri: BPSRedirectUri(
          scheme: 'id.go.bps',
          host: '$appName-sso-internal',
        ),
        realmType: BPSRealmType.internal,
        baseUrl: baseUrl,
        responseTypes: responseTypes,
        scopes: scopes,
        codeChallengeMethod: codeChallengeMethod,
        realmName: internalRealmName,
      ),
      external: BPSRealmConfig(
        clientId: externalClientId,
        redirectUri: BPSRedirectUri(
          scheme: 'id.go.bps',
          host: '$appName-sso-eksternal',
        ),
        realmType: BPSRealmType.external,
        baseUrl: baseUrl,
        responseTypes: responseTypes,
        scopes: scopes,
        codeChallengeMethod: codeChallengeMethod,
        realmName: externalRealmName,
      ),
      customTabsConfig: customTabsConfig ?? const BPSSsoCustomTabsConfig(),
      errorConfig: errorConfig ?? const BPSSsoErrorConfig(),
      securityConfig: securityConfig ?? BPSSsoSecurityConfig.iso27001,
      authCallbacks: authCallbacks ?? BPSSsoAuthCallback.none,
      interceptors: interceptors,
      authTimeout: authTimeout,
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

  /// Maximum time to wait for the user to complete authentication in the
  /// browser before timing out. Increase this when OTP (e.g. TOTP or SMS)
  /// is required, as users need extra time to retrieve and enter the code.
  ///
  /// Defaults to 5 minutes.
  final Duration authTimeout;

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
