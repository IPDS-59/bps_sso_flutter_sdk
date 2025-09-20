import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

enum BPSSsoColorScheme {
  light,
  dark,
  system;

  CustomTabsColorScheme get customTabColorScheme => switch (this) {
    light => CustomTabsColorScheme.light,
    dark => CustomTabsColorScheme.dark,
    system => CustomTabsColorScheme.system,
  };
}
