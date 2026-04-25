// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:app/screens/email_sign_up.dart' as _i1;
import 'package:app/screens/home.dart' as _i2;
import 'package:app/screens/join_game.dart' as _i3;
import 'package:app/screens/settings.dart' as _i4;
import 'package:auto_route/auto_route.dart' as _i5;

abstract class $AppRouter extends _i5.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i5.PageFactory> pagesMap = {
    EmailSignUp.name: (routeData) {
      return _i5.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.EmailSignUp(),
      );
    },
    Home.name: (routeData) {
      return _i5.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.HomeScreen(),
      );
    },
    JoinGame.name: (routeData) {
      return _i5.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.JoinGameScreen(),
      );
    },
    Settings.name: (routeData) {
      return _i5.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.SettingsScreen(),
      );
    },
  };
}

/// generated route for
/// [_i1.EmailSignUp]
class EmailSignUp extends _i5.PageRouteInfo<void> {
  const EmailSignUp({List<_i5.PageRouteInfo>? children})
      : super(
          EmailSignUp.name,
          initialChildren: children,
        );

  static const String name = 'EmailSignUp';

  static const _i5.PageInfo<void> page = _i5.PageInfo<void>(name);
}

/// generated route for
/// [_i2.HomeScreen]
class Home extends _i5.PageRouteInfo<void> {
  const Home({List<_i5.PageRouteInfo>? children})
      : super(
          Home.name,
          initialChildren: children,
        );

  static const String name = 'Home';

  static const _i5.PageInfo<void> page = _i5.PageInfo<void>(name);
}

/// generated route for
/// [_i3.JoinGameScreen]
class JoinGame extends _i5.PageRouteInfo<void> {
  const JoinGame({List<_i5.PageRouteInfo>? children})
      : super(
          JoinGame.name,
          initialChildren: children,
        );

  static const String name = 'JoinGame';

  static const _i5.PageInfo<void> page = _i5.PageInfo<void>(name);
}

/// generated route for
/// [_i4.SettingsScreen]
class Settings extends _i5.PageRouteInfo<void> {
  const Settings({List<_i5.PageRouteInfo>? children})
      : super(
          Settings.name,
          initialChildren: children,
        );

  static const String name = 'Settings';

  static const _i5.PageInfo<void> page = _i5.PageInfo<void>(name);
}
