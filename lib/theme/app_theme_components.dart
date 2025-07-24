import 'package:flutter/material.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/theme/app_theme_typography.dart';

// =================================================================================
// App Component Themes
// =================================================================================

// --- ElevatedButton Theme ---
final ElevatedButtonThemeData kElevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: kPrimaryColor,
    foregroundColor: kOnPrimaryColor,
    textStyle: kTextTheme.labelLarge,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
  ),
);

// --- InputDecoration Theme for TextFields ---
const InputDecorationTheme kInputDecorationTheme = InputDecorationTheme(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: kPrimaryColor),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
  ),
  contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
);

// --- Card Theme ---
const CardThemeData kCardTheme = CardThemeData(
  elevation: 1.0,
  margin: EdgeInsets.all(8.0),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
    side: BorderSide(color: Color(0xFFE0E0E0)), // Light grey border for cards
  ),
);
