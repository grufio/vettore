import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:vettore/theme/app_theme_colors.dart';

// =================================================================================
// Main App Theme
// =================================================================================

/// A macOS theme that uses the custom colors from your theme.
final MacosThemeData appTheme = MacosThemeData.light().copyWith(
  primaryColor: kPrimaryColor,
  canvasColor: kBackgroundColor,
  dividerColor: kBordersColor,
  typography: MacosTypography(
    color: kTextBlackColor,
    body: const TextStyle(color: kTextBlackColor),
    title1: const TextStyle(
      color: kTextBlackColor,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    title2: const TextStyle(
      color: kTextBlackColor,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    title3: const TextStyle(
      color: kTextBlackColor,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
  ),
  pushButtonTheme: const PushButtonThemeData(
    color: kPrimaryColor,
    secondaryColor: kSecondaryColor,
  ),
);
