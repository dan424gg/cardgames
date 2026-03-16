import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BaseCard extends StatefulWidget {
  final IconData? icon;
  final dynamic trailingIcon;
  final Color? iconBackgroundColor;
  final String title;
  final String? subtitle;
  final Color backgroundColor;
  final List<BoxShadow>? boxShadow;
  final double borderRadius;

  const BaseCard({
    super.key,
    this.icon,
    this.trailingIcon,
    required this.title,
    this.subtitle,
    this.backgroundColor = AppColors.secondary,
    this.iconBackgroundColor,
    this.boxShadow,
    this.borderRadius = 12,
  });

  @override
  State<BaseCard> createState() => _BaseCardState();
}

class _BaseCardState extends State<BaseCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: widget.boxShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          if (widget.icon != null) ...[
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
          if (widget.trailingIcon is Widget)
            widget.trailingIcon
          else
            Icon(widget.trailingIcon, size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildIconBox() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color:
            widget.iconBackgroundColor ??
            AppColors.primary.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(widget.icon, size: 14, color: AppColors.textPrimary),
    );
  }
}
