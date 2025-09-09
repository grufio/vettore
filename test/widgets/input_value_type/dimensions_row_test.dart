import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vettore/widgets/input_value_type/dimensions_row.dart';
import 'package:vettore/widgets/button_toggle.dart';

void main() {
  Widget makeHost(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: SizedBox(width: 300, child: child))),
    );
  }

  testWidgets('DimensionsRow: linked updates height on width change',
      (tester) async {
    final widthController = TextEditingController(text: '100');
    final heightController = TextEditingController(text: '50');

    await tester.pumpWidget(makeHost(DimensionsRow(
      widthController: widthController,
      heightController: heightController,
      enabled: true,
      initialLinked: false,
    )));

    // Link W/H
    await tester.tap(find.byType(ButtonToggle));
    await tester.pumpAndSettle();

    // Change width to 200 -> height should follow with aspect 0.5 -> 100
    final widthField = find.descendant(
      of: find.byKey(const ValueKey('width')),
      matching: find.byType(TextField),
    );
    expect(widthField, findsOneWidget);
    await tester.enterText(widthField, '200');
    await tester.pump();
    expect(heightController.text, '100');
  });

  testWidgets('DimensionsRow: unlink stops syncing counterpart',
      (tester) async {
    final widthController = TextEditingController(text: '100');
    final heightController = TextEditingController(text: '50');

    await tester.pumpWidget(makeHost(DimensionsRow(
      widthController: widthController,
      heightController: heightController,
      enabled: true,
      initialLinked: true,
    )));

    // Change width to 200 while linked -> height becomes 100
    final widthField = find.descendant(
      of: find.byKey(const ValueKey('width')),
      matching: find.byType(TextField),
    );
    await tester.enterText(widthField, '200');
    await tester.pump();
    expect(heightController.text, '100');

    // Unlink
    await tester.tap(find.byType(ButtonToggle));
    await tester.pumpAndSettle();

    // Change width again -> height should remain 100
    await tester.enterText(widthField, '300');
    await tester.pump();
    expect(heightController.text, '100');
  });
}
