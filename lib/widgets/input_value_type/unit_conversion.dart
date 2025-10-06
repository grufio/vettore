// no math rounding at conversion-time; rounding only at display formatting

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
  // Exact metric-to-metric conversions (avoid inch detour)
  if (from == to) return value;
  final bool fromMetric = from == Unit.millimeter || from == Unit.centimeter;
  final bool toMetric = to == Unit.millimeter || to == Unit.centimeter;
  if (fromMetric && toMetric) {
    // Convert via millimeters as base
    final double inMm =
        (from == Unit.millimeter) ? value : value * 10.0; // cm -> mm
    return (to == Unit.millimeter) ? inMm : (inMm / 10.0); // mm -> cm
  }

  // General path via inches (no rounding here)
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

  final double inches = toInches(value, from);
  return fromInches(inches, to);
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

  // Exact metric-to-metric conversions (avoid inch detour)
  if (from == to) return value;
  final bool fromMetric = from == 'mm' || from == 'cm';
  final bool toMetric = to == 'mm' || to == 'cm';
  if (fromMetric && toMetric) {
    final double inMm = (from == 'mm') ? value : value * 10.0; // cm -> mm
    return (to == 'mm') ? inMm : (inMm / 10.0); // mm -> cm
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
        throw ArgumentError('Unknown unit: $unit');
    }
  }

  final double inches = toInches(value, from);
  return fromInches(inches, to);
}

String formatUnitValue(double value, String unit) {
  final String u = unit.trim().toLowerCase();
  if (u == 'px') {
    return value.round().toString();
  }
  // UI rule: all non-px units show 2 decimals
  final double snapped = (value * 100.0).round() / 100.0;
  return snapped.toStringAsFixed(2);
}

/// UI-Feld-Formatierung: mm/cm mit 2 Nachkommastellen, px ganzzahlig,
/// andere Einheiten (in/pt) mit 4 Nachkommastellen.
String formatFieldUnitValue(double value, String unit) {
  final String u = unit.trim().toLowerCase();
  if (u == 'px') {
    return value.round().toString();
  }
  // UI rule: all non-px units show 2 decimals (avoid float drift)
  final double snapped = (value * 100.0).round() / 100.0;
  return snapped.toStringAsFixed(2);
}
