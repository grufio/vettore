import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;
import 'package:macos_ui/macos_ui.dart';

// =================================================================================
// App Color Constants
// =================================================================================

const Color kPrimaryColor = Color(0xFF0D47A1); // A deep, professional blue
const Color kSecondaryColor = Color(0xFF28a745); // A vibrant, clear green
const Color kBackgroundColor = Color(0xFFFFFFFF);
const Color kSurfaceColor = Color(0xFFFFFFFF);
const Color kErrorColor = Color(0xFFdc3545); // A standard error red
const Color kBordersColor = Color(0xFFDCDCDC); // For borders and dividers

const Color kOnPrimaryColor = Color(0xFFFFFFFF);
const Color kOnSecondaryColor = Color(0xFFFFFFFF);
const Color kOnBackgroundColor = Color(0xFF212121); // Dark grey for text
const Color kOnSurfaceColor = Color(0xFF212121);
const Color kOnErrorColor = Color(0xFFFFFFFF);

// =================================================================================
// Main App Theme
// =================================================================================

/// A macOS theme that uses the custom colors from your theme.
final MacosThemeData appTheme = MacosThemeData(
  brightness: ui.Brightness.light,
  primaryColor: kPrimaryColor,
  canvasColor: kBackgroundColor,
  dividerColor: kBordersColor,
  typography: MacosTypography(
    color: kOnBackgroundColor, // This was the missing parameter
    body: const TextStyle(color: kOnBackgroundColor),
    title1: const TextStyle(
      color: kOnBackgroundColor,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    title2: const TextStyle(
      color: kOnBackgroundColor,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    title3: const TextStyle(
      color: kOnBackgroundColor,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
  ),
  pushButtonTheme: const PushButtonThemeData(
    color: kPrimaryColor,
    secondaryColor: kSecondaryColor,
  ),
);
