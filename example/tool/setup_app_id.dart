#!/usr/bin/env dart
// dart run tool/setup_app_id.dart [--revert]
//
// Patches AndroidManifest.xml and Info.plist with SSO redirect URI schemes
// and hosts read from example/.env:
//   INTERNAL_REDIRECT_SCHEME, INTERNAL_REDIRECT_HOST
//   EXTERNAL_REDIRECT_SCHEME, EXTERNAL_REDIRECT_HOST
//
// Falls back to APP_NAME:
//   scheme → id.go.bps, host → <APP_NAME>-sso-internal / -sso-eksternal
//
// Pass --revert to reset everything back to PLACEHOLDER_* tokens.

import 'dart:io';

const _internalSchemeToken = 'PLACEHOLDER_INTERNAL_SCHEME';
const _internalHostToken = 'PLACEHOLDER_INTERNAL_HOST';
const _externalSchemeToken = 'PLACEHOLDER_EXTERNAL_SCHEME';
const _externalHostToken = 'PLACEHOLDER_EXTERNAL_HOST';

void main(List<String> args) {
  final revert = args.contains('--revert');

  if (revert) {
    _patchAndroidManifest(
      internalScheme: _internalSchemeToken,
      internalHost: _internalHostToken,
      externalScheme: _externalSchemeToken,
      externalHost: _externalHostToken,
    );
    _patchInfoPlist(
      internalScheme: _internalSchemeToken,
      internalHost: _internalHostToken,
      externalScheme: _externalSchemeToken,
      externalHost: _externalHostToken,
    );
    stdout.writeln('✓ Reverted to PLACEHOLDER tokens');
    return;
  }

  final env = _readEnv();

  final internalScheme = env['INTERNAL_REDIRECT_SCHEME']?.isNotEmpty == true
      ? env['INTERNAL_REDIRECT_SCHEME']!
      : (env['APP_NAME'] != null ? 'id.go.bps' : null);

  final internalHost = env['INTERNAL_REDIRECT_HOST']?.isNotEmpty == true
      ? env['INTERNAL_REDIRECT_HOST']!
      : _deriveHost(env['APP_NAME'], 'internal');

  final externalScheme = env['EXTERNAL_REDIRECT_SCHEME']?.isNotEmpty == true
      ? env['EXTERNAL_REDIRECT_SCHEME']!
      : (env['APP_NAME'] != null ? 'id.go.bps' : null);

  final externalHost = env['EXTERNAL_REDIRECT_HOST']?.isNotEmpty == true
      ? env['EXTERNAL_REDIRECT_HOST']!
      : _deriveHost(env['APP_NAME'], 'eksternal');

  if (internalScheme == null ||
      internalHost == null ||
      externalScheme == null ||
      externalHost == null) {
    stderr.writeln(
      'Error: Set INTERNAL_REDIRECT_SCHEME, INTERNAL_REDIRECT_HOST, '
      'EXTERNAL_REDIRECT_SCHEME, EXTERNAL_REDIRECT_HOST in .env.',
    );
    exit(1);
  }

  _patchAndroidManifest(
    internalScheme: internalScheme,
    internalHost: internalHost,
    externalScheme: externalScheme,
    externalHost: externalHost,
  );
  _patchInfoPlist(
    internalScheme: internalScheme,
    internalHost: internalHost,
    externalScheme: externalScheme,
    externalHost: externalHost,
  );

  stdout.writeln('✓ Internal:  $internalScheme://$internalHost');
  stdout.writeln('✓ External:  $externalScheme://$externalHost');
}

String? _deriveHost(String? appName, String suffix) {
  if (appName == null || appName.isEmpty) return null;
  return '$appName-sso-$suffix';
}

