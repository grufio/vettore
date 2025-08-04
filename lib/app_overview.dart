import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:vettore/models/grufio_tab_data.dart';
import 'package:vettore/widgets/grufio_tabs_app.dart';

class _MyDelegate extends NSWindowDelegate {
  final void Function(bool isFullscreen) onFullscreenChange;
  _MyDelegate(this.onFullscreenChange);

  @override
  void windowDidEnterFullScreen() {
    onFullscreenChange(true);
    super.windowDidEnterFullScreen();
  }

  @override
  void windowDidExitFullScreen() {
    onFullscreenChange(false);
    super.windowDidExitFullScreen();
  }
}

class AppOverviewPage extends StatefulWidget {
  const AppOverviewPage({super.key});

  @override
  State<AppOverviewPage> createState() => _AppOverviewPageState();
}

class _AppOverviewPageState extends State<AppOverviewPage> {
  int _activeIndex = 0;
  bool _isFullscreen = false;
  NSWindowDelegateHandle? _delegateHandle;

  final List<GrufioTabData> _tabs = [
    const GrufioTabData(iconPath: 'assets/icons/32/home.svg', width: 40.0),
    const GrufioTabData(
      iconPath: 'assets/icons/32/color-palette.svg',
      label: 'MouseOverTab',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final delegate = _MyDelegate((isFullscreen) {
      setState(() => _isFullscreen = isFullscreen);
      // Ensure layout updates after macOS animation
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
    });
    _delegateHandle = WindowManipulator.addNSWindowDelegate(delegate);
  }

  @override
  void dispose() {
    _delegateHandle?.removeFromHandler();
    super.dispose();
  }

  void _handleTabSelected(int index) {
    setState(() => _activeIndex = index);
  }

  void _handleTabClosed(int index) {
    setState(() {
      _tabs.removeAt(index);
      if (index < _activeIndex ||
          (index == _activeIndex && index == _tabs.length)) {
        _activeIndex = (_activeIndex - 1).clamp(0, _tabs.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final toolbar = GrufioToolBar(
      tabs: _tabs,
      activeIndex: _activeIndex,
      onTabSelected: _handleTabSelected,
      onTabClosed: _handleTabClosed,
      isFullscreen: _isFullscreen,
    );

    return MacosWindow(
      child: MacosScaffold(
        toolBar: toolbar,
        children: [
          ContentArea(
            builder: (context, scrollController) {
              return const Center(child: Text('App Content Area'));
            },
          ),
        ],
      ),
    );
  }
}
