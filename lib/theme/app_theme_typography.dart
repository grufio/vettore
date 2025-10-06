import 'package:flutter/material.dart';
import 'package:vettore/theme/app_theme_colors.dart';

// Exported text style constants
class AppTextStylesExported {
  const AppTextStylesExported();
  TextStyle get bodyXS => const TextStyle(
        fontSize: 8.0,
        fontWeight: FontWeight.normal,
        color: kGrey90,
      );
  TextStyle get bodyS => const TextStyle(
        fontSize: 10.0,
        fontWeight: FontWeight.normal,
        color: kGrey90,
      );
  TextStyle get bodyM => const TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
        color: kGrey90,
      );
  TextStyle get bodyMMedium => const TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        color: kGrey90,
      );
  TextStyle get bodyL => const TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
        color: kGrey90,
      );
  TextStyle get bodyXL => const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.normal,
        color: kGrey90,
      );
}

// Backward-compatible constant for existing imports
const AppTextStylesExported appTextStyles = AppTextStylesExported();
