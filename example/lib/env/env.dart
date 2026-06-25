import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'BASE_URL', defaultValue: 'https://sso.bps.go.id')
  static final String baseUrl = _Env.baseUrl;

  @EnviedField(varName: 'INTERNAL_CLIENT_ID', defaultValue: '')
  static final String internalClientId = _Env.internalClientId;

  @EnviedField(varName: 'INTERNAL_REDIRECT_SCHEME', defaultValue: 'id.go.bps')
  static final String internalRedirectScheme = _Env.internalRedirectScheme;

  @EnviedField(varName: 'INTERNAL_REDIRECT_HOST', defaultValue: '')
  static final String internalRedirectHost = _Env.internalRedirectHost;

  @EnviedField(varName: 'INTERNAL_REALM', defaultValue: 'pegawai-bps')
  static final String internalRealm = _Env.internalRealm;

  @EnviedField(varName: 'EXTERNAL_CLIENT_ID', defaultValue: '')
  static final String externalClientId = _Env.externalClientId;

  @EnviedField(varName: 'EXTERNAL_REDIRECT_SCHEME', defaultValue: 'id.go.bps')
  static final String externalRedirectScheme = _Env.externalRedirectScheme;

  @EnviedField(varName: 'EXTERNAL_REDIRECT_HOST', defaultValue: '')
  static final String externalRedirectHost = _Env.externalRedirectHost;

  @EnviedField(varName: 'EXTERNAL_REALM', defaultValue: 'eksternal')
  static final String externalRealm = _Env.externalRealm;
}
