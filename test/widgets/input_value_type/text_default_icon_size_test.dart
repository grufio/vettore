import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grufio/widgets/input_value_type/prefix_icon.dart';
import 'package:grufio/widgets/input_value_type/text_default.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: SizedBox(width: 300, child: child))));

  testWidgets('TextDefaultInput renders prefix icon at 16x16', (tester) async {
    final controller = TextEditingController(text: 'Title');
    await tester.pumpWidget(host(const Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(),
    )));

    await tester.pumpWidget(host(TextDefaultInput(controller: controller)));
    await tester.pumpAndSettle();

    final iconFinder = find.byType(PrefixIcon);
    expect(iconFinder, findsOneWidget);
    final size = tester.getSize(iconFinder);
    expect(size.width, 16.0);
    expect(size.height, 16.0);
  });
}
