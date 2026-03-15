import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A labeled section with an icon header and a list of child cards.
///
/// Children are rendered with 4px gaps between them and a rounded
/// container wrapping the whole group.
class Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color headerColor;
  final List<Widget> children;
  final Widget? footer;

  const Section({
    super.key,
    required this.icon,
    required this.title,
    this.headerColor = AppColors.primary,
    required this.children,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          decoration: BoxDecoration(
            color: headerColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.sectionHeader),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Children
        ...children.map(
          (child) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: child,
          ),
        ),
        if (footer != null) ...[
          const SizedBox(height: 2),
          footer!,
        ],
      ],
    );
  }
}

/// The "+ Add Bots" footer button used in player list sections.
class AddBotsButton extends StatelessWidget {
  final VoidCallback? onTap;

  const AddBotsButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text('Add Bots', style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
