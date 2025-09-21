// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [ConfigurationScreen]
class ConfigurationRoute extends PageRouteInfo<void> {
  const ConfigurationRoute({List<PageRouteInfo>? children})
    : super(ConfigurationRoute.name, initialChildren: children);

  static const String name = 'ConfigurationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ConfigurationScreen();
    },
  );
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreen();
    },
  );
}

/// generated route for
/// [OperationsScreen]
class OperationsRoute extends PageRouteInfo<void> {
  const OperationsRoute({List<PageRouteInfo>? children})
    : super(OperationsRoute.name, initialChildren: children);

  static const String name = 'OperationsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OperationsScreen();
    },
  );
}

/// generated route for
/// [UserInfoScreen]
class UserInfoRoute extends PageRouteInfo<UserInfoRouteArgs> {
  UserInfoRoute({
    Key? key,
    required BPSUser user,
    List<PageRouteInfo>? children,
  }) : super(
         UserInfoRoute.name,
         args: UserInfoRouteArgs(key: key, user: user),
         initialChildren: children,
       );

  static const String name = 'UserInfoRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserInfoRouteArgs>();
      return UserInfoScreen(key: args.key, user: args.user);
    },
  );
}

class UserInfoRouteArgs {
  const UserInfoRouteArgs({this.key, required this.user});

  final Key? key;

  final BPSUser user;

  @override
  String toString() {
    return 'UserInfoRouteArgs{key: $key, user: $user}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UserInfoRouteArgs) return false;
    return key == other.key && user == other.user;
  }

  @override
  int get hashCode => key.hashCode ^ user.hashCode;
}
