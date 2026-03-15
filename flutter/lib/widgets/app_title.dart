import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The app title widget shown in the root scaffold header.
class AppTitle extends StatelessWidget {
  final String text;

  const AppTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.title,
    );
  }
}

/// The page title widget shown in sub-screen scaffold headers.
class PageTitle extends StatelessWidget {
  final String text;

  const PageTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.pageTitle,
    );
  }
}
