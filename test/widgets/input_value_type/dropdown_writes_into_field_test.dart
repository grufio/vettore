import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grufio/widgets/input_value_type/input_value_type.dart';

class _DropdownHost extends StatefulWidget {
  const _DropdownHost();
  @override
  State<_DropdownHost> createState() => _DropdownHostState();
}

class _DropdownHostState extends State<_DropdownHost> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 240,
            child: InputValueType(
              controller: _controller,
              placeholder: 'Select model',
              dropdownItems: const ['Bricks', 'Colors'],
              variant: InputVariant.dropdown,
              suffixKey: const ValueKey('ivt-suffix'),
              onItemSelected: (value) {
                _controller.text = value;
              },
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Dropdown writes selection into field', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: _DropdownHost()));

    // Open overlay via suffix
    await tester.tap(find.byKey(const ValueKey('ivt-suffix')));
    await tester.pumpAndSettle();
    // Tap Colors
    await tester.tap(find.text('Colors').last);
    await tester.pumpAndSettle();

    final EditableText field = tester.widget(find.byType(EditableText));
    expect(field.controller.text, 'Colors');
  });
}
