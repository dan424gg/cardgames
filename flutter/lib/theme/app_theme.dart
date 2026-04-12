import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  static const double spacing = 15.0;
  static const double padding = 20.0;
}

class AppShadows {
  static const List<BoxShadow> boxLayered = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, .15),
      offset: const Offset(-1, 2),
      blurRadius: 4,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, .15),
      offset: const Offset(1, 2),
      blurRadius: 4,
    ),
  ];

  static const List<Shadow> textLayered = [
    Shadow(
      color: Color.fromRGBO(0, 0, 0, .15),
      offset: const Offset(-1, 2),
      blurRadius: 4,
    ),
    Shadow(
      color: Color.fromRGBO(0, 0, 0, .15),
      offset: const Offset(1, 2),
      blurRadius: 4,
    ),
  ];
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
  static const divider = Color(0xC6C6C8C8);
  static const toggleActive = Color(0xFF4CAF50);
  static const iconBackgroundColor = Color.fromRGBO(255, 255, 255, 0.6);
}

class AppTextStyles {
  static final _base = GoogleFonts.luckiestGuy(
    color: AppColors.textPrimary,
    height: 1.0,
  );

  static final title = _base.copyWith(fontSize: 60, letterSpacing: 1.5);
  static final pageTitle = _base.copyWith(fontSize: 35, letterSpacing: 1.2);
  static final sectionHeader = _base.copyWith(fontSize: 14, letterSpacing: 1.0);

  static final body = GoogleFonts.inter(
    fontSize: 16,
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w400,
  );

  static final bodySmall = GoogleFonts.inter(
    fontSize: 12,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w400,
  );

  static final label = GoogleFonts.inter(
    fontSize: 16,
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
    textTheme: TextTheme(
      bodyMedium: GoogleFonts.inter(),
      bodySmall: GoogleFonts.inter(),
      labelLarge: GoogleFonts.inter(),
    ),
  );
}

class AppAnimations {
  static const duration = Duration(milliseconds: 600);
  static const curve = Curves.easeInOut;
}

class AppContainerConstraints {
  static const double borderRadius = 12;
}
