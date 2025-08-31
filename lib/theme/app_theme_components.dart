import 'package:flutter/material.dart';
import 'package:vettore/theme/app_theme_colors.dart';

// =================================================================================
// App Component Themes
// =================================================================================

// (Removed) ElevatedButton Theme - will be set locally in widgets as needed.

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
  // --- Sizing and Alignment ---
  isDense: true, // Reduces vertical padding
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
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
