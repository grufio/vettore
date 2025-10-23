import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vettore/widgets/context_menu.dart';

void main() {
  testWidgets('Escape closes context menu via onKeyEvent', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: SizedBox.shrink()),
    ));

    // Open menu at center
    final context = tester.element(find.byType(SizedBox));
    bool closed = false;
    ContextMenu.show(
      context: context,
      globalPosition: const Offset(100, 100),
      items: [
        ContextMenuItem(label: 'Open', onTap: () {}),
      ],
      onClose: () => closed = true,
    );

    await tester.pumpAndSettle();
    expect(closed, isFalse);

    // Send Escape key down event; menu should close
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(closed, isTrue);
  });
}
