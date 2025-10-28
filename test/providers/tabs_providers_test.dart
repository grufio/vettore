import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/providers/tabs_providers.dart';

void main() {
  test('addOrSelectProjectTab deduplicates and selects', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final service = container.read(tabsServiceProvider);

    // Initially only Home tab
    expect(container.read(tabsProvider).length, 1);
    expect(container.read(activeTabIndexProvider), 0);

    final i1 = service.addOrSelectProjectTab(projectId: 42, label: 'Proj');
    expect(container.read(tabsProvider).length, 2);
    expect(container.read(activeTabIndexProvider), i1);

    final i2 = service.addOrSelectProjectTab(projectId: 42, label: 'Proj');
    // No duplicate
    expect(container.read(tabsProvider).length, 2);
    expect(i2, i1);
  });
}
