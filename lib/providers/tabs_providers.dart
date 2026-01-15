// ignore_for_file: always_use_package_imports
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/grufio_tab_data.dart';

/// Tabs state: list of tabs shown in the AppHeaderBar.
class TabsNotifier extends StateNotifier<List<GrufioTabData>> {
  TabsNotifier() : super([const GrufioTabData(iconId: 'home', width: 40)]);

  int indexOfProject(int projectId) {
    for (int i = 0; i < state.length; i++) {
      if (state[i].projectId == projectId) return i;
    }
    return -1;
  }

  int addProjectTab({required int projectId, required String label}) {
    final int existing = indexOfProject(projectId);
    if (existing != -1) return existing;
    final List<GrufioTabData> updated = List<GrufioTabData>.from(state)
      ..add(GrufioTabData(
        iconId: 'color-palette',
        label: label,
        projectId: projectId,
      ));
    state = updated;
    return updated.length - 1;
  }

  void closeTab(int index) {
    if (index <= 0 || index >= state.length) return; // keep Home
    final List<GrufioTabData> updated = List<GrufioTabData>.from(state)
      ..removeAt(index);
    state = updated;
  }

  void updateProjectTabLabel(int projectId, String label) {
    final int idx = indexOfProject(projectId);
    if (idx == -1) return;
    final GrufioTabData t = state[idx];
    if (t.label == label) return;
    final List<GrufioTabData> updated = List<GrufioTabData>.from(state);
    updated[idx] = GrufioTabData(
      iconId: t.iconId,
      label: label,
      width: t.width,
      projectId: t.projectId,
      vendorId: t.vendorId,
    );
    state = updated;
  }
}

final tabsProvider =
    StateNotifierProvider<TabsNotifier, List<GrufioTabData>>((ref) {
  return TabsNotifier();
});

/// Active tab index for the header tabs.
class ActiveTabIndexNotifier extends StateNotifier<int> {
  ActiveTabIndexNotifier() : super(0);

  void set(int index, int max) {
    if (index < 0) {
      state = 0;
    } else if (index >= max) {
      state = (max - 1).clamp(0, max - 1);
    } else {
      state = index;
    }
  }
}

final activeTabIndexProvider =
    StateNotifierProvider<ActiveTabIndexNotifier, int>((ref) {
  return ActiveTabIndexNotifier();
});

/// High-level helper service to modify tabs and active index together.
class TabsService {
  TabsService(this._ref);
  final Ref _ref;

  /// Add project tab if missing, then select it. Returns the index.
  int addOrSelectProjectTab({required int projectId, required String label}) {
    final tabsNotifier = _ref.read(tabsProvider.notifier);
    final int index = tabsNotifier.addProjectTab(
      projectId: projectId,
      label: label,
    );
    final int length = _ref.read(tabsProvider).length;
    _ref.read(activeTabIndexProvider.notifier).set(index, length);
    return index;
  }

  /// Close a tab and adjust the active index if necessary.
  void closeTab(int index) {
    final current = _ref.read(activeTabIndexProvider);
    _ref.read(tabsProvider.notifier).closeTab(index);
    final newTabs = _ref.read(tabsProvider);
    int newActive = current;
    if (current >= newTabs.length) newActive = newTabs.length - 1;
    if (newActive < 0) newActive = 0;
    _ref.read(activeTabIndexProvider.notifier).set(newActive, newTabs.length);
  }
}

final tabsServiceProvider = Provider<TabsService>((ref) => TabsService(ref));
