import 'package:bps_sso_sdk/src/config/config.dart';

/// Configuration for a specific BPS realm
class BPSRealmConfig {
  /// Create instance of [BPSRealmConfig]
  const BPSRealmConfig({
    required this.clientId,
    required this.redirectUri,
    required this.realm,
    required this.realmType,
    this.baseUrl = 'https://sso.bps.go.id',
    this.responseTypes = const ['code'],
    this.scopes = const ['openid', 'profile', 'email'],
    this.codeChallengeMethod = 'S256',
  });

  /// OAuth2 client ID for this realm
  final String clientId;

  /// Redirect URI for OAuth2 flow
  final String redirectUri;

  /// Keycloak realm name
  final String realm;

  /// Type of realm (internal/external)
  final BPSRealmType realmType;

  /// Base URL for BPS SSO server
  final String baseUrl;

  /// OAuth2 response types (default: ['code'])
  /// Common values: 'code', 'token', 'id_token'
  /// Can be combined: ['code', 'token'], ['code', 'id_token'], ['token',
  /// 'id_token']
  final List<String> responseTypes;

  /// OAuth2 scopes (default: ['openid', 'profile', 'email'])
  /// Common values: 'openid', 'profile', 'email', 'roles', 'groups',
  /// 'offline_access'
  final List<String> scopes;

  /// PKCE code challenge method (default: 'S256')
  /// Supported values: 'plain', 'S256'
  final String codeChallengeMethod;

  /// Get space-separated response type string for OAuth2 URL
  String get responseType => responseTypes.join(' ');

  /// Get space-separated scope string for OAuth2 URL
  String get scope => scopes.join(' ');

  /// Build authorization URL for this realm
  String buildAuthUrl({
    required String codeChallenge,
    required String state,
  }) {
    final params = <String, String>{
      'client_id': clientId,
      'response_type': responseType,
      'scope': scope,
      'redirect_uri': redirectUri,
      'state': state,
    };

    // Only add PKCE parameters if using authorization code flow
    if (responseTypes.contains('code')) {
      params['code_challenge'] = codeChallenge;
      params['code_challenge_method'] = codeChallengeMethod;
    }

    final query = params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');

    return '$baseUrl/auth/realms/$realm/protocol/openid-connect/auth?$query';
  }

  /// Get token endpoint URL
  String get tokenUrl =>
      '$baseUrl/auth/realms/$realm/protocol/openid-connect/token';

  /// Get user info endpoint URL
  String get userInfoUrl =>
      '$baseUrl/auth/realms/$realm/protocol/openid-connect/userinfo';

  /// Get logout endpoint URL
  String get logoutUrl =>
      '$baseUrl/auth/realms/$realm/protocol/openid-connect/logout';
}
