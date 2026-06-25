import 'package:flutter/foundation.dart';

/// Typed redirect URI for BPS SSO OAuth2 flow
///
/// Builds URIs of the form: `scheme://host`
/// e.g. `id.go.bps://fasih-sso-internal`
@immutable
class BPSRedirectUri {
  const BPSRedirectUri({required this.scheme, required this.host});

  /// URI scheme, e.g. `id.go.bps`
  final String scheme;

  /// URI host, e.g. `fasih-sso-internal`
  final String host;

  @override
  String toString() => '$scheme://$host';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BPSRedirectUri && other.scheme == scheme && other.host == host;

  @override
  int get hashCode => Object.hash(scheme, host);
}
