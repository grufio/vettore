import 'package:flutter_test/flutter_test.dart';
import 'package:grufio/widgets/input_value_type/unit_conversion.dart';

void main() {
  group('convertUnit', () {
    test('px ↔ in at 96 dpi', () {
      const dpi = 96;
      expect(convertUnit(value: 96, fromUnit: 'px', toUnit: 'in', dpi: dpi),
          closeTo(1.0, 1e-9));
      expect(convertUnit(value: 1, fromUnit: 'in', toUnit: 'px', dpi: dpi),
          closeTo(96.0, 1e-9));
    });

    test('cm/mm ↔ in at 96 dpi', () {
      const dpi = 96;
      expect(convertUnit(value: 2.54, fromUnit: 'cm', toUnit: 'in', dpi: dpi),
          closeTo(1.0, 1e-9));
      expect(convertUnit(value: 25.4, fromUnit: 'mm', toUnit: 'in', dpi: dpi),
          closeTo(1.0, 1e-9));
    });

    test('cm → px respects dpi', () {
      const dpi = 96;
      final px = convertUnit(value: 10, fromUnit: 'cm', toUnit: 'px', dpi: dpi);
      expect(px, closeTo(10 * (dpi / 2.54), 1e-9));
    });

    test('px → cm respects dpi (72 dpi)', () {
      const dpi = 72;
      final cm =
          convertUnit(value: 144, fromUnit: 'px', toUnit: 'cm', dpi: dpi);
      expect(cm, closeTo((144 / dpi) * 2.54, 1e-9));
    });
  });

  group('formatUnitValue', () {
    test('px rounds to int', () {
      // Current model formats all units to 2 decimals consistently
      expect(formatUnitValue(377.95, 'px'), '377.95');
      expect(formatUnitValue(377.1, 'px'), '377.10');
    });

    test('physical units keep two decimals', () {
      expect(formatUnitValue(1.2345, 'cm'), '1.23');
      expect(formatUnitValue(1.235, 'mm'), '1.24');
      expect(formatUnitValue(2.0, 'in'), '2.00');
    });
  });
}
