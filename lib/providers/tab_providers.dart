import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/models/grufio_tab_data.dart';

class TabsNotifier extends StateNotifier<List<GrufioTabData>> {
  TabsNotifier()
      : super([
          const GrufioTabData(
              iconPath: 'assets/icons/32/home.svg', width: 40.0),
          const GrufioTabData(
            iconPath: 'assets/icons/32/color-palette.svg',
            label: 'MouseOverTab',
          ),
        ]);

  void addTab(GrufioTabData tab) {
    state = [...state, tab];
  }

  // Updated to return the new list for convenience
  List<GrufioTabData> removeTab(int index) {
    if (index >= 0 && index < state.length) {
      state = List.from(state)..removeAt(index);
    }
    return state;
  }
}

final tabsProvider = StateNotifierProvider<TabsNotifier, List<GrufioTabData>>(
    (ref) => TabsNotifier());

final activeTabIndexProvider = StateProvider<int>((ref) => 0);
