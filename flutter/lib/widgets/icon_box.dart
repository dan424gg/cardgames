import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class IconBox extends StatelessWidget {
  final Color? backgroundColor;
  final IconData icon;

  const IconBox({super.key, required this.icon, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: AppColors.textPrimary),
    );
  }
}
