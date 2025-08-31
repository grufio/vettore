import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vettore/widgets/chip_filter.dart';

class FilterItem {
  final String id;
  final String label;
  const FilterItem({required this.id, required this.label});
}

class ContentFilterBar extends StatefulWidget {
  final List<FilterItem> items;
  final String activeId;
  final ValueChanged<String> onChanged;
  final double height;
  final double horizontalPadding;
  final double gap;
  final bool scrollable;

  const ContentFilterBar({
    super.key,
    required this.items,
    required this.activeId,
    required this.onChanged,
    this.height = 40.0,
    this.horizontalPadding = 24.0,
    this.gap = 4.0,
    this.scrollable = true,
  });

  @override
  State<ContentFilterBar> createState() => _ContentFilterBarState();
}

class _ContentFilterBarState extends State<ContentFilterBar> {
  final ScrollController _scrollController = ScrollController();
  late final List<GlobalKey> _itemKeys;

  @override
  void initState() {
    super.initState();
    _itemKeys = List.generate(widget.items.length, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureActiveVisible());
  }

  @override
  void didUpdateWidget(covariant ContentFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _itemKeys
        ..clear()
        ..addAll(List.generate(widget.items.length, (_) => GlobalKey()));
    }
    if (oldWidget.activeId != widget.activeId) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _ensureActiveVisible());
    }
  }

  void _ensureActiveVisible() {
    final index = widget.items.indexWhere((i) => i.id == widget.activeId);
    if (index >= 0 && index < _itemKeys.length) {
      final ctx = _itemKeys[index].currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.5,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _activatePrev() {
    final i = widget.items.indexWhere((e) => e.id == widget.activeId);
    if (i > 0) widget.onChanged(widget.items[i - 1].id);
  }

  void _activateNext() {
    final i = widget.items.indexWhere((e) => e.id == widget.activeId);
    if (i >= 0 && i < widget.items.length - 1) {
      widget.onChanged(widget.items[i + 1].id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        for (int i = 0; i < widget.items.length; i++) ...[
          GestureDetector(
            onTap: () => widget.onChanged(widget.items[i].id),
            child: KeyedSubtree(
              key: _itemKeys[i],
              child: widget.items[i].id == widget.activeId
                  ? ContentChip.active(label: widget.items[i].label)
                  : ContentChip.inactive(label: widget.items[i].label),
            ),
          ),
          if (i < widget.items.length - 1) SizedBox(width: widget.gap),
        ],
      ],
    );

    final content = widget.scrollable
        ? SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: row,
          )
        : row;

    return FocusableActionDetector(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowLeft):
            DirectionalFocusIntent(TraversalDirection.left),
        SingleActivator(LogicalKeyboardKey.arrowRight):
            DirectionalFocusIntent(TraversalDirection.right),
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
          onInvoke: (intent) {
            if (intent.direction == TraversalDirection.left) {
              _activatePrev();
            } else if (intent.direction == TraversalDirection.right) {
              _activateNext();
            }
            return null;
          },
        ),
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (intent) {
            // no-op, taps already handled
            return null;
          },
        ),
      },
      child: SizedBox(
        height: widget.height,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
          child: Align(
            alignment: Alignment.centerLeft,
            child: content,
          ),
        ),
      ),
    );
  }
}
