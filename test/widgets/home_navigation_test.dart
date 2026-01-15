import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grufio/theme/app_theme_colors.dart';
import 'package:grufio/widgets/side_menu_navigation.dart';

void main() {
  testWidgets('ProjectNavigation: selected uses kSelected', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: ProjectNavigation(
          onTap: _noop,
        ),
      ),
    ));

    // Find the Container backing the 'All' row (first section)
    final allFinder = find.text('All');
    expect(allFinder, findsWidgets);
    final containerFinder =
        find.ancestor(of: allFinder.first, matching: find.byType(Container));
    final Container c = tester.widget(containerFinder.first);
    final BoxDecoration? deco = c.decoration as BoxDecoration?;
    expect(deco?.color, kSelected);
  });

  testWidgets('ProjectNavigation: hover uses kGrey10', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: ProjectNavigation(
          onTap: _noop,
        ),
      ),
    ));

    // Hover over 'Current' in the Projects section
    final currentFinder = find.text('Current').first;
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(gesture.removePointer);
    await gesture.addPointer();
    await gesture.moveTo(tester.getCenter(currentFinder));
    await tester.pumpAndSettle();

    final containerFinder =
        find.ancestor(of: currentFinder, matching: find.byType(Container));
    final Container c = tester.widget(containerFinder.first);
    final BoxDecoration? deco = c.decoration as BoxDecoration?;
    expect(deco?.color, kGrey10);
  });
}

void _noop(int _) {}
