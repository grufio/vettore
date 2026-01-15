import 'package:grufio/widgets/input_value_type/unit_conversion.dart';

/// Keep only digits and at most a single decimal separator '.'
String sanitizeNumber(String raw) {
  final String digitsAndDots = raw.replaceAll(RegExp(r'[^0-9\.]'), '');
  final int dotIndex = digitsAndDots.indexOf('.');
  if (dotIndex == -1) return digitsAndDots;
  // Remove any subsequent dots while keeping the first one
  final String before = digitsAndDots.substring(0, dotIndex + 1);
  final String after =
      digitsAndDots.substring(dotIndex + 1).replaceAll('.', '');
  return before + after;
}

double clampPx(double px,
    {double minPx = double.negativeInfinity, double maxPx = double.infinity}) {
  return px.clamp(minPx, maxPx).toDouble();
}

double toPx(double value, String unit, int dpi) {
  return convertUnit(value: value, fromUnit: unit, toUnit: 'px', dpi: dpi);
}

double fromPx(double px, String unit, int dpi) {
  return convertUnit(value: px, fromUnit: 'px', toUnit: unit, dpi: dpi);
}
