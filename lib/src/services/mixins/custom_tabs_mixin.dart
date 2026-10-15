// The BuildContext is used within stream listeners which handle deep link
// callbacks. The context is checked with `mounted` before use.
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:bps_sso_sdk/src/config/bps_realm_config.dart';
import 'package:bps_sso_sdk/src/config/bps_sso_config.dart';
import 'package:bps_sso_sdk/src/config/ui/bps_sso_color_scheme.dart';
import 'package:bps_sso_sdk/src/config/ui/bps_sso_custom_tab_config.dart';
import 'package:bps_sso_sdk/src/core/constants.dart';
import 'package:bps_sso_sdk/src/exceptions/exceptions.dart';
import 'package:bps_sso_sdk/src/security/bps_sso_security_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

/// Mixin providing Custom Tabs handling for BPS SSO service
mixin CustomTabsMixin {
  /// Get the SSO configuration
  BPSSsoConfig get config;

  /// Get the security manager
  BPSSsoSecurityManager get securityManager;

  /// Get the link stream for deep link handling
  Stream<String>? get linkStream;

  /// Close Custom Tabs only on iOS platform
  Future<void> closeCustomTabsIfIOS() async {
    try {
      if (Platform.isIOS) {
        await closeCustomTabs();
      }
    } on Exception catch (e) {
      debugPrint('Platform check failed, skipping closeCustomTabs: $e');
    }
  }

  /// Close Custom Tabs with configured delay and proper state management
  void scheduleCustomTabsClose() {
    unawaited(
      Future<void>.delayed(SecurityConstants.iOSTabCloseDelay).then((_) {
        return closeCustomTabsIfIOS();
      }),
    );
  }

  /// Show Chrome Custom Tabs for authentication and capture authorization code
  Future<String?> showCustomTabsAuth(
    BuildContext context,
    String authUrl,
    String expectedState,
    BPSRealmConfig realmConfig,
  ) async {
    StreamSubscription<dynamic>? linkSubscription;
    CustomTabsCancelObserver? cancelObserver;
    try {
      final completer = Completer<String?>();

      linkSubscription = linkStream?.listen((link) async {
        // Login already ended (cancel/timeout): a late deep link must not
        // re-complete it (StateError) or show an error snackbar.
        if (completer.isCompleted) {
          await linkSubscription?.cancel();
          return;
        }

        if (!securityManager.validateDeepLink(link, expectedState)) {
          await linkSubscription?.cancel();
          completer.complete(null);
          final sanitizedError = securityManager.sanitizeError(
            const SecurityException('Invalid deep link received'),
            isProduction: !config.errorConfig.enableDetailedErrorMessages,
          );
          showErrorSnackBar(context, getErrorMessage(sanitizedError));
          return;
        }

        final uri = Uri.parse(link);
        final redirectUri = realmConfig.redirectUri;

        if (uri.scheme == redirectUri.scheme && uri.host == redirectUri.host) {
          final code = uri.queryParameters['code'];
          final state = uri.queryParameters['state'];
          final error = uri.queryParameters['error'];

          await linkSubscription?.cancel();

          if (error != null) {
            completer.complete(null);
            scheduleCustomTabsClose();
            final sanitizedError = securityManager.sanitizeError(
              NetworkException('Authentication failed: $error'),
              isProduction: !config.errorConfig.enableDetailedErrorMessages,
            );
            showErrorSnackBar(context, getErrorMessage(sanitizedError));
            return;
          }

          if (code != null && state == expectedState) {
            completer.complete(code);
            scheduleCustomTabsClose();
          } else {
            completer.complete(null);
            scheduleCustomTabsClose();
            final sanitizedError = securityManager.sanitizeError(
              const InvalidStateException(),
              isProduction: !config.errorConfig.enableDetailedErrorMessages,
            );
            showErrorSnackBar(context, getErrorMessage(sanitizedError));
          }
        }
      });

      await launchUrl(
        Uri.parse(authUrl),
        customTabsOptions: buildCustomTabsOptions(),
        safariVCOptions: buildSafariOptions(),
      );

      // flutter_custom_tabs has no close event, so an app resume without a
      // deep link is treated as the user dismissing the tab.
      cancelObserver = CustomTabsCancelObserver(
        onCancelDetected: () {
          if (!completer.isCompleted) completer.complete(null);
        },
      );
      WidgetsBinding.instance.addObserver(cancelObserver);

      return await completer.future.timeout(
        config.authTimeout,
        onTimeout: () async {
          await linkSubscription?.cancel();
          scheduleCustomTabsClose();
          return null;
        },
      );
    } on Exception catch (e) {
      debugPrint('Custom Tabs auth failed: $e');
      scheduleCustomTabsClose();
      return null;
    } finally {
      await linkSubscription?.cancel();
      if (cancelObserver != null) {
        cancelObserver.dispose();
        WidgetsBinding.instance.removeObserver(cancelObserver);
      }
    }
  }

  /// Show error snackbar
  void showErrorSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Build Custom Tabs options from configuration
  CustomTabsOptions buildCustomTabsOptions() {
    final uiConfig = config.customTabsConfig;

    return CustomTabsOptions(
      colorSchemes: CustomTabsColorSchemes(
        defaultPrams: CustomTabsColorSchemeParams(
          toolbarColor: uiConfig.toolbarColor ?? const Color(0xFF1E3A8A),
          navigationBarColor: uiConfig.navigationBarColor,
        ),
        lightParams: _buildLightParams(uiConfig),
        darkParams: _buildDarkParams(uiConfig),
      ),
      shareState: uiConfig.enableDefaultShare
          ? CustomTabsShareState.on
          : CustomTabsShareState.off,
      urlBarHidingEnabled: uiConfig.enableUrlBarHiding,
      showTitle: uiConfig.showTitle,
      instantAppsEnabled: uiConfig.enableInstantApps,
    );
  }

  CustomTabsColorSchemeParams? _buildLightParams(
    BPSSsoCustomTabsConfig uiConfig,
  ) {
    if (!uiConfig.enableColorScheme ||
        uiConfig.colorScheme != BPSSsoColorScheme.light) {
      return null;
    }
    return CustomTabsColorSchemeParams(
      toolbarColor: uiConfig.toolbarColor ?? const Color(0xFF1E3A8A),
      navigationBarColor: uiConfig.navigationBarColor,
    );
  }

  CustomTabsColorSchemeParams? _buildDarkParams(
    BPSSsoCustomTabsConfig uiConfig,
  ) {
    if (!uiConfig.enableColorScheme ||
        uiConfig.colorScheme != BPSSsoColorScheme.dark) {
      return null;
    }
    return CustomTabsColorSchemeParams(
      toolbarColor: uiConfig.toolbarColor ?? const Color(0xFF0F172A),
      navigationBarColor:
          uiConfig.navigationBarColor ?? const Color(0xFF0F172A),
    );
  }

  /// Build Safari View Controller options from configuration
  SafariViewControllerOptions buildSafariOptions() {
    final uiConfig = config.customTabsConfig;

    return SafariViewControllerOptions(
      preferredBarTintColor: uiConfig.toolbarColor ?? const Color(0xFF1E3A8A),
      preferredControlTintColor: Colors.white,
      barCollapsingEnabled: uiConfig.enableUrlBarHiding,
      entersReaderIfAvailable: false,
      dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
    );
  }

  /// Get user-friendly error message from exception
  String getErrorMessage(Exception error) {
    final errorConfig = config.errorConfig;

    if (errorConfig.customErrorMessages.containsKey(error.runtimeType)) {
      return errorConfig.customErrorMessages[error.runtimeType]!;
    }

    if (error is AuthenticationCancelledException) {
      return 'Authentication was cancelled';
    } else if (error is NetworkException) {
      return 'Network connection failed. '
          'Please check your internet connection.';
    } else if (error is SecurityException) {
      return 'Security validation failed. Please try again.';
    } else if (error is InvalidStateException) {
      return 'Authentication security check failed. '
          'Please restart the login process.';
    } else {
      return 'Authentication failed. Please try again.';
    }
  }
}

