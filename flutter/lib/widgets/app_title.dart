import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The app title widget shown in the root scaffold header.
class AppTitle extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double strokeWidth;

  const AppTitle({
    super.key,
    required this.text,
    required this.style,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: .center,
      children: [
        Text(
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
          text,
          style: style.copyWith(
            color: Colors.white,
            shadows: AppShadows.textLayered,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
