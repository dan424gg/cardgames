// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:app/screens/home.dart' as _i1;
import 'package:app/screens/settings.dart' as _i2;
import 'package:auto_route/auto_route.dart' as _i3;

abstract class $AppRouter extends _i3.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i3.PageFactory> pagesMap = {
    Home.name: (routeData) {
      return _i3.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.HomeScreen(),
      );
    },
    Settings.name: (routeData) {
      return _i3.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.SettingsScreen(),
      );
    },
  };
}

/// generated route for
/// [_i1.HomeScreen]
class Home extends _i3.PageRouteInfo<void> {
  const Home({List<_i3.PageRouteInfo>? children})
      : super(
          Home.name,
          initialChildren: children,
        );

  static const String name = 'Home';

  static const _i3.PageInfo<void> page = _i3.PageInfo<void>(name);
}

/// generated route for
/// [_i2.SettingsScreen]
class Settings extends _i3.PageRouteInfo<void> {
  const Settings({List<_i3.PageRouteInfo>? children})
      : super(
          Settings.name,
          initialChildren: children,
        );

  static const String name = 'Settings';

  static const _i3.PageInfo<void> page = _i3.PageInfo<void>(name);
}
