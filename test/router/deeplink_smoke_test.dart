import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vettore/app_router.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/models/grufio_tab_data.dart';
import 'package:vettore/providers/tabs_providers.dart';
import 'package:vettore/services/settings_service.dart';

class _FakeSettings extends SettingsService {
  _FakeSettings() : super(AppDatabase());
  @override
  String? getStringOrNull(String key) => null;
  @override
  Future<void> setString(String key, String value) async {}
  @override
  int getInt(String key, int defaultValue) => defaultValue;
  @override
  Future<void> setInt(String key, int value) async {}
}

class _FakeTabs extends TabsNotifier {
  _FakeTabs() : super(_FakeSettings());
  @override
  int addProjectTab({required int projectId, required String label}) {
    final i = indexOfProject(projectId);
    if (i != -1) return i;
    state = [
      ...state,
      GrufioTabData(iconId: 'color-palette', label: label, projectId: projectId)
    ];
    return state.length - 1;
  }

  @override
  void closeTab(int index) {
    if (index <= 0 || index >= state.length) return;
    final updated = List<GrufioTabData>.from(state)..removeAt(index);
    state = updated;
  }
}

class _FakeActive extends ActiveTabIndexNotifier {
  _FakeActive() : super(_FakeSettings());
  @override
  void set(int index, int max) {
    state = (index < 0) ? 0 : (index >= max ? max - 1 : index);
  }
}

class _FakeService extends TabsService {
  _FakeService(this._ref2) : super(_ref2);
  final rp.Ref _ref2;
  @override
  int addOrSelectProjectTab({required int projectId, required String label}) {
    final idx = (_ref2.read(tabsProvider.notifier) as _FakeTabs)
        .addProjectTab(projectId: projectId, label: label);
    final len = _ref2.read(tabsProvider).length;
    (_ref2.read(activeTabIndexProvider.notifier) as _FakeActive).set(idx, len);
    return idx;
  }

  @override
  void closeTab(int index) {
    (_ref2.read(tabsProvider.notifier) as _FakeTabs).closeTab(index);
    final len = _ref2.read(tabsProvider).length;
    final current = _ref2.read(activeTabIndexProvider);
    final newActive = (current >= len) ? (len - 1) : current;
    (_ref2.read(activeTabIndexProvider.notifier) as _FakeActive)
        .set(newActive, len);
  }
}

void main() {
  testWidgets('Deep-link to /project/:id creates/selects tab', (tester) async {
    final overrides = <Override>[
      tabsProvider.overrideWith((ref) => _FakeTabs()),
      activeTabIndexProvider.overrideWith((ref) => _FakeActive()),
      tabsServiceProvider
          .overrideWithProvider(Provider((ref) => _FakeService(ref))),
      settingsServiceProvider.overrideWithValue(_FakeSettings()),
    ];

    await tester.pumpWidget(ProviderScope(
      overrides: overrides,
      child: WidgetsApp.router(
        color: const Color(0xFFFFFFFF),
        routerConfig: appRouter,
      ),
    ));

    // Navigate to a project deep-link
    appRouter.go('/project/123');
    await tester.pumpAndSettle();

    // Read tabs via Provider from root context
    final BuildContext ctx = tester.element(find.byType(WidgetsApp));
    final container = ProviderScope.containerOf(ctx);
    final tabs = container.read(tabsProvider);
    final active = container.read(activeTabIndexProvider);

    expect(tabs.length >= 2, true); // Home + project tab
    expect(active, isNonNegative);
  });
}
