import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF8F5F1);
  static const Color textMain = Color(0xFF262626);
  static const Color textSecondary = Color(0xFF7A7A7A);

  static const Color buttonDark = Color(0xFF4C2A15);
  static const Color buttonOrange = Color(0xFFFF7215);

  static const Color peachCard = Color(0xFFFFDFCA);
  static const Color peachCardText = Color(0xFF4C2A15);

  static const Color habitBgOrange = Color(0xFFFFDBBD);
  static const Color habitIconOrange = Color(0xFFF37B31);

  static const Color habitBgGreen = Color(0xFFD6ECC3);
  static const Color habitIconGreen = Color(0xFF7C9A43);

  static const Color habitBgPink = Color(0xFFFFD5F0);
  static const Color habitIconPink = Color(0xFFDF76C7);

  static const Color chartWalking = Color(0xFF4C2A15);
  static const Color chartRunning = Color(0xFFB55B27);
  static const Color chartMeditation = Color(0xFF86A539);
  static const Color chartDrink = Color(0xFFDF76C7);
  static const Color chartBgStripes = Color(0xFFEBE6DF);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Urbanist',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.textMain),
        bodyMedium: TextStyle(color: AppColors.textMain),
        displayLarge: TextStyle(color: AppColors.textMain),
        displayMedium: TextStyle(color: AppColors.textMain),
        displaySmall: TextStyle(color: AppColors.textMain),
        headlineMedium: TextStyle(color: AppColors.textMain),
        headlineSmall: TextStyle(color: AppColors.textMain),
        titleLarge: TextStyle(color: AppColors.textMain),
        titleMedium: TextStyle(color: AppColors.textMain),
        titleSmall: TextStyle(color: AppColors.textMain),
        bodySmall: TextStyle(color: AppColors.textMain),
        labelLarge: TextStyle(color: AppColors.textMain),
        labelSmall: TextStyle(color: AppColors.textMain),
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.buttonOrange,
        background: AppColors.background,
      ),
    );
  }
}
