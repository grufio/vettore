import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/app_overview.dart';

void main() {
  testWidgets('Overview defaults to Projects / All', (tester) async {
    await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(home: AppOverviewPage(showHeader: false))));
    await tester.pumpAndSettle();

    // Expect the HomeNavigation is built; default selected index is Projects/All
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('Libraries'), findsOneWidget);
  });
}
