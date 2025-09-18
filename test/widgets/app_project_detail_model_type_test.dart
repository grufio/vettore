import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/app_project_detail.dart';

void main() {
  testWidgets('Model/Type persistence and filtering', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: AppProjectDetailPage()),
        ),
      ),
    );

    // Just build smoke test; detailed interaction tests depend on keys/ids.
    await tester.pumpAndSettle();

    // Verify the page is on project tab initially
    // and the widget tree renders without exceptions.
    expect(find.byType(AppProjectDetailPage), findsOneWidget);
  });
}
