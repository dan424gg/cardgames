import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_title.dart';
import 'back_button.dart' as cards;

/// Standard page scaffold used across all screens.
///
/// - Root screens: show [AppTitle] on the left, optional trailing action on right.
/// - Sub-screens: show [BackButton] on the left, [PageTitle] in the center.
class AppScaffold extends StatelessWidget {
  final String title;
  final bool isRoot;
  final Widget body;
  final Widget? trailing;
  final VoidCallback? onBack;
  final EdgeInsets? bodyPadding;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.isRoot = false,
    this.trailing,
    this.onBack,
    this.bodyPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildNavBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: bodyPadding ??
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    if (isRoot) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            AppTitle(text: title),
            const Spacer(),
            if (trailing != null) trailing!,
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: cards.BackButton(onTap: onBack),
          ),
          PageTitle(text: title),
          if (trailing != null)
            Align(alignment: Alignment.centerRight, child: trailing!),
        ],
      ),
    );
  }
}
