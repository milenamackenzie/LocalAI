import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_theme_extension.dart';

class AppTheme {
  // Brand Colors (Green-Blue / Teal focus)
  static const Color primaryLight = Color(0xFF00696D);
  static const Color primaryContainerLight = Color(0xFF6FF6FB);
  static const Color secondaryLight = Color(0xFF4A6364);

  static const Color primaryDark = Color(0xFF4CD9DF);
  static const Color primaryContainerDark = Color(0xFF004F52);
  static const Color secondaryDark = Color(0xFFB1CBCD);

  static ThemeData light() {
    return FlexThemeData.light(
      colors: const FlexSchemeColor(
        primary: primaryLight,
        primaryContainer: primaryContainerLight,
        secondary: secondaryLight,
        secondaryContainer: Color(0xFFCCE8E9),
        tertiary: Color(0xFF4E6078),
        tertiaryContainer: Color(0xFFD6E3FF),
        appBarColor: Color(0xFFCCE8E9),
        error: Color(0xFFBA1A1A),
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 12.0,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyColors: true,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    ).copyWith(
      extensions: [
        CustomThemeExtension(
          cardGradient: LinearGradient(
            colors: [primaryLight.withOpacity(0.1), secondaryLight.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          successColor: const Color(0xFF2E7D32),
          warningColor: const Color(0xFFF57C00),
        ),
      ],
    );
  }

  static ThemeData dark() {
    return FlexThemeData.dark(
      colors: const FlexSchemeColor(
        primary: primaryDark,
        primaryContainer: primaryContainerDark,
        secondary: secondaryDark,
        secondaryContainer: Color(0xFF324B4C),
        tertiary: Color(0xFFB6C8E8),
        tertiaryContainer: Color(0xFF36485F),
        appBarColor: Color(0xFF324B4C),
        error: Color(0xFFFFB4AB),
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 12.0,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyColors: true,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    ).copyWith(
      extensions: [
        CustomThemeExtension(
          cardGradient: LinearGradient(
            colors: [primaryDark.withOpacity(0.2), secondaryDark.withOpacity(0.2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          successColor: const Color(0xFF81C784),
          warningColor: const Color(0xFFFFB74D),
        ),
      ],
    );
  }
}
