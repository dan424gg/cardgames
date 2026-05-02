// widgets/animated_expandable.dart

import 'package:flutter/material.dart';
import 'package:app/theme/app_theme.dart';
import 'size_holder.dart';

class AnimatedExpandable extends StatelessWidget {
  const AnimatedExpandable({
    super.key,
    required this.header,
    required this.child,
    required this.isExpanded,
    this.duration = AppAnimations.duration,
    this.curve = AppAnimations.curve,
    this.reverse = false,
  });

  final Widget header;
  final Widget child;
  final bool isExpanded;
  final Duration duration;
  final Curve curve;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    final expandedContent = ClipPath(
      clipper: reverse ? BottomOnlyClipper() : TopOnlyClipper(),
      child: AnimatedAlign(
        alignment: reverse ? Alignment.bottomCenter : Alignment.topCenter,
        heightFactor: isExpanded ? 1.0 : 0.0,
        duration: duration,
        curve: curve,
        child: AnimatedSlide(
          offset: Offset(
            0,
            isExpanded
                ? 0.0
                : reverse
                ? 1.0
                : -1.0,
          ),
          duration: duration,
          curve: curve,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: reverse
                ? [child, SizeHolder(child: header)]
                : [SizeHolder(child: header), child],
          ),
        ),
      ),
    );

    return Stack(
      alignment: reverse ? Alignment.bottomCenter : Alignment.topCenter,
      children: reverse
          ? [SizeHolder(child: header), expandedContent, header]
          : [SizeHolder(child: header), expandedContent, header],
    );
  }
}

class TopOnlyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(-1000, 0);
    path.lineTo(size.width + 1000, 0);
    path.lineTo(size.width + 1000, size.height + 1000);
    path.lineTo(-1000, size.height + 1000);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BottomOnlyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(-1000, -1000);
    path.lineTo(size.width + 1000, -1000);
    path.lineTo(size.width + 1000, size.height);
    path.lineTo(-1000, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
