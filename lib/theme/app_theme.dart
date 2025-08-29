import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:vettore/theme/app_theme_colors.dart';

// =================================================================================
// Main App Theme
// =================================================================================

/// A macOS theme that uses the custom colors from your theme.
final MacosThemeData appTheme = MacosThemeData.light().copyWith(
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
