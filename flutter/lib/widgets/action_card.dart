import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum ActionCardVariant { navigate, dropdown, toggle, action }

/// The core card component used throughout the app.
///
/// Supports four behavioral variants:
/// - [ActionCardVariant.navigate] → shows a `>` chevron, calls [onTap] on tap
/// - [ActionCardVariant.dropdown] → shows a `∨/∧` chevron, expands [children] inline
/// - [ActionCardVariant.toggle] → shows a Switch, calls [onToggle] on change
/// - [ActionCardVariant.action] → plain card, calls [onTap] on tap (no trailing icon)
class ActionCard extends StatefulWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String title;
  final String? subtitle;
  final Color backgroundColor;
  final ActionCardVariant variant;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;
  final bool toggleValue;
  final List<Widget>? children;
  final Widget? trailing;
  final Color? iconBackgroundColor;
  final List<BoxShadow>? boxShadow;

  const ActionCard({
    super.key,
    this.icon,
    this.iconWidget,
    required this.title,
    this.subtitle,
    this.backgroundColor = AppColors.secondary,
    this.variant = ActionCardVariant.navigate,
    this.onTap,
    this.onToggle,
    this.toggleValue = false,
    this.children,
    this.trailing,
    this.iconBackgroundColor,
    this.boxShadow,
  });

  /// Convenience: destructive/bad variant (e.g. Sign Out)
  factory ActionCard.bad({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) =>
      ActionCard(
        icon: icon,
        title: title,
        backgroundColor: AppColors.bad,
        variant: ActionCardVariant.navigate,
        onTap: onTap,
      );

  @override
  State<ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMainRow(),
        if (widget.variant == ActionCardVariant.dropdown && _expanded)
          _buildDropdownChildren(),
      ],
    );
  }

  Widget _buildMainRow() {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: _expanded
              ? const BorderRadius.vertical(top: Radius.circular(12))
              : BorderRadius.circular(12),
          boxShadow: widget.boxShadow,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            if (widget.iconWidget != null) ...[
              widget.iconWidget!,
              const SizedBox(width: 10),
            ] else if (widget.icon != null) ...[
              _buildIconBox(),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.title, style: AppTextStyles.label),
                  if (widget.subtitle != null)
                    Text(widget.subtitle!, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            _buildTrailing(),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBox() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: widget.iconBackgroundColor ??
            AppColors.primary.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(widget.icon, size: 22, color: AppColors.textPrimary),
    );
  }

  Widget _buildTrailing() {
    if (widget.trailing != null) return widget.trailing!;

    switch (widget.variant) {
      case ActionCardVariant.navigate:
        return const Icon(Icons.chevron_right,
            size: 18, color: AppColors.textSecondary);

      case ActionCardVariant.dropdown:
        return AnimatedRotation(
          turns: _expanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 200),
          child: const Icon(Icons.keyboard_arrow_down,
              size: 18, color: AppColors.textSecondary),
        );

      case ActionCardVariant.toggle:
        return Transform.scale(
          scale: 0.8,
          child: Switch(
            value: widget.toggleValue,
            onChanged: widget.onToggle,
            activeThumbColor: AppColors.toggleActive,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );

      case ActionCardVariant.action:
        return const SizedBox.shrink();
    }
  }

  void _handleTap() {
    if (widget.variant == ActionCardVariant.dropdown) {
      setState(() => _expanded = !_expanded);
    } else if (widget.variant == ActionCardVariant.navigate ||
        widget.variant == ActionCardVariant.action) {
      widget.onTap?.call();
    }
  }

  Widget _buildDropdownChildren() {
    final children = widget.children ?? [];
    final childrenWithDividers = <Widget>[];

    for (int i = 0; i < children.length; i++) {
      childrenWithDividers.add(children[i]);
      if (i < children.length - 1) {
        childrenWithDividers.add(
          const Divider(
            height: 1,
            color: AppColors.tertiary,
            thickness: 1,
          ),
        );
      }
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: childrenWithDividers,
      ),
    );
  }
}
