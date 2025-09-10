double convertUnit({
  required double value,
  required String fromUnit,
  required String toUnit,
  required int dpi,
}) {
  double toInches(double v, String unit) {
    switch (unit) {
      case 'px':
        return v / dpi;
      case 'in':
        return v;
      case 'cm':
        return v / 2.54;
      case 'mm':
        return v / 25.4;
      default:
        return v; // assume inches if unknown
    }
  }

  double fromInches(double inches, String unit) {
    switch (unit) {
      case 'px':
        return inches * dpi;
      case 'in':
        return inches;
      case 'cm':
        return inches * 2.54;
      case 'mm':
        return inches * 25.4;
      default:
        return inches;
    }
  }

  final double inches = toInches(value, fromUnit);
  return fromInches(inches, toUnit);
}

String formatUnitValue(double value, String unit) {
  if (unit == 'px') {
    return value.round().toString();
  }
  return value.toStringAsFixed(2);
}
