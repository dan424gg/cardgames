import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The primary full-width button (e.g. "Join Game", "Ready", "Start Game").
class MainButton extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? colorOverride;
  final VoidCallback? onTap;
  final bool isLoading;

  const MainButton({
    super.key,
    required this.title,
    this.icon,
    this.colorOverride,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = colorOverride ?? AppColors.primary;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: bg.withValues(alpha: 0.4),
              offset: const Offset(0, 3),
              blurRadius: 8,
            ),
          ],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textPrimary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: AppColors.textPrimary),
                    const SizedBox(width: 8),
                  ],
                  Text(title,
                      style: AppTextStyles.label.copyWith(fontSize: 15)),
                ],
              ),
      ),
    );
  }
}

/// Compact sub-button for secondary actions inside a dropdown or list.
///
/// [showArrow] indicates navigation; otherwise acts as a toggle/action.
class SubButton extends StatelessWidget {
  final String title;
  final IconData? icon;
  final bool showArrow;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SubButton({
    super.key,
    required this.title,
    this.icon,
    this.showArrow = true,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(title, style: AppTextStyles.label),
            ),
            trailing ??
                (showArrow
                    ? const Icon(Icons.chevron_right,
                        size: 16, color: AppColors.textSecondary)
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
