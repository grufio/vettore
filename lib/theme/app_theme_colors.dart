import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;
import 'package:macos_ui/macos_ui.dart';

// =================================================================================
// App Color Constants
// =================================================================================

const Color kPrimaryColor = Color(0xFF0D47A1); // A deep, professional blue
const Color kSecondaryColor = Color(0xFF28a745); // A vibrant, clear green
// Buttons
const Color kButtonColor = Color(0xFF646464);
const Color kWhite = Color(0xFFFFFFFF);
// Deprecated: use kWhite directly. Keeping for now to avoid breaking import
const Color kErrorColor = Color(0xFFdc3545); // A standard error red
const Color kBordersColor = Color(0xFFDCDCDC); // For borders and dividers

const Color kOnBackgroundColor = Color(0xFF212121); // Dark grey for text
const Color kOnSurfaceColor = Color(0xFF212121);

// Explicit black for text where true black is desired
const Color kBlack = Color(0xFF000000);

// =================================================================================
// Main App Theme
// =================================================================================

/// A macOS theme that uses the custom colors from your theme.
final MacosThemeData appTheme = MacosThemeData(
  brightness: ui.Brightness.light,
  primaryColor: kPrimaryColor,
  canvasColor: kWhite,
  dividerColor: kBordersColor,
  typography: MacosTypography(
    color: kBlack,
    body: const TextStyle(color: kBlack),
    title1: const TextStyle(
      color: kBlack,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    title2: const TextStyle(
      color: kBlack,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    title3: const TextStyle(
      color: kBlack,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
  ),
  pushButtonTheme: const PushButtonThemeData(
    color: kPrimaryColor,
    secondaryColor: kSecondaryColor,
  ),
);

// =================================================================================
// Header/Tab Colors (centralized for reuse)
// =================================================================================

// Titlebar/header background and divider
const Color kHeaderBackgroundColor = Color(0xFFF0F0F0);
const Color kHeaderDividerColor = kBordersColor;

// Tab colors
const Color kTabTextColor = kOnBackgroundColor;
const Color kTabTextColorInactive = Color(0xFF7D7D7D);
const Color kTabBackgroundActive = kWhite;
const Color kTabBackgroundInactive = Color(0xFFF0F0F0);
const Color kTabBackgroundHover = Color(0xFFDCDCDC);
const Color kTabCloseHoverBackground =
    Color(0xFFBFBFBF); // TabsIcon.create hover bg
const Color kTransparent = Color(0x00000000);
