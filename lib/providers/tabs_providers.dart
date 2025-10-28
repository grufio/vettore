import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/models/grufio_tab_data.dart';
import 'package:vettore/services/settings_service.dart';

/// Tabs state: list of tabs shown in the AppHeaderBar.
class TabsNotifier extends StateNotifier<List<GrufioTabData>> {
  TabsNotifier(this._settings) : super(_loadInitial(_settings));
  final SettingsService _settings;

  static const String _kTabsJsonKey = 'ui_tabs_json';

  static List<GrufioTabData> _loadInitial(SettingsService settings) {
    final String? json = settings.getStringOrNull(_kTabsJsonKey);
    if (json == null || json.isEmpty) {
      return const [GrufioTabData(iconId: 'home', width: 40)];
    }
    try {
      final List<dynamic> arr = jsonDecode(json) as List<dynamic>;
      final List<GrufioTabData> tabs = [
        for (final dynamic e in arr)
          GrufioTabData(
            iconId: (e['iconId'] as String?) ?? 'home',
            label: e['label'] as String?,
            width: (e['width'] as num?)?.toDouble(),
            projectId: e['projectId'] as int?,
            vendorId: e['vendorId'] as int?,
          )
      ];
      if (tabs.isEmpty || tabs.first.projectId != null) {
        // Ensure Home is present at index 0
        tabs.insert(0, const GrufioTabData(iconId: 'home', width: 40));
      }
      return tabs;
    } catch (_) {
      return const [GrufioTabData(iconId: 'home', width: 40)];
    }
  }

  Future<void> _persist() async {
    final List<Map<String, dynamic>> arr = [
      for (final t in state)
        {
          'iconId': t.iconId,
          'label': t.label,
          'width': t.width,
          'projectId': t.projectId,
          'vendorId': t.vendorId,
        }
    ];
    await _settings.setString(_kTabsJsonKey, jsonEncode(arr));
  }

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
    // ignore: discarded_futures
    _persist();
    return updated.length - 1;
  }

  void closeTab(int index) {
    if (index <= 0 || index >= state.length) return; // keep Home
    final List<GrufioTabData> updated = List<GrufioTabData>.from(state)
      ..removeAt(index);
    state = updated;
    // ignore: discarded_futures
    _persist();
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
    // ignore: discarded_futures
    _persist();
  }
}

final tabsProvider =
    StateNotifierProvider<TabsNotifier, List<GrufioTabData>>((ref) {
  final settings = ref.watch(settingsServiceProvider);
  return TabsNotifier(settings);
});

/// Active tab index for the header tabs.
class ActiveTabIndexNotifier extends StateNotifier<int> {
  ActiveTabIndexNotifier(this._settings)
      : super(_settings.getInt(_kActiveIndexKey, 0));
  final SettingsService _settings;
  static const String _kActiveIndexKey = 'ui_tabs_active_index';

  void set(int index, int max) {
    if (index < 0) {
      state = 0;
    } else if (index >= max) {
      state = (max - 1).clamp(0, max - 1);
    } else {
      state = index;
    }
    // ignore: discarded_futures
    _settings.setInt(_kActiveIndexKey, state);
  }
}

final activeTabIndexProvider =
    StateNotifierProvider<ActiveTabIndexNotifier, int>((ref) {
  final settings = ref.watch(settingsServiceProvider);
  return ActiveTabIndexNotifier(settings);
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
