import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class DarkTheme {
  const DarkTheme._();

  static ThemeData get theme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryYellow,
      onPrimary: AppColors.blackStroke,
      secondary: AppColors.pink,
      onSecondary: AppColors.blackStroke,
      tertiary: AppColors.mintGreen,
      onTertiary: AppColors.blackStroke,
      error: AppColors.dangerRed,
      onError: AppColors.whiteCard,
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkCard,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.darkText,
          fontSize: 34,
          fontWeight: FontWeight.w900,
        ),
        headlineMedium: TextStyle(
          color: AppColors.darkText,
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
        titleLarge: TextStyle(
          color: AppColors.darkText,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
        titleMedium: TextStyle(
          color: AppColors.darkText,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        bodyLarge: TextStyle(
          color: AppColors.darkText,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(
          color: AppColors.darkMutedText,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.md,
        ),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(width: 4),
        errorBorder: _border(color: AppColors.dangerRed),
        focusedErrorBorder: _border(color: AppColors.dangerRed, width: 4),
        labelStyle: const TextStyle(
          color: AppColors.darkText,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  static OutlineInputBorder _border({
    Color color = AppColors.blackStroke,
    double width = AppSizes.brutalBorder,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.brutalRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
