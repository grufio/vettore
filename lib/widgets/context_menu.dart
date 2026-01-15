import 'package:flutter/widgets.dart';
// ignore_for_file: always_use_package_imports
import '../theme/app_theme_colors.dart';
import 'input_value_type/dropdown_overlay.dart';

class ContextMenu {
  static const double menuWidth = kDropdownPanelWidth;
  static const double itemHeight = kDropdownItemHeight;

  static void show({
    required BuildContext context,
    required Offset globalPosition,
    required List<ContextMenuItem> items,
    required VoidCallback onClose,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    // Wrap items to ensure the overlay entry is removed on selection
    final List<ContextMenuItem> wrappedItems = items
        .map((it) => ContextMenuItem(
              label: it.label,
              onTap: () {
                entry.remove();
                it.onTap();
                onClose();
              },
            ))
        .toList();

    entry = OverlayEntry(
      builder: (_) => _MenuPanel(
        position: globalPosition,
        items: wrappedItems,
        onClose: () {
          entry.remove();
          onClose();
        },
      ),
    );
    overlay.insert(entry);
  }
}

class ContextMenuItem {
  ContextMenuItem({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
}

class _MenuPanel extends StatelessWidget {
  const _MenuPanel(
      {required this.position, required this.items, required this.onClose});
  final Offset position;
  final List<ContextMenuItem> items;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
        child: GestureDetector(
            onTap: onClose, child: const ColoredBox(color: Color(0x00000000))),
      ),
      Positioned(
        left: position.dx,
        top: position.dy,
        child: ConstrainedBox(
          constraints:
              const BoxConstraints.tightFor(width: kDropdownPanelWidth),
          child: ColoredBox(
            color: kGrey100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [for (final it in items) _MenuRow(item: it)],
            ),
          ),
        ),
      ),
    ]);
  }
}

class _MenuRow extends StatefulWidget {
  const _MenuRow({required this.item});
  final ContextMenuItem item;
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
      child: GestureDetector(
        onTap: widget.item.onTap,
        child: Container(
          height: kDropdownItemHeight,
          color: _hovered ? kInputBackground : kTransparent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child:
                Text(widget.item.label, style: const TextStyle(color: kWhite)),
          ),
        ),
      ),
    );
  }
}
