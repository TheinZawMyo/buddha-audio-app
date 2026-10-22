import 'package:flutter/material.dart';

/// Design tokens from architecture.md §8 (saffron/ochre palette).
abstract final class AppColors {
  static const primary = Color(0xFFB96A2C);
  static const dark = Color(0xFF70401F);
  static const background = Color(0xFFFFF8EE);
  static const text = Color(0xFF28231F);

  static const primaryContainer = Color(0xFFF6DFC8);
  static const onPrimaryContainer = Color(0xFF5A3214);
  static const surface = Color(0xFFFFFDF8);
  static const surfaceVariant = Color(0xFFF4E6D3);
  static const outline = Color(0xFFE3D2BC);
  static const mutedText = Color(0xFF7A6A5B);

  // Player (dark saffron)
  static const playerBackgroundTop = Color(0xFF8A4E24);
  static const playerBackgroundBottom = Color(0xFF3F2411);
  static const playerSurface = Color(0x33FFFFFF);
  static const playerText = Color(0xFFFFF6EA);
  static const playerMuted = Color(0xCCF0DCC4);
}

abstract final class AppTheme {
  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );

    final scheme = base.copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.dark,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: AppColors.surface,
      surfaceContainer: AppColors.surfaceVariant,
      surfaceContainerHigh: AppColors.surfaceVariant,
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.mutedText,
      outline: AppColors.outline,
      outlineVariant: AppColors.outline,
      error: const Color(0xFFB3261E),
      onError: Colors.white,
    );

    final textTheme = Typography.englishLike2021
        .apply(
          bodyColor: AppColors.text,
          displayColor: AppColors.text,
        )
        .copyWith(
          headlineMedium: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          titleLarge: const TextStyle(fontWeight: FontWeight.w700),
          titleMedium: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
          bodyMedium: const TextStyle(height: 1.4),
          labelLarge: const TextStyle(fontWeight: FontWeight.w600),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium?.copyWith(
          fontSize: 22,
          color: AppColors.primary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: .06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.outline, width: .8),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primaryContainer,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: AppColors.text,
        ),
        side: const BorderSide(color: AppColors.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        showCheckmark: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        height: 66,
        indicatorColor: AppColors.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11.5,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.dark
                : AppColors.mutedText,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.dark
                : AppColors.mutedText,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.dark,
          minimumSize: const Size(0, 48),
          side: const BorderSide(color: AppColors.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      sliderTheme: const SliderThemeData(
        trackHeight: 4,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
        inactiveTrackColor: AppColors.outline,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.mutedText),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        space: 1,
        thickness: .8,
      ),
      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.dark,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
