import 'package:flutter/material.dart';

class AppSpacing {
  static const double spacing = 10.0;
  static const double padding = 20.0;
}

class AppColors {
  static const primary = Color(0xFFD7EDD7);
  static const secondary = Color(0xFFFFFFFF);
  static const tertiary = Color(0xFFC6C6C8);
  static const background = Color(0xFFF0F7F0);
  static const bad = Color(0xFFF4DBD4);
  static const teamA = Color(0xFFD4E8F4);
  static const teamB = Color(0xFFF4D4E8);
  static const teamAAccent = Color(0xFF4A90D9);
  static const teamBAccent = Color(0xFFD94A90);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B6B6B);
  static const divider = Color(0xFFE0E0E0);
  static const toggleActive = Color(0xFF4CAF50);
}

class AppTextStyles {
  static const _base = TextStyle(
    fontFamily: 'LuckiestGuy',
    color: AppColors.textPrimary,
  );

  static final title = _base.copyWith(fontSize: 28, letterSpacing: 1.5);
  static final pageTitle = _base.copyWith(fontSize: 22, letterSpacing: 1.2);
  static final sectionHeader = _base.copyWith(fontSize: 14, letterSpacing: 1.0);

  static const body = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w500,
  );

  static const bodySmall = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w400,
  );

  static const label = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 13,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w600,
  );
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.secondary,
        ),
        fontFamily: 'Nunito',
      );
}
