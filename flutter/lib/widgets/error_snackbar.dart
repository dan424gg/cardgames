import 'package:app/widgets/icon_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import '../theme/app_theme.dart';

SnackBar errorSnackBar({
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
}) {
  return SnackBar(
    content: Row(
      spacing: AppSpacing.spacing,
      children: [
        IconBox(
          icon: SFIcons.sf_exclamationmark_triangle,
          backgroundColor: AppColors.iconBackgroundColor,
        ),
        Expanded(
          child: Text(message, style: AppTextStyles.label, softWrap: true),
        ),
      ],
    ),
    backgroundColor: Colors.red.shade200,
    behavior: .floating,
    duration: duration,
    action: actionLabel != null
        ? SnackBarAction(label: actionLabel, onPressed: onAction ?? () {})
        : null,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppContainerConstraints.borderRadius),
    ),
  );
}

/// Helper function to show an error snackbar
void showErrorSnackBar(
  BuildContext context, {
  required String message,
  String? actionLabel = "OK",
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    errorSnackBar(
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    ),
  );
}
