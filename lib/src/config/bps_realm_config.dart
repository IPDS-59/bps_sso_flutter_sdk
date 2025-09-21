import 'package:bps_sso_sdk/src/config/config.dart';
import 'package:flutter/foundation.dart';

/// Configuration for a specific BPS realm
@immutable
class BPSRealmConfig {
  /// Create instance of [BPSRealmConfig]
  const BPSRealmConfig({
    required this.clientId,
    required this.redirectUri,
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

    return '$baseUrl/realms/$realm/protocol/openid-connect/auth?$query';
  }

  /// Keycloak realm name
  String get realm => realmType.value;

  /// Get token endpoint URL
  String get tokenUrl => '$baseUrl/realms/$realm/protocol/openid-connect/token';

  /// Get user info endpoint URL
  String get userInfoUrl =>
      '$baseUrl/realms/$realm/protocol/openid-connect/userinfo';

  /// Get logout endpoint URL
  String get logoutUrl =>
      '$baseUrl/realms/$realm/protocol/openid-connect/logout';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BPSRealmConfig &&
        other.clientId == clientId &&
        other.redirectUri == redirectUri &&
        other.realmType == realmType &&
        other.baseUrl == baseUrl &&
        _listEquals(other.responseTypes, responseTypes) &&
        _listEquals(other.scopes, scopes) &&
        other.codeChallengeMethod == codeChallengeMethod;
  }

  @override
  int get hashCode {
    return Object.hash(
      clientId,
      redirectUri,
      realmType,
      baseUrl,
      Object.hashAll(responseTypes),
      Object.hashAll(scopes),
      codeChallengeMethod,
    );
  }

  /// Helper method to compare lists
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
