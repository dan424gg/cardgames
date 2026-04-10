import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'app_router.gr.dart'; // generated file
import '../theme/app_theme.dart';

@AutoRouterConfig() // tells AutoRoute this is the central navigation config
class AppRouter extends $AppRouter {
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
        // Apply curve to both animations
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AppAnimations.curve,
        );
        final curvedSecondaryAnimation = CurvedAnimation(
          parent: secondaryAnimation,
          curve: AppAnimations.curve,
        );

        // When entering: slide in from left
        final slideInAnimation = Tween<Offset>(
          begin: const Offset(-1.0, 0.0),
          end: Offset.zero,
        ).animate(curvedAnimation);

        // When exiting (pushed by another route): slide out to left
        final slideOutAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-1.0, 0.0),
        ).animate(curvedSecondaryAnimation);

        return SlideTransition(
          position: slideOutAnimation,
          child: SlideTransition(position: slideInAnimation, child: child),
        );
      },
    ),
    CustomRoute(
      path: '/settings',
      page: Settings.page,
      durationInMilliseconds: AppAnimations.duration.inMilliseconds,
      reverseDurationInMilliseconds: AppAnimations.duration.inMilliseconds,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Apply curve to both animations
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AppAnimations.curve,
        );
        final curvedSecondaryAnimation = CurvedAnimation(
          parent: secondaryAnimation,
          curve: AppAnimations.curve,
        );

        // When entering: slide in from right
        final slideInAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(curvedAnimation);

        // When exiting (pushed by another route): slide out to right
        final slideOutAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(1.0, 0.0),
        ).animate(curvedSecondaryAnimation);

        return SlideTransition(
          position: slideOutAnimation,
          child: SlideTransition(position: slideInAnimation, child: child),
        );
      },
    ),
  ];
}
