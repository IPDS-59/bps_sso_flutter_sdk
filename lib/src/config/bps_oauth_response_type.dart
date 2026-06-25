/// OAuth2 response types for BPS SSO authorization flow
enum BPSOAuthResponseType {
  code,
  token,
  idToken;

  String get value => switch (this) {
    code => 'code',
    token => 'token',
    idToken => 'id_token',
  };
}
