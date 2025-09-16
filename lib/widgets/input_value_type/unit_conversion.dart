import 'dart:math' as math;

double convertUnit({
  required double value,
  required String fromUnit,
  required String toUnit,
  required int dpi,
}) {
  if (dpi <= 0) {
    throw ArgumentError('dpi must be > 0');
  }

  String normalizeUnit(String u) => u.trim().toLowerCase();

  final String from = normalizeUnit(fromUnit);
  final String to = normalizeUnit(toUnit);
  const known = {'px', 'in', 'pt', 'cm', 'mm'};
  if (!known.contains(from)) {
    throw ArgumentError('Unknown unit: $fromUnit');
  }
  if (!known.contains(to)) {
    throw ArgumentError('Unknown unit: $toUnit');
  }

  double toInches(double v, String unit) {
    switch (unit) {
      case 'px':
        return v / dpi;
      case 'in':
        return v;
      case 'pt':
        return v / 72.0;
      case 'cm':
        return v / 2.54;
      case 'mm':
        return v / 25.4;
      default:
        // Should never happen due to validation above
        throw ArgumentError('Unknown unit: $unit');
    }
  }

  double fromInches(double inches, String unit) {
    switch (unit) {
      case 'px':
        return inches * dpi;
      case 'in':
        return inches;
      case 'pt':
        return inches * 72.0;
      case 'cm':
        return inches * 2.54;
      case 'mm':
        return inches * 25.4;
      default:
        // Should never happen due to validation above
        throw ArgumentError('Unknown unit: $unit');
    }
  }

  double _round(double v, int dec) {
    final double p = math.pow(10, dec).toDouble();
    return (v * p).round() / p;
  }

  final double inches = toInches(value, from);
  final double out = fromInches(inches, to);
  // For non-px targets, round to 4 decimals at conversion time
  return to == 'px' ? out : _round(out, 4);
}

String formatUnitValue(double value, String unit) {
  final String u = unit.trim().toLowerCase();
  if (u == 'px') {
    return value.round().toString();
  }
  // 4 Nachkommastellen für alle nicht-px Einheiten
  return value.toStringAsFixed(4);
}

/// UI-Feld-Formatierung: mm/cm mit 2 Nachkommastellen, px ganzzahlig,
/// andere Einheiten (in/pt) mit 4 Nachkommastellen.
String formatFieldUnitValue(double value, String unit) {
  final String u = unit.trim().toLowerCase();
  if (u == 'px') {
    return value.round().toString();
  }
  if (u == 'mm' || u == 'cm') {
    return value.toStringAsFixed(2);
  }
  return value.toStringAsFixed(4);
}
