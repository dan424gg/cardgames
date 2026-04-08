import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// An animated chevron icon that rotates based on the expanded state.
class AnimatedChevron extends StatelessWidget {
  const AnimatedChevron({
    required this.expanded,
    this.size = 16.0,
    this.color = Colors.black,
    this.duration = AppAnimations.duration,
    this.curve = AppAnimations.curve,
    super.key,
  });

  final bool expanded;
  final double size;
  final Color color;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: expanded ? 0.25 : 0,
      duration: duration,
      curve: curve,
      child: Icon(Icons.arrow_forward_ios_sharp, size: size, color: color),
    );
  }
}
