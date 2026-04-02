import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0052D9);
  static const Color primaryColorLight = Color(0xFF4080FF);
  static const Color successColor = Color(0xFF2BA471);
  static const Color warningColor = Color(0xFFE37318);
  static const Color errorColor = Color(0xFFD54941);
  static const Color accentColor = Color(0xFFFF6B35);

  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF0052D9), Color(0xFF4080FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const cardGradient = LinearGradient(
    colors: [Color(0xFF0052D9), Color(0xFF4080FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const _subThemes = FlexSubThemesData(
    interactionEffects: true,
    tintedDisabledControls: true,
    blendOnLevel: 10,
    useTextTheme: true,
    useM2StyleDividerInM3: true,
    alignedDropdown: true,
    useInputDecoratorThemeInDialogs: true,
    inputDecoratorBorderType: FlexInputBorderType.outline,
    inputDecoratorRadius: 12.0,
    inputDecoratorUnfocusedHasBorder: false,
    inputDecoratorFocusedHasBorder: true,
    inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
    inputDecoratorBackgroundAlpha: 21,
    fabRadius: 16.0,
    fabSchemeColor: SchemeColor.primary,
    chipRadius: 12.0,
    cardRadius: 16.0,
    cardElevation: 0.5,
    filledButtonRadius: 12.0,
    elevatedButtonRadius: 12.0,
    outlinedButtonRadius: 12.0,
    segmentedButtonRadius: 12.0,
    segmentedButtonSchemeColor: SchemeColor.primary,
    dialogRadius: 20.0,
    snackBarRadius: 12.0,
    snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
    navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
    navigationBarSelectedIconSchemeColor: SchemeColor.onPrimaryContainer,
    navigationBarIndicatorSchemeColor: SchemeColor.primaryContainer,
    navigationBarIndicatorOpacity: 1.0,
    navigationBarElevation: 2.0,
    navigationBarHeight: 72.0,
  );

  static ThemeData lightTheme = FlexThemeData.light(
    colors: const FlexSchemeColor(
      primary: Color(0xFF0052D9),
      primaryContainer: Color(0xFFDAE2FF),
      secondary: Color(0xFF2BA471),
      secondaryContainer: Color(0xFFB8F5D8),
      tertiary: Color(0xFFFF6B35),
      tertiaryContainer: Color(0xFFFFDBC8),
      error: Color(0xFFD54941),
    ),
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 7,
    subThemesData: _subThemes,
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    textTheme: GoogleFonts.notoSansScTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    ),
    primaryTextTheme: GoogleFonts.notoSansScTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    ),
  );

  static ThemeData darkTheme = FlexThemeData.dark(
    colors: const FlexSchemeColor(
      primary: Color(0xFF9ECAFF),
      primaryContainer: Color(0xFF003FA7),
      secondary: Color(0xFF6DDBAC),
      secondaryContainer: Color(0xFF005237),
      tertiary: Color(0xFFFFB694),
      tertiaryContainer: Color(0xFF802D00),
      error: Color(0xFFFFB4AB),
    ),
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 13,
    subThemesData: _subThemes.copyWith(
      inputDecoratorBackgroundAlpha: 43,
      blendOnLevel: 20,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    textTheme: GoogleFonts.notoSansScTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ),
    primaryTextTheme: GoogleFonts.notoSansScTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    ),
  );
}
