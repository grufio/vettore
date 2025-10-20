import 'package:flutter_test/flutter_test.dart';
import 'package:vettore/widgets/input_value_type/unit_value_controller.dart';

void main() {
  group('UnitValueController', () {
    test('setDpi does not change underlying pixel value', () {
      final c = UnitValueController(valuePx: 120.5, unit: 'mm', dpi: 96);
      final before = c.valuePx;
      c.setDpi(144);
      expect(c.valuePx, before);
    });

    test('getDisplayValueInUnit preserves last typed echo within epsilon', () {
      final c = UnitValueController(unit: 'mm', dpi: 96);
      // User types 120.50 mm
      c.setValueFromUnit(120.50, isUserInput: true);
      // Simulate storage rounding to nearest integer pixel in background
      final pxBefore = c.valuePx!;
      c.setValuePx(pxBefore + 0.3); // < 0.5 px drift → should echo typed value
      final display = c.getDisplayValueInUnit();
      expect(display, isNotNull);
      // Expect ~120.50 with 4-dec stability internally → allow tight tolerance
      expect(display!, closeTo(120.5, 1e-6));
    });

    test('unit change updates unit but does not mutate pixel value', () {
      final c = UnitValueController(valuePx: 200.0, unit: 'px', dpi: 96);
      final pxBefore = c.valuePx;
      c.setUnit('mm');
      expect(c.unit, 'mm');
      expect(c.valuePx, pxBefore);
    });
  });
}
