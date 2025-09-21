import 'package:auto_route/auto_route.dart';
import 'package:bps_sso_sdk/bps_sso_sdk.dart';
import 'package:flutter/material.dart';

import '../screens/configuration_screen.dart';
import '../screens/home_screen.dart';
import '../screens/operations_screen.dart';
import '../screens/user_info_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, path: '/', initial: true),
    AutoRoute(page: ConfigurationRoute.page, path: '/config'),
    AutoRoute(page: OperationsRoute.page, path: '/operations'),
    AutoRoute(page: UserInfoRoute.page, path: '/user-info'),
    // Deep link route for OAuth callback - redirect to operations screen
    // The SDK will handle the actual callback processing via app_links stream
    RedirectRoute(path: '/callback', redirectTo: '/operations'),
  ];
}
