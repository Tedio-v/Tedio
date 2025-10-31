import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.brand,
      onPrimary: Colors.white,
      secondary: AppColors.link,
      onSecondary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      background: AppColors.background,
      onBackground: AppColors.brand,
      surface: AppColors.surface,
      onSurface: AppColors.brand,
      tertiary: AppColors.accentMint,
      onTertiary: AppColors.brand,
      outline: AppColors.brand.withOpacity(0.12),
    );

    final textTheme = AppTypography.buildTextTheme(colorScheme);
    final subtleBorder = BorderSide(color: AppColors.brand.withOpacity(0.12));
    final focusBorder = BorderSide(color: AppColors.link, width: 1.4);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.brand,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.brand(fontSize: 28),
        iconTheme: const IconThemeData(color: AppColors.brand),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: subtleBorder,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.accentMint,
        labelStyle: textTheme.labelMedium?.copyWith(color: AppColors.brand),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: subtleBorder,
        ),
        selectedColor: AppColors.accentSlate,
        secondarySelectedColor: AppColors.accentRose,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.link,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brand,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
          side: subtleBorder,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.link,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        labelStyle: textTheme.labelLarge?.copyWith(color: AppColors.muted),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.muted.withOpacity(0.7)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: subtleBorder,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: subtleBorder,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: focusBorder,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.4),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.brand.withOpacity(0.08),
        space: 24,
        thickness: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.muted,
        textColor: AppColors.brand,
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: AppColors.surface,
        selectedColor: AppColors.link,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.link,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.link,
        unselectedItemColor: AppColors.muted,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.brand,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        actionTextColor: AppColors.accentMint,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.link,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.hovered)
              ? AppColors.brand.withOpacity(0.4)
              : AppColors.brand.withOpacity(0.24),
        ),
      ),
    );
  }
}
