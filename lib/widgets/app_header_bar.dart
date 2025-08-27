import 'dart:io' show Platform;

import 'package:flutter/widgets.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:window_manager/window_manager.dart';

import 'package:vettore/models/grufio_tab_data.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/widgets/grufio_tabs_app.dart';

class AppHeaderBar extends StatefulWidget {
  const AppHeaderBar({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onTabSelected,
    this.height = 40.0,
    this.leftPaddingWhenWindowed = 72.0,
    this.enableDragZone = true,
    this.autoFullscreenPadding = true,
  });

  final List<GrufioTabData> tabs;
  final int activeIndex;
  final ValueChanged<int> onTabSelected;
  final double height;
  final double leftPaddingWhenWindowed;
  final bool enableDragZone;
  final bool autoFullscreenPadding;

  @override
  State<AppHeaderBar> createState() => _AppHeaderBarState();
}

class _AppHeaderBarState extends State<AppHeaderBar>
    with WidgetsBindingObserver, WindowListener {
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isMacOS) {
      windowManager.addListener(this);
      _refreshWindowInfo();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (Platform.isMacOS) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (Platform.isMacOS) _refreshWindowInfo();
  }

  @override
  void onWindowEvent(String eventName) async {
    if (eventName == 'enter-full-screen' || eventName == 'leave-full-screen') {
      await _refreshWindowInfo();
    }
  }

  Future<void> _refreshWindowInfo() async {
    try {
      final isFs = await windowManager.isFullScreen();
      if (!mounted) return;
      setState(() => _isFullscreen = isFs);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final double leftPad = (Platform.isMacOS && widget.autoFullscreenPadding)
        ? (_isFullscreen ? 0.0 : widget.leftPaddingWhenWindowed)
        : widget.leftPaddingWhenWindowed;

    final header = Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: kHeaderBackgroundColor,
        border:
            Border(bottom: BorderSide(color: kHeaderDividerColor, width: 1)),
      ),
      padding: EdgeInsets.only(left: leftPad),
      child: Row(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(widget.tabs.length, (i) {
                final t = widget.tabs[i];
                return GrufioTab(
                  iconPath: t.iconPath,
                  label: t.label,
                  width: t.width,
                  isActive: i == widget.activeIndex,
                  showLeftBorder: i == 0,
                  showRightBorder: true,
                  onTap: () => widget.onTabSelected(i),
                );
              }),
            ),
          ),
          if (Platform.isMacOS && widget.enableDragZone)
            Expanded(child: MoveWindow()),
        ],
      ),
    );

    if (Platform.isMacOS) {
      return WindowTitleBarBox(child: header);
    }
    return header;
  }
}
