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
  });

  final Widget header;
  final Widget child;
  final bool isExpanded;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // invisible placeholder for size of header for spacing
        SizeHolder(child: header),

        // clip the top path so we get the in/out of view visual effect
        ClipPath(
          clipper: TopOnlyClipper(),
          child:
              // when not expanded, height of box goes to 0, producing the minimizing effect
              AnimatedAlign(
                alignment: Alignment.topCenter,
                heightFactor: isExpanded ? 1.0 : 0.0,
                duration: duration,
                curve: curve,
                child:
                    // when not expanded, child slides upward out (by a factor of it's own height)
                    AnimatedSlide(
                      offset: Offset(0, isExpanded ? 0.0 : -1.0),
                      duration: duration,
                      curve: curve,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizeHolder(child: header),
                          child,
                        ],
                      ),
                    ),
              ),
        ),
        header,
      ],
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
