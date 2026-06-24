#!/usr/bin/env dart
// dart run tool/setup_app_id.dart [--app-name=myapp]
//
// Patches AndroidManifest.xml and Info.plist with the SSO redirect URI host.
// App name resolution order:
//   1. --app-name CLI argument
//   2. APP_NAME in example/.env
//   3. APP_NAME in .env (repo root)

import 'dart:io';

void main(List<String> args) {
  final appName = _resolveAppName(args);
  if (appName == null) {
    stderr.writeln(
      'Error: APP_NAME not set. Provide it via --app-name=<name> or .env.',
    );
    exit(1);
  }

  _patchAndroidManifest(appName);
  _patchInfoPlist(appName);

  stdout.writeln('✓ App ID set to "$appName"');
}

String? _resolveAppName(List<String> args) {
  // 1. CLI arg
  const prefix = '--app-name=';
  for (final arg in args) {
    if (arg.startsWith(prefix)) {
      final name = arg.substring(prefix.length).trim();
      if (name.isNotEmpty) return name;
    }
  }

  // 2. .env in example/ dir (script lives in example/tool/)
  final scriptDir = File(Platform.script.toFilePath()).parent.parent;
  final envFiles = [
    File('${scriptDir.path}/.env'),
    File('${scriptDir.parent.path}/.env'),
  ];

  for (final envFile in envFiles) {
    if (!envFile.existsSync()) continue;
    for (final line in envFile.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.startsWith('#') || !trimmed.contains('=')) continue;
      final idx = trimmed.indexOf('=');
      final key = trimmed.substring(0, idx).trim();
      final value = trimmed.substring(idx + 1).trim();
      if (key == 'APP_NAME' && value.isNotEmpty) return value;
    }
  }

  return null;
}

void _patchAndroidManifest(String appName) {
  final manifest = File(
    '${Platform.script.toFilePath().split('/tool/').first}/android/app/src/main/AndroidManifest.xml',
  );

  if (!manifest.existsSync()) {
    stderr.writeln('Warning: AndroidManifest.xml not found at ${manifest.path}');
    return;
  }

  var content = manifest.readAsStringSync();
  content = content.replaceAll(
    RegExp(r'android:host="[^"]*-sso-internal"'),
    'android:host="$appName-sso-internal"',
  );
  content = content.replaceAll(
    RegExp(r'android:host="[^"]*-sso-eksternal"'),
    'android:host="$appName-sso-eksternal"',
  );
  manifest.writeAsStringSync(content);
  stdout.writeln('  Patched AndroidManifest.xml');
}

void _patchInfoPlist(String appName) {
  final plist = File(
    '${Platform.script.toFilePath().split('/tool/').first}/ios/Runner/Info.plist',
  );

  if (!plist.existsSync()) {
    stderr.writeln('Warning: Info.plist not found at ${plist.path}');
    return;
  }

  var content = plist.readAsStringSync();
  content = content.replaceAll(
    RegExp(r'(<key>BPSSsoAppName</key>\s*<string>)[^<]*(</string>)'),
    '<key>BPSSsoAppName</key>\n    <string>$appName</string>',
  );
  plist.writeAsStringSync(content);
  stdout.writeln('  Patched Info.plist');
}
