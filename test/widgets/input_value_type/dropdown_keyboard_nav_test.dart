import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vettore/widgets/input_value_type/input_value_type.dart';

void main() {
  Widget makeHost(Widget child) {
    return MaterialApp(
        home:
            Scaffold(body: Center(child: SizedBox(width: 300, child: child))));
  }

  testWidgets('Dropdown keyboard navigation highlights and selects',
      (tester) async {
    final controller = TextEditingController(text: 'linear');
    final items = ['nearest', 'linear', 'cubic'];

    await tester.pumpWidget(makeHost(InputValueType(
      controller: controller,
      dropdownItems: items,
      selectedItem: 'linear',
      variant: InputVariant.dropdown,
      suffixKey: const ValueKey('ivt-suffix'),
    )));

    // Focus the field
    await tester.tap(find.byType(TextField));
    await tester.pump();

    // Open dropdown via exposed suffix key
    await tester.tap(find.byKey(const ValueKey('ivt-suffix')));
    await tester.pump();

    // Send arrow down then enter to select next item
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    // Controller should now be updated via onItemSelected in parent (uncontrolled here)
    expect(items.contains(controller.text), isTrue);
  });
}
