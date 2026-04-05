// widgets/animated_expandable.dart

import 'package:flutter/material.dart';
import 'package:app/theme/app_theme.dart';

class AnimatedExpandable extends StatelessWidget {
  const AnimatedExpandable({
    super.key,
    required this.header,
    required this.child,
    required this.isExpanded,
    this.duration = AppAnimations.duration,
    this.curve = AppAnimations.curve,
    this.bottomPadding = AppSpacing.spacing,
  });

  final Widget header;
  final Widget child;
  final bool isExpanded;
  final Duration duration;
  final Curve curve;
  final double bottomPadding;

  static const Duration defaultDuration = Duration(milliseconds: 500);
  static const Curve defaultCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Reserves the header's space so the Stack is tall enough
        _SizeHolder(child: header),
        ClipRRect(
          child: AnimatedAlign(
            alignment: Alignment.topCenter,
            heightFactor: isExpanded ? 1.0 : 0.0,
            duration: duration,
            curve: curve,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SizeHolder(child: header),
                Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: child,
                ),
              ],
            ),
          ),
        ), // The real interactive header always sits on top
        header,
      ],
    );
  }
}

class _SizeHolder extends StatelessWidget {
  const _SizeHolder({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: false,
      maintainSize: true,
      maintainState: true,
      maintainAnimation: true,
      child: child,
    );
  }
}
