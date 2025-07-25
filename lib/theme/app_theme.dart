import 'package:flutter/material.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/theme/app_theme_components.dart';
import 'package:vettore/theme/app_theme_typography.dart';

// =================================================================================
// Main App Theme
// =================================================================================

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: kColorScheme,
  textTheme: kTextTheme,

  // Component Themes
  elevatedButtonTheme: kElevatedButtonTheme,
  inputDecorationTheme: kInputDecorationTheme,
  cardTheme: kCardTheme,

  // Global Properties
  scaffoldBackgroundColor: kBackgroundColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: kPrimaryColor,
    foregroundColor: kOnPrimaryColor,
  ),
);
