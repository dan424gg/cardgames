import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'app_router.gr.dart'; // generated file
import '../theme/app_theme.dart';

@AutoRouterConfig() // tells AutoRoute this is the central navigation config
class AppRouter extends $AppRouter {
  // Helper method to reduce boilerplate for slide transitions
  static Widget _buildSlideTransition({
    required Offset slideDirection,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: AppAnimations.curve,
    );
    final curvedSecondaryAnimation = CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppAnimations.curve,
    );

    final slideInAnimation = Tween<Offset>(
      begin: slideDirection,
      end: Offset.zero,
    ).animate(curvedAnimation);

    final slideOutAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: slideDirection,
    ).animate(curvedSecondaryAnimation);

    return SlideTransition(
      position: slideOutAnimation,
      child: SlideTransition(position: slideInAnimation, child: child),
    );
  }

  // list of routes to be used
  @override
  List<AutoRoute> get routes => [
    // [screen].page only becomes available when widget is annotated with @RoutePage (using code-gen)
    CustomRoute(
      path: '/',
      page: Home.page,
      durationInMilliseconds: AppAnimations.duration.inMilliseconds,
      reverseDurationInMilliseconds: AppAnimations.duration.inMilliseconds,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildSlideTransition(
          slideDirection: const Offset(-1.0, 0.0),
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    ),
    CustomRoute(
      path: '/settings',
      page: Settings.page,
      durationInMilliseconds: AppAnimations.duration.inMilliseconds,
      reverseDurationInMilliseconds: AppAnimations.duration.inMilliseconds,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildSlideTransition(
          slideDirection: const Offset(1.0, 0.0),
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    ),
    CustomRoute(
      path: '/joingame',
      page: JoinGame.page,
      durationInMilliseconds: AppAnimations.duration.inMilliseconds,
      reverseDurationInMilliseconds: AppAnimations.duration.inMilliseconds,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildSlideTransition(
          slideDirection: const Offset(1.0, 0.0),
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    ),
  ];
}
