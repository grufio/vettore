import 'package:flutter/material.dart';
import 'package:vettore/theme/app_theme_colors.dart';

// =================================================================================
// App TextTheme
// =================================================================================

const TextTheme kTextTheme = TextTheme(
  // For large headlines
  headlineLarge: TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    color: kOnBackgroundColor,
    letterSpacing: 1.2,
  ),
  // For standard titles (e.g., AppBar)
  titleLarge: TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    color: kOnSurfaceColor,
  ),
  // For main body text
  bodyLarge: TextStyle(
    fontSize: 16.0,
    color: kOnBackgroundColor,
  ),
  // For smaller body text or captions
  bodyMedium: TextStyle(
    fontSize: 14.0,
    color: kOnBackgroundColor,
  ),
  // For buttons
  labelLarge: TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: kOnPrimaryColor,
  ),
);