Map<String, String> _readEnv() {
  final scriptDir = File(Platform.script.toFilePath()).parent.parent;
  final envFile = File('${scriptDir.path}/.env');
  if (!envFile.existsSync()) return {};

  final result = <String, String>{};
  for (final line in envFile.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.startsWith('#') || !trimmed.contains('=')) continue;
    final idx = trimmed.indexOf('=');
    final key = trimmed.substring(0, idx).trim();
    final value = trimmed.substring(idx + 1).trim();
    if (key.isNotEmpty) result[key] = value;
  }
  return result;
}

// Manifest uses two separate <data> elements — match each by their position
// (internal comes first, external second). We use regex so it always works
// regardless of current values (token or real).
void _patchAndroidManifest({
  required String internalScheme,
  required String internalHost,
  required String externalScheme,
  required String externalHost,
}) {
  final manifest = File(
    '${_exampleRoot()}/android/app/src/main/AndroidManifest.xml',
  );
  if (!manifest.existsSync()) {
    stderr.writeln('Warning: AndroidManifest.xml not found');
    return;
  }

  var content = manifest.readAsStringSync();
  final dataPattern = RegExp(
    r'<data android:scheme="[^"]+" android:host="[^"]+" />',
  );

  // Replace internal (first match)
  content = content.replaceFirstMapped(
    dataPattern,
    (_) =>
        '<data android:scheme="$internalScheme" android:host="$internalHost" />',
  );

  // Replace external (last remaining match)
  final matches = dataPattern.allMatches(content).toList();
  if (matches.isNotEmpty) {
    final last = matches.last;
    content =
        '${content.substring(0, last.start)}'
        '<data android:scheme="$externalScheme" android:host="$externalHost" />'
        '${content.substring(last.end)}';
  }

  manifest.writeAsStringSync(content);
  stdout.writeln('  Patched AndroidManifest.xml');
}

void _patchInfoPlist({
  required String internalScheme,
  required String internalHost,
  required String externalScheme,
  required String externalHost,
}) {
  final plist = File('${_exampleRoot()}/ios/Runner/Info.plist');
  if (!plist.existsSync()) {
    stderr.writeln('Warning: Info.plist not found');
    return;
  }

  var content = plist.readAsStringSync();

  // All four values are identified by unique marker strings — replace by marker.
  // Scheme entries sit inside named dicts; host entries use dedicated keys.
  content = _replaceMarked(
    content,
    'BPS SSO Internal</string>',
    RegExp(r'<string>[^<]*</string>'),
    '<string>$internalScheme</string>',
  );
  content = _replaceMarked(
    content,
    'BPS SSO External</string>',
    RegExp(r'<string>[^<]*</string>'),
    '<string>$externalScheme</string>',
  );
  content = _replaceKeyValue(content, 'BPSSsoInternalHost', internalHost);
  content = _replaceKeyValue(content, 'BPSSsoExternalHost', externalHost);

  plist.writeAsStringSync(content);
  stdout.writeln('  Patched Info.plist');
}

// Finds [marker] in [source], then replaces the next occurrence of [pattern]
// after that marker with [replacement].
String _replaceMarked(
  String source,
  String marker,
  RegExp pattern,
  String replacement,
) {
  final markerIdx = source.indexOf(marker);
  if (markerIdx == -1) return source;
  final after = source.substring(markerIdx);
  final m = pattern.firstMatch(after);
  if (m == null) return source;
  final start = markerIdx + m.start;
  final end = markerIdx + m.end;
  return source.substring(0, start) + replacement + source.substring(end);
}

// Replaces the <string> value after <key>[key]</key> in a plist.
String _replaceKeyValue(String source, String key, String value) {
  return source.replaceFirstMapped(
    RegExp('<key>$key</key>\\s*<string>[^<]*</string>'),
    (m) {
      final block = m[0]!;
      return block.replaceFirst(
        RegExp(r'<string>[^<]*</string>'),
        '<string>$value</string>',
      );
    },
  );
}

String _exampleRoot() => Platform.script.toFilePath().split('/tool/').first;
