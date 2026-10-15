import 'dart:async';

import 'package:bps_sso_sdk/src/config/config.dart';
import 'package:bps_sso_sdk/src/security/bps_sso_security_manager.dart';
import 'package:bps_sso_sdk/src/services/mixins/custom_tabs_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSecurityManager implements BPSSsoSecurityManager {
  @override
  bool validateDeepLink(String link, String expectedState) => true;

  @override
  Exception sanitizeError(dynamic error, {required bool isProduction}) =>
      error as Exception;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Harness with CustomTabsMixin {
  _Harness(this.config);

  final links = StreamController<String>.broadcast();

  @override
  final BPSSsoConfig config;

  @override
  final BPSSsoSecurityManager securityManager = _FakeSecurityManager();

  @override
  Stream<String>? get linkStream => links.stream;
}

const _state = 'expected-state';
const _channel = MethodChannel('plugins.flutter.droibit.github.io/custom_tabs');

void main() {
  late _Harness harness;
  late BuildContext context;

  final config = BPSSsoConfig.create(
    appName: 'testapp',
    internalClientId: 'internal',
    externalClientId: 'external',
    authTimeout: const Duration(seconds: 10),
  );
  final deepLink = '${config.internal.redirectUri}?code=abc&state=$_state';

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (_) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  // Created inside the test body so streams bind to the fake-async zone.
  Future<void> pumpHost(WidgetTester tester) {
    harness = _Harness(config);
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  // StreamSubscription.cancel() resolves on the root zone, outside fake
  // async, so let the real event loop turn once.
  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
  }

  Future<String?> runAuth(
    WidgetTester tester,
    Future<void> Function() during,
  ) async {
    String? result = 'pending';
    unawaited(
      harness
          .showCustomTabsAuth(
            context,
            'https://sso.bps.go.id/auth',
            _state,
            config.internal,
          )
          .then((r) => result = r),
    );
    await tester.pump();
    await during();
    await tester.pump(const Duration(seconds: 2));
    await settle(tester);
    return result;
  }

  void lifecycle(WidgetTester tester, AppLifecycleState state) =>
      tester.binding.handleAppLifecycleStateChanged(state);

  testWidgets('resume without deep link is treated as cancel', (tester) async {
    await pumpHost(tester);
    final result = await runAuth(tester, () async {
      lifecycle(tester, AppLifecycleState.inactive);
      lifecycle(tester, AppLifecycleState.resumed);
    });
    expect(result, isNull);
  });

  testWidgets('deep link arriving after cancel is ignored', (tester) async {
    await pumpHost(tester);
    final result = await runAuth(tester, () async {
      lifecycle(tester, AppLifecycleState.inactive);
      lifecycle(tester, AppLifecycleState.resumed);
    });
    expect(result, isNull);

    harness.links.add(deepLink);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('deep link racing the resume still completes login', (
    tester,
  ) async {
    await pumpHost(tester);
    final result = await runAuth(tester, () async {
      lifecycle(tester, AppLifecycleState.inactive);
      lifecycle(tester, AppLifecycleState.resumed);
      harness.links.add(deepLink);
      await settle(tester);
    });
    expect(result, 'abc');
  });

  testWidgets('honours config.authTimeout', (tester) async {
    await pumpHost(tester);
    String? result = 'pending';
    unawaited(
      harness
          .showCustomTabsAuth(
            context,
            'https://sso.bps.go.id/auth',
            _state,
            config.internal,
          )
          .then((r) => result = r),
    );
    await tester.pump(const Duration(seconds: 9));
    expect(result, 'pending');
    await tester.pump(const Duration(seconds: 2));
    await settle(tester);
    expect(result, isNull);
    await tester.pump(const Duration(seconds: 1));
  });
}
