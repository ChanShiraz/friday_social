import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color surface = Color(0xFFFCF9F2);
  static const Color background = Color(0xFFFCF9F2);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF6F3EC);
  static const Color surfaceContainer = Color(0xFFF1EEE7);
  static const Color surfaceContainerHigh = Color(0xFFEBE8E1);
  static const Color surfaceContainerHighest = Color(0xFFE5E2DB);

  static const Color primary = Color(0xFF1C1C18);
  static const Color primaryContainer = Color(0xFF1C1B1A);
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color secondary = Color(0xFFA23E18);
  static const Color secondaryContainer = Color(0xFFFE8357);
  static const Color secondaryFixed = Color(0xFFFFDBCF);

  static const Color onSurface = Color(0xFF1C1C18);
  static const Color onSurfaceVariant = Color(0xFF4A4640);
  static const Color outline = Color(0xFF7B766F);
  static const Color outlineVariant = Color(0xFFCCC6BD);

  static const Color onTertiaryContainer = Color(0xFF73859F);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        surface: AppColors.surface,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        onSurface: AppColors.onSurface,
        onPrimary: AppColors.onPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.newsreader(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.newsreader(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
          letterSpacing: -0.3,
        ),
        headlineSmall: GoogleFonts.newsreader(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
          letterSpacing: -0.2,
        ),
        bodyLarge: GoogleFonts.hankenGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurface,
          letterSpacing: -0.1,
        ),
        bodyMedium: GoogleFonts.hankenGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurfaceVariant,
        ),
        bodySmall: GoogleFonts.hankenGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.hankenGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.hankenGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        labelSmall: GoogleFonts.hankenGrotesk(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
