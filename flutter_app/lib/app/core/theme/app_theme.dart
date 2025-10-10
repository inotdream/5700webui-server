import 'package:flutter/material.dart';

class AppTheme {
  // TDesign/Ant Design 主题色
  static const primaryColor = Color(0xFF0052D9); // TDesign 蓝色
  static const primaryColorLight = Color(0xFF4080FF); // 浅蓝色
  static const primaryColorDark = Color(0xFF0034B5); // 深蓝色
  static const secondaryColor = Color(0xFF00A870); // 绿色
  static const accentColor = Color(0xFFFF6B35); // 橙色
  static const warningColor = Color(0xFFE37318); // 警告色
  static const errorColor = Color(0xFFD54941); // 错误色
  static const successColor = Color(0xFF00A870); // 成功色
  
  // 渐变色
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF0052D9), Color(0xFF0034B5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const cardGradient = LinearGradient(
    colors: [Color(0xFF0052D9), Color(0xFF4080FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 亮色主题
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      primaryContainer: primaryColorLight,
      secondary: secondaryColor,
      surface: const Color(0xFFFFFFFF),
      background: const Color(0xFFF5F7FA),
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF1F2937),
      onBackground: const Color(0xFF1F2937),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    cardTheme: CardThemeData(
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF1F2937),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return const Color(0xFFE5E7EB);
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor.withOpacity(0.3);
        }
        return const Color(0xFFE5E7EB);
      }),
    ),
  );

  // 暗色主题
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryColorLight,
      primaryContainer: primaryColorDark,
      secondary: secondaryColor,
      surface: const Color(0xFF1F2937),
      background: const Color(0xFF111827),
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFFF9FAFB),
      onBackground: const Color(0xFFF9FAFB),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF111827),
    cardTheme: CardThemeData(
      elevation: 2,
      color: const Color(0xFF1F2937),
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFFF9FAFB),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColorLight,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColorLight;
        }
        return const Color(0xFF4B5563);
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColorLight.withOpacity(0.3);
        }
        return const Color(0xFF4B5563);
      }),
    ),
  );

  // 卡片阴影
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: primaryColor.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // 深色模式卡片阴影
  static List<BoxShadow> cardShadowDark = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}