/// Detects Custom Tabs / SFSafariViewController closing without a deep link
/// (back press, swipe away, iOS "Done") by watching the app lifecycle.
///
/// Launching the tab moves the host app out of `resumed`; returning to
/// `resumed` starts a 1.5 s grace timer before [onCancelDetected] fires.
/// The grace period exists because on Android the `resumed` event and the
/// deep-link delivery arrive in no fixed order; a successful deep link
/// completes the login first and the cancel callback becomes a no-op.
/// Leaving `resumed` again (system dialog, app switcher) cancels the timer.
@visibleForTesting
class CustomTabsCancelObserver with WidgetsBindingObserver {
  /// Creates an observer. The host may already be paused when this is
  /// attached (after `launchUrl`), so the current state is seeded here.
  CustomTabsCancelObserver({required this.onCancelDetected}) {
    _leftResumed = _isAway(WidgetsBinding.instance.lifecycleState);
  }

  /// Grace period between resume and the cancel callback.
  static const gracePeriod = Duration(milliseconds: 1500);

  /// Called once when a cancel is detected.
  final VoidCallback onCancelDetected;

  bool _leftResumed = false;
  bool _fired = false;
  Timer? _cancelTimer;

  static bool _isAway(AppLifecycleState? state) =>
      state == AppLifecycleState.inactive ||
      state == AppLifecycleState.paused ||
      state == AppLifecycleState.hidden;

  /// Cancels any pending cancel-detection timer.
  void dispose() {
    _cancelTimer?.cancel();
    _cancelTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_fired) return;
    if (_isAway(state)) {
      dispose();
      _leftResumed = true;
      return;
    }
    if (state == AppLifecycleState.resumed && _leftResumed) {
      _cancelTimer?.cancel();
      _cancelTimer = Timer(gracePeriod, () {
        _fired = true;
        onCancelDetected();
      });
    }
  }
}
