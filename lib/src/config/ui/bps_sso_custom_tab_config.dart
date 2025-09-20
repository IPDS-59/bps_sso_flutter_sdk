import 'package:bps_sso_sdk/src/config/config.dart';
import 'package:flutter/material.dart';

/// UI configuration for Chrome Custom Tabs
class BPSSsoCustomTabsConfig {
  const BPSSsoCustomTabsConfig({
    this.toolbarColor,
    this.navigationBarColor,
    this.enableUrlBarHiding = false,
    this.enableDefaultShare = false,
    this.enableInstantApps = false,
    this.showTitle = true,
    this.closeButtonIcon,
    this.startAnimations,
    this.exitAnimations,
    this.enableColorScheme = true,
    this.colorScheme = BPSSsoColorScheme.system,
    this.customMenuItems = const [],
    this.headers = const {},
    this.enableBookmarks = false,
    this.enableDownloads = false,
  });

  /// Primary color for the Chrome Custom Tab toolbar
  /// If null, uses the app's primary color
  final Color? toolbarColor;

  /// Color for the navigation bar (Android only)
  /// If null, uses system default
  final Color? navigationBarColor;

  /// Whether to enable URL bar hiding when scrolling
  final bool enableUrlBarHiding;

  /// Whether to show the default share action
  final bool enableDefaultShare;

  /// Whether to enable instant apps (Android only)
  final bool enableInstantApps;

  /// Whether to show the page title in the toolbar
  final bool showTitle;

  /// Custom close button icon
  /// If null, uses the default back arrow
  final Widget? closeButtonIcon;

  /// Custom animations for opening the tab (Android only)
  /// [enter_animation_res, exit_animation_res]
  final List<int>? startAnimations;

  /// Custom animations for closing the tab (Android only)
  /// [enter_animation_res, exit_animation_res]
  final List<int>? exitAnimations;

  /// Whether to enable color scheme matching
  final bool enableColorScheme;

  /// Color scheme preference for the custom tab
  final BPSSsoColorScheme colorScheme;

  /// Custom menu items to add to the overflow menu
  final List<CustomTabMenuItem> customMenuItems;

  /// Additional headers to send with requests
  final Map<String, String> headers;

  /// Whether to enable bookmarks functionality
  final bool enableBookmarks;

  /// Whether to enable downloads functionality
  final bool enableDownloads;

  /// Create a copy with modified values
  BPSSsoCustomTabsConfig copyWith({
    Color? toolbarColor,
    Color? navigationBarColor,
    bool? enableUrlBarHiding,
    bool? enableDefaultShare,
    bool? enableInstantApps,
    bool? showTitle,
    Widget? closeButtonIcon,
    List<int>? startAnimations,
    List<int>? exitAnimations,
    bool? enableColorScheme,
    BPSSsoColorScheme? colorScheme,
    List<CustomTabMenuItem>? customMenuItems,
    Map<String, String>? headers,
    bool? enableBookmarks,
    bool? enableDownloads,
  }) => BPSSsoCustomTabsConfig(
    toolbarColor: toolbarColor ?? this.toolbarColor,
    navigationBarColor: navigationBarColor ?? this.navigationBarColor,
    enableUrlBarHiding: enableUrlBarHiding ?? this.enableUrlBarHiding,
    enableDefaultShare: enableDefaultShare ?? this.enableDefaultShare,
    enableInstantApps: enableInstantApps ?? this.enableInstantApps,
    showTitle: showTitle ?? this.showTitle,
    closeButtonIcon: closeButtonIcon ?? this.closeButtonIcon,
    startAnimations: startAnimations ?? this.startAnimations,
    exitAnimations: exitAnimations ?? this.exitAnimations,
    enableColorScheme: enableColorScheme ?? this.enableColorScheme,
    colorScheme: colorScheme ?? this.colorScheme,
    customMenuItems: customMenuItems ?? this.customMenuItems,
    headers: headers ?? this.headers,
    enableBookmarks: enableBookmarks ?? this.enableBookmarks,
    enableDownloads: enableDownloads ?? this.enableDownloads,
  );
}
