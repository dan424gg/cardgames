import 'package:flutter/material.dart';

/// A widget that maintains the size of its child while keeping it invisible.
/// Useful for reserving space in layout without displaying the content.
class SizeHolder extends StatelessWidget {
  const SizeHolder({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ExcludeFocus(
      excluding: true,
      child: IgnorePointer(child: Opacity(opacity: 0, child: child)),
    );
  }
}
