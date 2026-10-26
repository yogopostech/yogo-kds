import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _primary         = Color(0xFFFF6B2C);
  static const _primaryDark     = Color(0xFFFF8C55);
  static const _secondary       = Color(0xFF1A73E8);
  static const _secondaryDark   = Color(0xFF4D94FF);

  static ThemeData get light => FlexThemeData.light(
        colors: const FlexSchemeColor(
          primary:            _primary,
          primaryContainer:   Color(0xFFFFDBC8),
          secondary:          _secondary,
          secondaryContainer: Color(0xFFD3E3FD),
          tertiary:           Color(0xFF4CAF50),
          tertiaryContainer:  Color(0xFFC8E6C9),
        ),
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 7,
        appBarStyle: FlexAppBarStyle.background,
        useMaterial3: true,
        fontFamily: 'Inter',
        subThemesData: const FlexSubThemesData(
          cardRadius: 12,
          inputDecoratorRadius: 10,
          elevatedButtonRadius: 10,
          chipRadius: 8,
          tabBarIndicatorWeight: 3,
          tabBarIndicatorTopRadius: 2,
        ),
      );

  static ThemeData get dark => FlexThemeData.dark(
        colors: const FlexSchemeColor(
          primary:            _primaryDark,
          primaryContainer:   Color(0xFF7A3010),
          secondary:          _secondaryDark,
          secondaryContainer: Color(0xFF1A3A6E),
          tertiary:           Color(0xFF66BB6A),
          tertiaryContainer:  Color(0xFF1B5E20),
        ),
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        appBarStyle: FlexAppBarStyle.background,
        useMaterial3: true,
        fontFamily: 'Inter',
        subThemesData: const FlexSubThemesData(
          cardRadius: 12,
          inputDecoratorRadius: 10,
          elevatedButtonRadius: 10,
          chipRadius: 8,
          tabBarIndicatorWeight: 3,
          tabBarIndicatorTopRadius: 2,
        ),
      );
}
