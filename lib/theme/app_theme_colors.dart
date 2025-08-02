import 'package:flutter/material.dart';

// =================================================================================
// App Color Constants
// =================================================================================

const Color kPrimaryColor = Color(0xFF0D47A1); // A deep, professional blue
const Color kSecondaryColor = Color(0xFF4CAF50); // A vibrant, clear green
const Color kBackgroundColor = Color(0xFFF0F0F0);
const Color kSurfaceColor = Colors.white;
const Color kErrorColor = Color(0xFFB00020); // Standard Material error red
const Color kBordersColor = Color(0xFFDCDCDC); // For borders and dividers

const Color kOnPrimaryColor = Colors.white;
const Color kOnSecondaryColor = Colors.white;
const Color kOnBackgroundColor = Color(0xFF212121); // Dark grey for text
const Color kOnSurfaceColor = Color(0xFF212121);
const Color kOnErrorColor = Colors.white;

// =================================================================================
// App ColorScheme
// =================================================================================

const ColorScheme kColorScheme = ColorScheme(
  primary: kPrimaryColor,
  secondary: kSecondaryColor,
  background: kBackgroundColor,
  surface: kSurfaceColor,
  error: kErrorColor,
  onPrimary: kOnPrimaryColor,
  onSecondary: kOnSecondaryColor,
  onBackground: kOnBackgroundColor,
  onSurface: kOnSurfaceColor,
  onError: kOnErrorColor,
  brightness: Brightness.light,
);
