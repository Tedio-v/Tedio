import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextTheme buildTextTheme(ColorScheme colorScheme) {
    final base = ThemeData.light().textTheme;
    final lexendTheme = GoogleFonts.lexendTextTheme(base).apply(
      bodyColor: colorScheme.onBackground,
      displayColor: colorScheme.onBackground,
    );

    return lexendTheme.copyWith(
      displayLarge: lexendTheme.displayLarge?.copyWith(fontWeight: FontWeight.w700),
      displayMedium: lexendTheme.displayMedium?.copyWith(fontWeight: FontWeight.w700),
      displaySmall: lexendTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
      headlineLarge: lexendTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium: lexendTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      headlineSmall: lexendTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: lexendTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: lexendTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: lexendTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: GoogleFonts.poppins(
        textStyle: base.labelLarge,
        fontWeight: FontWeight.w700,
        color: colorScheme.onPrimary,
        letterSpacing: 0.2,
      ),
      labelMedium: GoogleFonts.poppins(
        textStyle: base.labelMedium,
        fontWeight: FontWeight.w600,
        color: colorScheme.onPrimary,
        letterSpacing: 0.1,
      ),
      labelSmall: GoogleFonts.poppins(
        textStyle: base.labelSmall,
        fontWeight: FontWeight.w600,
        color: colorScheme.onPrimary,
      ),
      bodyLarge: lexendTheme.bodyLarge?.copyWith(height: 1.4),
      bodyMedium: lexendTheme.bodyMedium?.copyWith(height: 1.4),
      bodySmall: lexendTheme.bodySmall?.copyWith(height: 1.4, color: AppColors.muted),
    );
  }

  static TextStyle brand({
    Color color = AppColors.brand,
    double fontSize = 28,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return GoogleFonts.balooThambi2(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: -0.4,
    );
  }
}
