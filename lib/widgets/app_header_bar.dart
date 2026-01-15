import 'dart:io' show Platform;

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/widgets.dart';
import 'package:grufio/models/grufio_tab_data.dart';
import 'package:grufio/services/logger.dart';
import 'package:grufio/theme/app_theme_colors.dart';
import 'package:grufio/widgets/tabs_main.dart';
import 'package:window_manager/window_manager.dart';

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
    this.showCloseButtons = true,
    this.onCloseTab,
    this.onAddTab,
  });

  final List<GrufioTabData> tabs;
  final int activeIndex;
  final ValueChanged<int> onTabSelected;
  final double height;
  final double leftPaddingWhenWindowed;
  final bool enableDragZone;
  final bool autoFullscreenPadding;
  final bool showCloseButtons;
  final ValueChanged<int>? onCloseTab;
  final VoidCallback? onAddTab;

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
    } catch (e, st) {
      logWarn('Failed to refresh window fullscreen state', e, st);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double leftPad = (Platform.isMacOS && widget.autoFullscreenPadding)
        ? (_isFullscreen ? 0.0 : widget.leftPaddingWhenWindowed)
        : widget.leftPaddingWhenWindowed;

    final header = Container(
      height: widget.height,
      decoration: const BoxDecoration(
        color: kHeaderBackgroundColor,
        border: Border(bottom: BorderSide(color: kBordersColor)),
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
                  iconId: t.iconId,
                  label: t.label,
                  width: t.width,
                  isActive: i == widget.activeIndex,
                  showLeftBorder: i == 0,
                  onTap: () => widget.onTabSelected(i),
                  onClose: (widget.showCloseButtons && i > 0)
                      ? () => widget.onCloseTab?.call(i)
                      : null,
                );
              }),
            ),
          ),
          GrufioTabButton(
            onTap: () => widget.onAddTab?.call(),
          ),
          if (Platform.isMacOS && widget.enableDragZone)
            Expanded(child: MoveWindow()),
        ],
      ),
    );

    if (Platform.isMacOS) {
      // Return the full 40px header without wrapping in WindowTitleBarBox
      return header;
    }
    return header;
  }
}
