import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A reusable expand/collapse wrapper.
///
/// Owns all dropdown state and layout. Pass any header widget via
/// [headerBuilder] — it receives the current [expanded] flag so the
/// header can react visually (e.g. rotate a chevron). The [onTap]
/// callback for toggling is handled internally; an optional
/// [onExpandedChanged] lets callers observe state changes.
///
/// Example — wrapping a plain tile:
/// ```dart
/// ExpandableSection(
///   headerBuilder: (expanded) => MyTile(expanded: expanded),
///   children: [ChildA(), ChildB()],
/// )
/// ```
class ExpandableSection extends StatefulWidget {
  /// Builds the always-visible header row.
  /// Receives [expanded] so the header can animate (e.g. rotate a chevron).
  final Widget Function(bool expanded) headerBuilder;

  /// Widgets shown below the header when expanded.
  final List<Widget> children;

  /// Corner radius applied to the children panel clip.
  final double borderRadius;

  /// Width fraction for the children panel relative to the header.
  /// Defaults to 0.85 to produce the indented cascade look.
  final double childrenWidthFactor;

  /// Whether the section starts expanded.
  final bool initiallyExpanded;

  /// Called whenever the section is toggled, with the new expanded state.
  final ValueChanged<bool>? onExpandedChanged;

  const ExpandableSection({
    super.key,
    required this.headerBuilder,
    required this.children,
    this.borderRadius = 12,
    this.childrenWidthFactor = 0.85,
    this.initiallyExpanded = false,
    this.onExpandedChanged,
  });

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    widget.onExpandedChanged?.call(_expanded);
  }

  @override
  Widget build(BuildContext context) {
    // The Stack keeps the header at its natural size while allowing the
    // children panel to "overflow" downward beneath it without pushing
    // sibling widgets. The invisible Visibility clone reserves the space.
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Space-holder — keeps the column height stable so the floating
            // header above it doesn't collapse the Stack.
            Visibility(
              visible: false,
              maintainSize: true,
              maintainState: true,
              maintainAnimation: true,
              child: widget.headerBuilder(_expanded),
            ),
            if (_expanded) _buildChildrenPanel(),
          ],
        ),
        // Floating header — sits on top and responds to taps.
        GestureDetector(
          onTap: _toggle,
          child: widget.headerBuilder(_expanded),
        ),
      ],
    );
  }

  Widget _buildChildrenPanel() {
    final children = widget.children;
    final items = <Widget>[
      // Thick top divider visually separates header from children.
      Divider(height: 2, color: AppColors.secondary, thickness: 2),
      for (int i = 0; i < children.length; i++) ...[
        children[i],
        if (i < children.length - 1)
          const Divider(height: 1, color: AppColors.tertiary, thickness: 1),
      ],
    ];

    return FractionallySizedBox(
      widthFactor: widget.childrenWidthFactor,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(widget.borderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items,
        ),
      ),
    );
  }
}