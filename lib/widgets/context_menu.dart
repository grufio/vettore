import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/widgets/input_value_type/dropdown_overlay.dart'
    show kDropdownItemHeight, kDropdownPanelWidth;

class ContextMenuItem {
  const ContextMenuItem({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
}

class ContextMenuController {
  OverlayEntry? _entry;
  void close() {
    _entry?.remove();
    _entry = null;
  }
}

class ContextMenu {
  static const double menuWidth = kDropdownPanelWidth;
  static const double itemHeight = kDropdownItemHeight;
  static const EdgeInsets panelPadding = EdgeInsets.all(8.0);
  // Single-open guard
  static ContextMenuController? _activeController;
  static VoidCallback? _activeOnClose;
  static void _clearActive() {
    _activeController = null;
    _activeOnClose = null;
  }

  static ContextMenuController show({
    required BuildContext context,
    required Offset globalPosition,
    required List<ContextMenuItem> items,
    VoidCallback? onClose,
  }) {
    // Close any existing menu first (material will also handle single-open, but we ensure border clears)
    _activeController?.close();
    _activeOnClose?.call();
    _clearActive();

    final controller = ContextMenuController();

    // Convert global position to a RelativeRect for showMenu
    final RenderBox overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromLTWH(globalPosition.dx, globalPosition.dy, 0, 0),
      Offset.zero & overlayBox.size,
    );

    // Custom-styled Material menu entries (match dropdown visuals)
    final List<PopupMenuEntry<int>> entries = List.generate(
      items.length,
      (i) => PopupMenuItem<int>(
        value: i,
        padding: EdgeInsets.zero,
        height: kDropdownItemHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _MenuRow(label: items[i].label),
        ),
      ),
    );

    showMenu<int>(
      context: context,
      position: position,
      items: entries,
      color: kGrey100,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      elevation: 4.0,
      constraints: const BoxConstraints(minWidth: kDropdownPanelWidth),
    ).then((int? value) {
      onClose?.call();
      _clearActive();
      if (value != null && value >= 0 && value < items.length) {
        items[value].onTap();
      }
    });

    _activeController = controller;
    _activeOnClose = onClose;
    return controller;
  }
}

class _ContextMenuPanel extends StatefulWidget {
  const _ContextMenuPanel({required this.items, required this.onDismiss});
  final List<ContextMenuItem> items;
  final VoidCallback onDismiss;

  @override
  State<_ContextMenuPanel> createState() => _ContextMenuPanelState();
}

class _ContextMenuPanelState extends State<_ContextMenuPanel> {
  int _hoverIndex = -1;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onFocusChange: (hasFocus) {
          if (!hasFocus) widget.onDismiss();
        },
        onKeyEvent: (node, KeyEvent event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            widget.onDismiss();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: ConstrainedBox(
          constraints:
              const BoxConstraints.tightFor(width: kDropdownPanelWidth),
          child: Container(
            padding: ContextMenu.panelPadding,
            decoration: const BoxDecoration(
              color: kGrey100,
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < widget.items.length; i++)
                  _ContextMenuRow(
                    label: widget.items[i].label,
                    hovered: _hoverIndex == i,
                    onEnter: () => setState(() => _hoverIndex = i),
                    onExit: () => setState(() => _hoverIndex = -1),
                    onTap: () {
                      widget.onDismiss();
                      widget.items[i].onTap();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatefulWidget {
  const _MenuRow({required this.label});
  final String label;
  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        height: kDropdownItemHeight,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: _hovered ? kInputBackground : kTransparent,
          borderRadius: const BorderRadius.all(Radius.circular(4.0)),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          widget.label,
          style: const TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w400,
            color: kWhite,
            height: 1.0,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _ContextMenuRow extends StatelessWidget {
  const _ContextMenuRow({
    required this.label,
    required this.hovered,
    required this.onTap,
    required this.onEnter,
    required this.onExit,
  });
  final String label;
  final bool hovered;
  final VoidCallback onTap;
  final VoidCallback onEnter;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: kDropdownItemHeight,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          color: hovered ? kInputBackground : kTransparent,
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
              color: kWhite,
              height: 1.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
