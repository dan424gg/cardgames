import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'app_router.gr.dart'; // generated file
import '../theme/app_theme.dart';

enum SlideDirection { left, right, up, down }

extension SlideDirectionX on SlideDirection {
  Offset get offset {
    switch (this) {
      case SlideDirection.left:  return const Offset(-1.0, 0.0);
      case SlideDirection.right: return const Offset(1.0, 0.0);
      case SlideDirection.up:    return const Offset(0.0, -1.0);
      case SlideDirection.down:  return const Offset(0.0, 1.0);
    }
  }

  SlideDirection get opposite {
    switch (this) {
      case SlideDirection.left:  return SlideDirection.right;
      case SlideDirection.right: return SlideDirection.left;
      case SlideDirection.up:    return SlideDirection.down;
      case SlideDirection.down:  return SlideDirection.up;
    }
  }
}

@AutoRouterConfig()
class AppRouter extends $AppRouter {
  static Widget _buildSlideTransition({
    required SlideDirection direction,
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
      begin: direction.offset,
      end: Offset.zero,
    ).animate(curvedAnimation);

    final slideOutAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: direction.opposite.offset,
    ).animate(curvedSecondaryAnimation);

    return SlideTransition(
      position: slideOutAnimation,
      child: SlideTransition(position: slideInAnimation, child: child),
    );
  }

  @override
  List<AutoRoute> get routes => [
    CustomRoute(
      path: '/',
      page: Home.page,
      durationInMilliseconds: AppAnimations.duration.inMilliseconds,
      reverseDurationInMilliseconds: AppAnimations.duration.inMilliseconds,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildSlideTransition(
          direction: SlideDirection.right,
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
          direction: SlideDirection.right,
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
          direction: SlideDirection.right,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    ),
    CustomRoute(
      path: '/emailsignup',
      page: EmailSignUp.page,
      durationInMilliseconds: AppAnimations.duration.inMilliseconds,
      reverseDurationInMilliseconds: AppAnimations.duration.inMilliseconds,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildSlideTransition(
          direction: SlideDirection.right,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    ),
  ];
}