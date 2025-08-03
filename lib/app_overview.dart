import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:vettore/models/grufio_tab_data.dart';
import 'package:vettore/widgets/grufio_tabs_app.dart';

class AppOverviewPage extends StatefulWidget {
  const AppOverviewPage({super.key});

  @override
  State<AppOverviewPage> createState() => _AppOverviewPageState();
}

class _AppOverviewPageState extends State<AppOverviewPage> {
  int _activeIndex = 0;
  final List<GrufioTabData> _tabs = [
    const GrufioTabData(iconPath: 'assets/icons/32/home.svg', width: 40.0),
    const GrufioTabData(
      iconPath: 'assets/icons/32/color-palette.svg',
      label: 'MouseOverTab',
    ),
  ];

  void _handleTabSelected(int index) {
    setState(() {
      _activeIndex = index;
    });
  }

  void _handleTabClosed(int index) {
    setState(() {
      _tabs.removeAt(index);
      // Adjust the active index if the closed tab was before or was the active tab
      if (index < _activeIndex ||
          (index == _activeIndex && index == _tabs.length)) {
        _activeIndex = (_activeIndex - 1).clamp(0, _tabs.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MacosWindow(
      titleBar: GrufioTitleBar(
        tabs: _tabs,
        activeIndex: _activeIndex,
        onTabSelected: _handleTabSelected,
        onTabClosed: _handleTabClosed,
      ),
      child: MacosScaffold(
        children: [
          ContentArea(
            builder: (context, scrollController) {
              return const Center(
                child: Text('App Content Area'),
              );
            },
          ),
        ],
      ),
    );
  }
}
