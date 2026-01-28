import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blue,
        brightness: Brightness.light,
      ),
    );

    // Use IBM Plex Sans KR for Korean support, fallback to Noto Sans KR
    // Apply Korean font to text theme
    final koreanFont = base.textTheme.apply(
      fontFamily: GoogleFonts.ibmPlexSansKr().fontFamily ?? GoogleFonts.notoSansKr().fontFamily,
    );
    
    final koreanTheme = koreanFont.copyWith(
      displayLarge: koreanFont.displayLarge?.copyWith(
        fontWeight: FontWeight.w900,
        color: AppColors.text,
        fontSize: 64,
        letterSpacing: -1.5,
      ),
      displayMedium: koreanFont.displayMedium?.copyWith(
        fontWeight: FontWeight.w900,
        color: AppColors.text,
        fontSize: 48,
        letterSpacing: -1.0,
      ),
      displaySmall: koreanFont.displaySmall?.copyWith(
        fontWeight: FontWeight.w900,
        color: AppColors.text,
        fontSize: 40,
        letterSpacing: -1.0,
      ),
      headlineLarge: koreanFont.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
      headlineMedium: koreanFont.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
      headlineSmall: koreanFont.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
      titleLarge: koreanFont.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
      titleMedium: koreanFont.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
      titleSmall: koreanFont.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      bodyLarge: koreanFont.bodyLarge?.copyWith(
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      ),
      bodyMedium: koreanFont.bodyMedium?.copyWith(
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      ),
      bodySmall: koreanFont.bodySmall?.copyWith(
        fontWeight: FontWeight.w400,
        color: AppColors.subText,
      ),
      labelLarge: koreanFont.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      labelMedium: koreanFont.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
      labelSmall: koreanFont.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.subText,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      textTheme: koreanTheme,
    );
  }
}

