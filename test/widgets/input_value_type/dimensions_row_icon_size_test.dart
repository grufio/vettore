import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vettore/widgets/input_value_type/dimensions_row.dart';
import 'package:vettore/widgets/input_value_type/prefix_icon.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: SizedBox(width: 320, child: child))));

  testWidgets('DimensionsRow renders both prefix icons at 16x16',
      (tester) async {
    final w = TextEditingController(text: '100');
    final h = TextEditingController(text: '100');
    await tester.pumpWidget(host(DimensionsRow(
      widthController: w,
      heightController: h,
      enabled: true,
    )));
    await tester.pumpAndSettle();

    final icons = find.byType(PrefixIcon);
    expect(icons, findsNWidgets(2));
    for (final e in icons.evaluate()) {
      final size = tester.getSize(find.byWidget(e.widget));
      expect(size.width, 16.0);
      expect(size.height, 16.0);
    }
  });
}
