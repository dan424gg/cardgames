import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A back button used in sub-screen scaffold headers.
class BackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const BackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).pop(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.arrow_back,
          size: 18,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
