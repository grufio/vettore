import 'dart:math' as math;

// Strongly-typed units to avoid typos and magic strings
enum Unit { px, inch, point, centimeter, millimeter }

extension UnitString on Unit {
  String get asDbString {
    switch (this) {
      case Unit.px:
        return 'px';
      case Unit.inch:
        return 'in';
      case Unit.point:
        return 'pt';
      case Unit.centimeter:
        return 'cm';
      case Unit.millimeter:
        return 'mm';
    }
  }
}

Unit parseUnit(String unit) {
  switch (unit.trim().toLowerCase()) {
    case 'px':
      return Unit.px;
    case 'in':
      return Unit.inch;
    case 'pt':
      return Unit.point;
    case 'cm':
      return Unit.centimeter;
    case 'mm':
      return Unit.millimeter;
    default:
      throw ArgumentError('Unknown unit: $unit');
  }
}

double convertUnitTyped({
  required double value,
  required Unit from,
  required Unit to,
  required int dpi,
}) {
  if (dpi <= 0) {
    throw ArgumentError('dpi must be > 0');
  }

  double toInches(double v, Unit u) {
    switch (u) {
      case Unit.px:
        return v / dpi;
      case Unit.inch:
        return v;
      case Unit.point:
        return v / 72.0;
      case Unit.centimeter:
        return v / 2.54;
      case Unit.millimeter:
        return v / 25.4;
    }
  }

  double fromInches(double inches, Unit u) {
    switch (u) {
      case Unit.px:
        return inches * dpi;
      case Unit.inch:
        return inches;
      case Unit.point:
        return inches * 72.0;
      case Unit.centimeter:
        return inches * 2.54;
      case Unit.millimeter:
        return inches * 25.4;
    }
  }

  double _round(double v, int dec) {
    final double p = math.pow(10, dec).toDouble();
    return (v * p).round() / p;
  }

  final double inches = toInches(value, from);
  final double out = fromInches(inches, to);
  return to == Unit.px ? out : _round(out, 4);
}

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
