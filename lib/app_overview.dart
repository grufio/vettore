// lib/app_overview.dart

import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'package:vettore/models/grufio_tab_data.dart';
import 'package:vettore/widgets/grufio_tabs_app.dart' show GrufioTab;

const double _kToolbarHeight = 40.0;

class AppOverviewPage extends StatefulWidget {
  const AppOverviewPage({super.key});
  @override
  State<AppOverviewPage> createState() => _AppOverviewPageState();
}

class _AppOverviewPageState extends State<AppOverviewPage> {
  int _activeIndex = 0;
  final List<GrufioTabData> _tabs = [
    const GrufioTabData(iconPath: 'assets/icons/32/home.svg', width: 40),
    const GrufioTabData(
        iconPath: 'assets/icons/32/color-palette.svg', label: 'Palette'),
  ];

  void _onTabSelected(int i) => setState(() => _activeIndex = i);

  @override
  Widget build(BuildContext context) {
    return MacosWindow(
      child: Column(
        children: [
          WindowTitleBarBox(
            child: ToolBar(
              height: _kToolbarHeight,
              title: Row(
                children: [
                  Expanded(child: MoveWindow()),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: _kToolbarHeight,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: GrufioTabsApp(
                        tabs: _tabs,
                        activeIndex: _activeIndex,
                        onTabSelected: _onTabSelected,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MinimizeWindowButton(),
                  MaximizeWindowButton(),
                  CloseWindowButton(),
                ],
              ),
            ),
          ),
          Expanded(
            child: MacosScaffold(
              toolBar: null,
              backgroundColor: MacosColors.windowBackgroundColor,
              children: [
                ContentArea(builder: (_, __) {
                  return Center(
                    child: Text('Content for Tab ${_activeIndex + 1}'),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Lightweight wrapper for tab rendering, keeping grufio_tabs_app.dart untouched.
class GrufioTabsApp extends StatelessWidget {
  final List<GrufioTabData> tabs;
  final int activeIndex;
  final ValueChanged<int> onTabSelected;

  const GrufioTabsApp({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(tabs.length, (index) {
        final data = tabs[index];
        return GrufioTab(
          iconPath: data.iconPath,
          label: data.label,
          width: data.width,
          isActive: index == activeIndex,
          showLeftBorder: index > 0,
          onTap: () => onTabSelected(index),
        );
      }),
    );
  }
}
