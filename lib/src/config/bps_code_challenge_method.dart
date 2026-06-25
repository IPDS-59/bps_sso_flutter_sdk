/// PKCE code challenge method for BPS SSO
enum BPSCodeChallengeMethod {
  s256,
  plain;

  String get value => switch (this) {
    s256 => 'S256',
    plain => 'plain',
  };
}
