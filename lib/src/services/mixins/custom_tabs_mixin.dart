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
    try {
      final completer = Completer<String?>();
      StreamSubscription<dynamic>? linkSubscription;

      linkSubscription = linkStream?.listen((String link) async {
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
        final redirectUri = Uri.parse(realmConfig.redirectUri);

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

      return await completer.future.timeout(
        SecurityConstants.authTimeout,
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
