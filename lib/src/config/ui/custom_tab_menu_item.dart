import 'package:flutter/services.dart';

/// Custom menu item for Chrome Custom Tabs overflow menu
class CustomTabMenuItem {
  const CustomTabMenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.id,
  });

  /// Display title for the menu item
  final String title;

  /// Icon for the menu item (Android resource ID)
  final int icon;

  /// Callback when the menu item is tapped
  final VoidCallback onTap;

  /// Optional unique identifier
  final String? id;
}
