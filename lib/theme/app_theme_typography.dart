import 'package:flutter/material.dart';
import 'package:vettore/theme/app_theme_colors.dart';

/// A custom theme extension for our specific text styles.
/// This allows us to add our own text style system to the main ThemeData.
@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.bodyXS,
    required this.bodyS,
    required this.bodyM,
    required this.bodyL,
    required this.bodyXL,
  });

  final TextStyle bodyXS; // 8px
  final TextStyle bodyS; // 10px
  final TextStyle bodyM; // 12px
  final TextStyle bodyL; // 14px
  final TextStyle bodyXL; // 16px

  @override
  ThemeExtension<AppTextStyles> copyWith({
    TextStyle? bodyXS,
    TextStyle? bodyS,
    TextStyle? bodyM,
    TextStyle? bodyL,
    TextStyle? bodyXL,
  }) {
    return AppTextStyles(
      bodyXS: bodyXS ?? this.bodyXS,
      bodyS: bodyS ?? this.bodyS,
      bodyM: bodyM ?? this.bodyM,
      bodyL: bodyL ?? this.bodyL,
      bodyXL: bodyXL ?? this.bodyXL,
    );
  }

  @override
  ThemeExtension<AppTextStyles> lerp(
    covariant ThemeExtension<AppTextStyles>? other,
    double t,
  ) {
    if (other is! AppTextStyles) {
      return this;
    }
    return AppTextStyles(
      bodyXS: TextStyle.lerp(bodyXS, other.bodyXS, t)!,
      bodyS: TextStyle.lerp(bodyS, other.bodyS, t)!,
      bodyM: TextStyle.lerp(bodyM, other.bodyM, t)!,
      bodyL: TextStyle.lerp(bodyL, other.bodyL, t)!,
      bodyXL: TextStyle.lerp(bodyXL, other.bodyXL, t)!,
    );
  }
}

// Create an instance of our custom text styles to be used in the main theme.
const appTextStyles = AppTextStyles(
  bodyXS: TextStyle(
    fontSize: 8.0,
    fontWeight: FontWeight.normal,
    color: kOnBackgroundColor,
  ),
  bodyS: TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.normal,
    color: kOnBackgroundColor,
  ),
  bodyM: TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: kOnBackgroundColor,
  ),
  bodyL: TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: kOnBackgroundColor,
  ),
  bodyXL: TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: kOnBackgroundColor,
  ),
);
