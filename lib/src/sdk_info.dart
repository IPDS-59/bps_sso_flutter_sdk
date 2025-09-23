/// BPS SSO SDK information and metadata
class BPSSsoSdkInfo {
  /// Current version of the BPS SSO SDK
  static const String version = '1.2.0';

  /// SDK name
  static const String name = 'BPS SSO SDK';

  /// SDK description
  static const String description =
      'A Flutter SDK for BPS (Badan Pusat Statistik) SSO authentication '
      'integration';

  /// SDK homepage URL
  static const String homepage =
      'https://github.com/IPDS-59/bps_sso_flutter_sdk';

  /// SDK repository URL
  static const String repository =
      'https://github.com/IPDS-59/bps_sso_flutter_sdk';

  /// Get full SDK info as a formatted string
  static String get fullInfo => '$name v$version';

  /// Get detailed SDK info as a map
  static Map<String, String> get details => {
    'name': name,
    'version': version,
    'description': description,
    'homepage': homepage,
    'repository': repository,
  };
}
