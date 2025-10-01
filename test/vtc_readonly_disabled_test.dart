import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/widgets/input_value_type/resolution_selector.dart';
import 'package:vettore/widgets/input_value_type/dimension_row.dart';

void main() {
  group('Read-only view', () {
    testWidgets(
        'ResolutionSelector does not render tappable suffix in readOnlyView',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ResolutionSelector(
                  value: 96, onChanged: _noop, readOnlyView: true),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // In readOnlyView, dropdown is disabled; the suffix button is not built
      expect(find.byKey(const ValueKey('dpi-suffix')), findsNothing);
    });

    testWidgets('WidthRow uses disabled TextField when readOnlyView enabled',
        (tester) async {
      final widthController = TextEditingController(text: '1200');
      final heightController = TextEditingController(text: '1600');
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: WidthRow(
                widthController: widthController,
                heightController: heightController,
                enabled: false,
                readOnlyView: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textFields =
          tester.widgetList<TextField>(find.byType(TextField)).toList();
      expect(textFields.isNotEmpty, true);
      for (final tf in textFields) {
        expect(tf.enabled, false);
        expect(tf.readOnly, true);
      }
    });
  });
}

void _noop(int _) {}
