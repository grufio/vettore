import 'package:flutter_test/flutter_test.dart';
import 'package:grufio/widgets/input_value_type/unit_conversion.dart';

void main() {
  test('formatFieldUnitValue adds .00 when missing', () {
    expect(formatFieldUnitValue(120, 'mm'), '120.00');
    expect(formatFieldUnitValue(120.1, 'mm'), '120.10');
  });
}
