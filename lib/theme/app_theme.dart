import 'package:flutter/material.dart';

/// Central design tokens for Maritime Watch.
/// Deep navy/ocean blues with sky-blue accents, on a dark hull background —
/// mirrors official maritime chart colours, with white used for clarity
/// and trust (Marine Department branding).
class AppColors {
  AppColors._();

  static const navy = Color(0xFF04101E);
  static const deep = Color(0xFF091E36);
  static const ocean = Color(0xFF0D3561);
  static const blue = Color(0xFF1565C0);
  static const sky = Color(0xFF2196F3);
  static const wave = Color(0xFF42A5F5);
  static const mist = Color(0xFFBBDEFB);
  static const white = Color(0xFFFFFFFF);

  static const danger = Color(0xFFE53935);
  static const warn = Color(0xFFF57C00);
  static const ok = Color(0xFF43A047);

  static const dim = Color(0x85FFFFFF); // ~52% white
  static const dimmer = Color(0x47FFFFFF); // ~28% white
  static const cardBg = Color(0x0EFFFFFF); // ~5.5% white
  static const cardBorder = Color(0x17FFFFFF); // ~9% white

  static const gradientPrimary = LinearGradient(
    colors: [sky, blue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const gradientCover = LinearGradient(
    colors: [Color.fromARGB(255, 34, 79, 216), navy, Color(0xFF020C16)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.65, 1.0],
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.navy,

      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.sky,
        secondary: AppColors.wave,
        surface: AppColors.deep,
        error: AppColors.danger,
      ),

      textTheme: base.textTheme.apply(
        bodyColor: AppColors.white,
        displayColor: AppColors.white,
        fontFamily: 'Inter',
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.deep,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
        iconTheme: IconThemeData(color: AppColors.white),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x0FFFFFFF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.cardBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.cardBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.sky,
            width: 1.5,
          ),
        ),
        hintStyle: const TextStyle(
          color: AppColors.dimmer,
          fontFamily: 'Inter',
        ),
        labelStyle: const TextStyle(
          color: AppColors.wave,
          fontFamily: 'Inter',
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sky,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.deep,
        selectedItemColor: AppColors.wave,
        unselectedItemColor: AppColors.dimmer,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}