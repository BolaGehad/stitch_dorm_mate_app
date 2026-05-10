import 'package:flutter/material.dart';

class AppTheme {
  // Core Colors
  static const Color surface = Color(0xFFF6FAFF);
  static const Color surfaceDim = Color(0xFFCFDCE7);
  static const Color primary = Color(0xFF006A62);
  static const Color primaryContainer = Color(0xFF2EC4B6);
  static const Color onSurface = Color(0xFF111D25);
  static const Color onSurfaceVariant = Color(0xFF3C4947);
  static const Color outline = Color(0xFF6C7A77);
  static const Color outlineVariant = Color(0xFFBBCAC6);
  static const Color surfaceContainerHighest = Color(0xFFD8E4F0);
  static const Color surfaceContainerHigh = Color(0xFFDDEAF5);
  static const Color surfaceContainerLow = Color(0xFFEBF5FF);
  static const Color surfaceContainer = Color(0xFFE3EFFB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF895100);
  static const Color secondaryContainer = Color(0xFFFD9D1A);
  static const Color tertiary = Color(0xFF5A5F62);
  static const Color tertiaryContainer = Color(0xFFACB1B4);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color onPrimaryContainer = Color(0xFF004C46);

  // Typography
  static const String fontFamily = 'Plus Jakarta Sans';

  // Pre-calculated opacities for const expressions
  static const Color outlineVariantOpacity15 = Color(0x26BBCAC6); // 15% opacity
  static const Color outlineVariantOpacity5 = Color(0x0DBBCAC6); // 5% opacity
  static const Color surfaceDimOpacity3 = Color(0x08CFDCE7); // 3% opacity
  static const Color surfaceDimOpacity2 = Color(0x05CFDCE7); // 2% opacity
  static const Color primaryContainerOpacity3 =
      Color(0x082EC4B6); // 3% opacity for grid
  static const Color primaryContainerOpacity12 =
      Color(0x1F2EC4B6); // 12% opacity
  static const Color primaryContainerOpacity20 =
      Color(0x332EC4B6); // 20% opacity
  static const Color primaryContainerOpacity40 =
      Color(0x662EC4B6); // 40% opacity
  static const Color primaryContainerOpacity8 = Color(0x142EC4B6); // 8% opacity
  static const Color primaryOpacity4 = Color(0x0A006A62); // 4% opacity
  static const Color primaryOpacity3 = Color(0x08006A62); // 3% opacity
  static const Color primaryOpacity2 = Color(0x05006A62); // 2% opacity
  static const Color onSurfaceVariantOpacity60 =
      Color(0x993C4947); // 60% opacity
  static const Color onSurfaceVariantOpacity40 =
      Color(0x663C4947); // 40% opacity
  static const Color secondaryOpacity10 = Color(0x1A895100); // 10% opacity
  static const Color primaryContainerOpacity10 =
      Color(0x1A2EC4B6); // 10% opacity
  static const Color secondaryContainerOpacity20 =
      Color(0x33FD9D1A); // 20% opacity
  static const Color primaryContainerOpacity30 =
      Color(0x4D2EC4B6); // 30% opacity
  static const Color primaryContainerOpacity60 =
      Color(0x992EC4B6); // 60% opacity
  static const Color primaryContainerOpacity80 =
      Color(0xCC2EC4B6); // 80% opacity

  static InputDecorationTheme _inputDecorationTheme(ColorScheme cs) {
    return InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(
        color: cs.onSurfaceVariant.withValues(alpha: 0.85),
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(
        color: cs.onSurfaceVariant,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      floatingLabelStyle: TextStyle(
        color: cs.primary,
        fontWeight: FontWeight.w600,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.error, width: 2),
      ),
      prefixIconColor: cs.outline,
      suffixIconColor: cs.outline,
    );
  }

  static final ColorScheme _lightColorScheme = ColorScheme.light(
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: secondary,
    secondaryContainer: secondaryContainer,
    surface: surface,
    onSurface: onSurface,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
    error: error,
    surfaceContainerHighest: surfaceContainerHighest,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainer: surfaceContainer,
    surfaceContainerLow: surfaceContainerLow,
    surfaceContainerLowest: surfaceContainerLowest,
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: surface,
    colorScheme: _lightColorScheme,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.56,
        color: onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.22,
        color: onSurface,
      ),
      bodyLarge: TextStyle(
          fontSize: 17, fontWeight: FontWeight.w400, color: onSurface),
      bodyMedium: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w400, color: onSurface),
      labelMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.65,
        color: outline,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: outline,
      ),
    ),
  ).copyWith(
    inputDecorationTheme: _inputDecorationTheme(_lightColorScheme),
  );

  /// Near-OLED dark base; teal tint matches brand primary.
  static const Color _darkSurface = Color(0xFF050807);
  static const Color _darkOnSurface = Color(0xFFE6EDEB);
  static const Color _darkOnSurfaceVariant = Color(0xFF9DAAA7);

  static final ColorScheme _darkColorScheme = ColorScheme.dark(
    brightness: Brightness.dark,
    primary: primaryContainer,
    onPrimary: Color(0xFF00332F),
    primaryContainer: Color(0xFF005048),
    onPrimaryContainer: Color(0xFF8CF4E8),
    secondary: secondaryContainer,
    onSecondary: Color(0xFF422C00),
    surface: _darkSurface,
    onSurface: _darkOnSurface,
    onSurfaceVariant: _darkOnSurfaceVariant,
    outline: Color(0xFF6F7A78),
    outlineVariant: Color(0xFF2A3331),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    surfaceContainerHighest: Color(0xFF1C2523),
    surfaceContainerHigh: Color(0xFF151D1B),
    surfaceContainer: Color(0xFF111917),
    surfaceContainerLow: Color(0xFF0C1211),
    surfaceContainerLowest: Color(0xFF080B0A),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: _darkSurface,
    colorScheme: _darkColorScheme,
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.56,
        color: _darkOnSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.22,
        color: _darkOnSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: _darkOnSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: _darkOnSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.65,
        color: _darkOnSurfaceVariant,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: _darkOnSurfaceVariant,
      ),
    ),
  ).copyWith(
    inputDecorationTheme: _inputDecorationTheme(_darkColorScheme),
  );

  /// Kept for compatibility; prefer [lightTheme].
  static ThemeData get themeData => lightTheme;

  // --- Dark-mode-aware helpers (prefer these over static light [surface] colors in UI) ---

  static Color schemeSurface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color schemeOnSurface(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color schemeOnSurfaceVariant(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  static Color schemeContainerLowest(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerLowest;

  static Color schemeContainerLow(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerLow;

  static Color schemeContainerHighest(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;

  static Color schemeOutlineVariant(BuildContext context) =>
      Theme.of(context).colorScheme.outlineVariant;

  static Color schemeOutline(BuildContext context) =>
      Theme.of(context).colorScheme.outline;

  static Color schemePrimary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  /// Blurred app bars / top bars
  static Color frostedBarBg(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Theme.of(context).brightness == Brightness.dark
        ? c.surfaceContainerHigh.withValues(alpha: 0.96)
        : c.surface.withValues(alpha: 0.88);
  }

  /// Bottom navigation glass strip
  static Color frostedBottomBarBg(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Theme.of(context).brightness == Brightness.dark
        ? c.surfaceContainerHigh.withValues(alpha: 0.98)
        : c.surface.withValues(alpha: 0.92);
  }

  /// Elevated cards / sheets (replaces raw [Colors.white] panels)
  static Color cardBackground(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerLowest;
}
