import 'package:flutter/material.dart';

class AppColors {
  static const appBackground = Color(0xFFFAFAF8);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSoft = Color(0xFFF4F4F2);
  static const surfacePressed = Color(0xFFEDEDEA);
  static const photoPlaceholder = Color(0xFFECECEA);
  static const textPrimary = Color(0xFF111111);
  static const textSecondary = Color(0xFF666666);
  static const textMuted = Color(0xFFA0A0A0);
  static const line = Color(0xFFE7E7E4);
  static const lineStrong = Color(0xFFD4D4D0);
  static const actionPrimary = Color(0xFF111111);
  static const actionPrimaryText = Color(0xFFFFFFFF);
  static const actionSecondary = Color(0xFFFFFFFF);
  static const actionSecondaryText = Color(0xFF111111);
  static const profileAccent = Color(0xFFC9151B);
  static const warningAccent = Color(0xFFD8A868);
  static const lowScoreAccent = Color(0xFF9B3A34);
  static const subtleAccent = Color(0xFFB8A27A);
  static const cameraBackdrop = Color(0xFF161616);
  static const overlayPanel = Color(0xEEFFFFFF);
  static const warmTile = Color(0xFFD8A868);
  static const coolTile = Color(0xFF87A7B7);
  static const moodTile = Color(0xFF886E84);
}

class AppMetrics {
  static const pagePadding = 20.0;
  static const sectionSpacing = 24.0;
  static const gridGap = 8.0;
  static const thumbnailRadius = 8.0;
  static const panelRadius = 10.0;
  static const buttonRadius = 8.0;
  static const buttonHeight = 46.0;
  static const bottomNavHeight = 64.0;
  static const thinBorder = 1.0;
  static const selectedOutline = 1.4;
}

class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.actionPrimary,
      brightness: Brightness.light,
      surface: AppColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.appBackground,
      colorScheme: colorScheme.copyWith(
        primary: AppColors.actionPrimary,
        secondary: AppColors.subtleAccent,
        error: AppColors.lowScoreAccent,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 25,
          fontWeight: FontWeight.w700,
          height: 1.18,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.25,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.3,
          letterSpacing: 0,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          height: 1.45,
          letterSpacing: 0,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          height: 1.42,
          letterSpacing: 0,
        ),
        bodySmall: TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          height: 1.35,
          letterSpacing: 0,
        ),
        labelLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        labelSmall: TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.appBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: AppMetrics.thinBorder,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.appBackground,
        selectedColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: Colors.transparent,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
