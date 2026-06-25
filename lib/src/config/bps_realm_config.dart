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
    this.responseTypes = const [BPSOAuthResponseType.code],
    this.scopes = const [
      BPSOAuthScope.openid,
      BPSOAuthScope.profile,
      BPSOAuthScope.email,
    ],
    this.codeChallengeMethod = BPSCodeChallengeMethod.s256,
    this.realmName,
  });

  /// OAuth2 client ID for this realm
  final String clientId;

  /// Redirect URI for OAuth2 flow
  final BPSRedirectUri redirectUri;

  /// Type of realm (internal/external)
  final BPSRealmType realmType;

  /// Base URL for BPS SSO server
  final String baseUrl;

  /// OAuth2 response types (default: [BPSOAuthResponseType.code])
  final List<BPSOAuthResponseType> responseTypes;

  /// OAuth2 scopes
  final List<BPSOAuthScope> scopes;

  /// PKCE code challenge method (default: S256)
  final BPSCodeChallengeMethod codeChallengeMethod;

  /// Optional custom realm name
  /// If null, uses realmType.value as the realm name
  final String? realmName;

  /// Get space-separated response type string for OAuth2 URL
  String get responseType => responseTypes.map((e) => e.value).join(' ');

  /// Get space-separated scope string for OAuth2 URL
  String get scope => scopes.map((e) => e.value).join(' ');

  /// Build authorization URL for this realm
  String buildAuthUrl({
    required String codeChallenge,
    required String state,
  }) {
    final params = <String, String>{
      'client_id': clientId,
      'response_type': responseType,
      'scope': scope,
      'redirect_uri': redirectUri.toString(),
      'state': state,
    };

    if (responseTypes.contains(BPSOAuthResponseType.code)) {
      params['code_challenge'] = codeChallenge;
      params['code_challenge_method'] = codeChallengeMethod.value;
    }

    final query = params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');

    return '$baseUrl/auth/realms/$realm/protocol/openid-connect/auth?$query';
  }

  /// Keycloak realm name
  /// Uses custom realmName if provided, otherwise defaults to realmType.value
  String get realm => realmName ?? realmType.value;

  /// Get token endpoint URL
  String get tokenUrl =>
      '$baseUrl/auth/realms/$realm/protocol/openid-connect/token';

  /// Get user info endpoint URL
  String get userInfoUrl =>
      '$baseUrl/auth/realms/$realm/protocol/openid-connect/userinfo';

  /// Get logout endpoint URL
  String get logoutUrl =>
      '$baseUrl/auth/realms/$realm/protocol/openid-connect/logout';

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
        other.codeChallengeMethod == codeChallengeMethod &&
        other.realmName == realmName;
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
      realmName,
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
