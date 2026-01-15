import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grufio/widgets/input_value_type/input_value_type.dart';

class _SelectorHost extends StatefulWidget {
  const _SelectorHost();
  @override
  State<_SelectorHost> createState() => _SelectorHostState();
}

class _SelectorHostState extends State<_SelectorHost> {
  final TextEditingController _controller = TextEditingController(text: '100');
  String _unit = 'px';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 240,
            child: InputValueType(
              controller: _controller,
              placeholder: 'Width',
              dropdownItems: const ['px', 'cm', 'mm', 'in'],
              selectedItem: _unit,
              suffixText: _unit,
              variant: InputVariant.selector,
              suffixKey: const ValueKey('ivt-suffix'),
              onItemSelected: (value) {
                setState(() => _unit = value);
              },
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Selector updates suffix, not field text', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: _SelectorHost()));
    // Initial suffix shows px
    expect(find.text('px'), findsOneWidget);

    // Open overlay via suffix
    await tester.tap(find.byKey(const ValueKey('ivt-suffix')));
    await tester.pumpAndSettle();
    // Tap cm
    await tester.tap(find.text('cm').last);
    await tester.pumpAndSettle();

    // Suffix should show cm now
    expect(find.text('cm'), findsOneWidget);
    // Field text should remain '100'
    final EditableText field = tester.widget(find.byType(EditableText));
    expect(field.controller.text, '100');
  });
}
