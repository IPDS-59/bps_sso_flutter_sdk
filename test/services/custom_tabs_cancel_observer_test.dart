import 'package:bps_sso_sdk/src/services/mixins/custom_tabs_mixin.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void _drive(
  CustomTabsCancelObserver observer,
  List<AppLifecycleState> states,
) => states.forEach(observer.didChangeAppLifecycleState);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CustomTabsCancelObserver', () {
    test(
      'does not fire immediately on resume; fires after 1500 ms',
      () {
        fakeAsync((async) {
          var callCount = 0;
          final observer = CustomTabsCancelObserver(
            onCancelDetected: () => callCount++,
          );

          _drive(observer, [
            AppLifecycleState.paused,
            AppLifecycleState.resumed,
          ]);

          // Not called immediately on resume.
          expect(callCount, 0);

          async.elapse(const Duration(milliseconds: 1499));
          expect(callCount, 0);

          async.elapse(const Duration(milliseconds: 1));
          expect(callCount, 1);

          observer.dispose();
        });
      },
    );

    test(
      'cancels pending timer when host re-leaves resumed; callback never fires',
      () {
        fakeAsync((async) {
          var callCount = 0;
          final observer = CustomTabsCancelObserver(
            onCancelDetected: () => callCount++,
          );

          // First trip: paused → resumed (schedules timer).
          _drive(observer, [
            AppLifecycleState.paused,
            AppLifecycleState.resumed,
          ]);

          // Host re-leaves resumed before timer fires (system dialog / switcher).
          async.elapse(const Duration(milliseconds: 500));
          _drive(observer, [AppLifecycleState.paused]);

          // Let plenty of time pass — the timer must have been cancelled.
          async.elapse(const Duration(seconds: 5));
          expect(callCount, 0);

          observer.dispose();
        });
      },
    );

    test(
      'does not fire after dispose cancels the timer',
      () {
        fakeAsync((async) {
          var callCount = 0;
          final observer = CustomTabsCancelObserver(
            onCancelDetected: () => callCount++,
          );

          _drive(observer, [
            AppLifecycleState.paused,
            AppLifecycleState.resumed,
          ]);

          async.elapse(const Duration(milliseconds: 1000));

          // Simulate external completer completion (deep-link success) by
          // disposing the observer before the grace timer fires.
          observer.dispose();

          async.elapse(const Duration(milliseconds: 1000));
          expect(callCount, 0);
        });
      },
    );
  });
}
