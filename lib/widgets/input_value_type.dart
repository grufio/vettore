import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart'
    show
        Material,
        MaterialType,
        TextField,
        InputDecoration,
        InputBorder,
        materialTextSelectionControls;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart'
    show RawKeyEvent, RawKeyDownEvent, LogicalKeyboardKey;
import 'dart:async';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/theme/app_theme_typography.dart';

class InputValueType extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextAlign textAlign;
  final bool autofocus;
  final String? placeholder;
  final String? suffixText;
  final String prefixIconAsset;
  final bool readOnly;
  // Dropdown support (optional). If provided, tapping the field opens a dropdown.
  final List<String>? dropdownItems;
  final String? selectedItem;
  final ValueChanged<String>? onItemSelected;
  final InputDropdownController? dropdownController;

  const InputValueType({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.textAlign = TextAlign.start,
    this.autofocus = false,
    this.placeholder,
    this.suffixText,
    this.prefixIconAsset = 'assets/icons/32/color-palette.svg',
    this.readOnly = false,
    this.dropdownItems,
    this.selectedItem,
    this.onItemSelected,
    this.dropdownController,
  });

  factory InputValueType.text({
    Key? key,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    TextAlign textAlign = TextAlign.start,
    bool autofocus = false,
    String? placeholder,
    String? suffixText,
    String prefixIconAsset = 'assets/icons/32/document--blank.svg',
  }) {
    return InputValueType(
      key: key,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textAlign: textAlign,
      autofocus: autofocus,
      placeholder: placeholder,
      suffixText: suffixText,
      prefixIconAsset: prefixIconAsset,
      readOnly: false,
    );
  }

  @override
  State<InputValueType> createState() => _InputValueTypeState();
}

class InputDropdownController {
  late VoidCallback _open;
  late VoidCallback _close;
  late VoidCallback _toggle;
  late VoidCallback _next;
  late VoidCallback _prev;
  late VoidCallback _confirm;

  void _attach(
    VoidCallback open,
    VoidCallback close,
    VoidCallback toggle,
    VoidCallback next,
    VoidCallback prev,
    VoidCallback confirm,
  ) {
    _open = open;
    _close = close;
    _toggle = toggle;
    _next = next;
    _prev = prev;
    _confirm = confirm;
  }

  void open() => _open();
  void close() => _close();
  void toggle() => _toggle();
  void highlightNext() => _next();
  void highlightPrev() => _prev();
  void confirm() => _confirm();
}

class _InputValueTypeState extends State<InputValueType> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  final FocusNode _keyboardNode = FocusNode();
  late final VoidCallback _controllerListener;
  late final VoidCallback _focusListener;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _targetKey = GlobalKey();
  OverlayEntry? _dropdownEntry;
  bool get _hasDropdown =>
      (widget.dropdownItems != null && widget.dropdownItems!.isNotEmpty);
  int _highlightIndex = -1;
  String _typeAheadBuffer = '';
  Timer? _typeAheadClearTimer;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    // Disallow focus when read-only
    _focusNode.canRequestFocus = !widget.readOnly;
    _controllerListener = () {
      if (!mounted) return;
      setState(() {});
    };
    _focusListener = () {
      if (!mounted) return;
      if (widget.readOnly) {
        return;
      }
      if (_focusNode.hasFocus) {
        // Select all on focus
        WidgetsBinding.instance.addPostFrameCallback((_) => _selectAll());
      } else {
        _clearSelection();
      }
      setState(() {});
    };
    _controller.addListener(_controllerListener);
    _focusNode.addListener(_focusListener);
    // Attach controller if present
    widget.dropdownController?._attach(
      () => _dropdownEntry == null ? _toggleDropdown() : null,
      _removeDropdown,
      _toggleDropdown,
      _highlightNext,
      _highlightPrev,
      _confirmSelection,
    );
  }

  @override
  void didUpdateWidget(covariant InputValueType oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.readOnly != widget.readOnly) {
      _focusNode.canRequestFocus = !widget.readOnly;
      if (widget.readOnly && _focusNode.hasFocus) {
        _focusNode.unfocus();
      }
      // Clear any selection when switching to read-only to avoid blue highlight
      if (widget.readOnly) {
        _controller.selection = const TextSelection.collapsed(offset: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_controllerListener);
    _focusNode.removeListener(_focusListener);
    _removeDropdown();
    _keyboardNode.dispose();
    _typeAheadClearTimer?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isReadOnly = widget.readOnly;
    final TextStyle textStyle = appTextStyles.bodyM.copyWith(
      color: isReadOnly ? kGrey70 : kGrey100,
      height: 1.0,
    );
    final TextStyle placeholderStyle = appTextStyles.bodyM.copyWith(
      color: kGrey70,
      fontStyle: FontStyle.italic,
      height: 1.0,
    );

    // Ensure no selection highlight persists when read-only, even after rebuild/resize
    if (isReadOnly) {
      final sel = _controller.selection;
      if (sel.start != sel.end || sel.baseOffset != sel.extentOffset) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _controller.selection = const TextSelection.collapsed(offset: 0);
        });
      }
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        key: _targetKey,
        height: 24.0,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: isReadOnly ? kWhite : kGrey10,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            color: isReadOnly
                ? kBordersColor
                : (_focusNode.hasFocus ? kInputFocus : kTransparent),
            width: 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              widget.prefixIconAsset,
              width: 16.0,
              height: 16.0,
              colorFilter: const ColorFilter.mode(kGrey70, BlendMode.srcIn),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: MouseRegion(
                cursor: isReadOnly
                    ? SystemMouseCursors.basic
                    : SystemMouseCursors.text,
                child: RawKeyboardListener(
                  focusNode: _keyboardNode,
                  onKey: (RawKeyEvent ev) {
                    if (ev is! RawKeyDownEvent) return;
                    if (!_hasDropdown) return;
                    if (_dropdownEntry == null) return;
                    final key = ev.logicalKey;
                    if (key == LogicalKeyboardKey.arrowDown) {
                      _highlightNext();
                    } else if (key == LogicalKeyboardKey.arrowUp) {
                      _highlightPrev();
                    } else if (key == LogicalKeyboardKey.home) {
                      _highlightHome();
                    } else if (key == LogicalKeyboardKey.end) {
                      _highlightEnd();
                    } else if (key == LogicalKeyboardKey.enter) {
                      _confirmSelection();
                    } else if (key == LogicalKeyboardKey.escape) {
                      _removeDropdown();
                    } else {
                      final label = key.keyLabel;
                      if (label.length == 1) {
                        _handleTypeAhead(label);
                      }
                    }
                  },
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (_hasDropdown && !isReadOnly) {
                        _toggleDropdown();
                      }
                    },
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        if (_controller.text.isEmpty &&
                            widget.placeholder != null)
                          IgnorePointer(
                            child: Text(
                              widget.placeholder!,
                              style: placeholderStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        IgnorePointer(
                          ignoring: isReadOnly,
                          child: Material(
                            type: MaterialType.transparency,
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              style: textStyle,
                              cursorColor: isReadOnly ? kTransparent : kGrey100,
                              decoration: const InputDecoration(
                                isCollapsed: true,
                                isDense: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              textAlign: widget.textAlign,
                              autofocus: isReadOnly ? false : widget.autofocus,
                              onChanged: isReadOnly ? null : widget.onChanged,
                              onSubmitted:
                                  isReadOnly ? null : widget.onSubmitted,
                              readOnly: isReadOnly,
                              enableInteractiveSelection: !isReadOnly,
                              showCursor: !isReadOnly,
                              selectionControls: materialTextSelectionControls,
                              enabled: !isReadOnly,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildSuffix(isReadOnly),
          ],
        ),
      ),
    );
  }

  void _clearSelection() {
    final int caret =
        _controller.selection.extentOffset.clamp(0, _controller.text.length);
    _controller.selection = TextSelection.collapsed(offset: caret);
  }

  void _selectAll() {
    final text = _controller.text;
    _controller.selection =
        TextSelection(baseOffset: 0, extentOffset: text.length);
  }

  Widget _buildSuffix(bool isReadOnly) {
    if (widget.suffixText == null) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 8.0),
        Text(
          widget.suffixText!,
          style: appTextStyles.bodyM
              .copyWith(color: isReadOnly ? kGrey70 : kGrey70, height: 1.0),
        ),
      ],
    );
  }

  void _toggleDropdown() {
    final bool needsInsert = !(_dropdownEntry?.mounted ?? false);
    _dropdownEntry ??= _createDropdown();
    if (needsInsert) {
      Overlay.of(context).insert(_dropdownEntry!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_dropdownEntry?.mounted ?? false) {
          _keyboardNode.requestFocus();
        }
      });
    } else {
      _removeDropdown();
    }
  }

  void _removeDropdown() {
    _dropdownEntry?.remove();
  }

  OverlayEntry _createDropdown() {
    final items = widget.dropdownItems ?? const <String>[];
    _highlightIndex = items.indexOf(widget.selectedItem ?? '');
    if (_highlightIndex < 0 && items.isNotEmpty) _highlightIndex = 0;
    _dropdownEntry = OverlayEntry(
      builder: (context) {
        final Size screenSize = MediaQuery.of(context).size;
        double offsetY = 28;
        const double itemHeight = 28.0;
        const int maxVisible = 8;
        final int visibleCount =
            items.length < maxVisible ? items.length : maxVisible;
        final double estimatedPanelHeight = 8 + (visibleCount * itemHeight) + 8;
        final RenderBox? targetBox =
            _targetKey.currentContext?.findRenderObject() as RenderBox?;
        if (targetBox != null) {
          final Offset topLeft = targetBox.localToGlobal(Offset.zero);
          final double targetBottom = topLeft.dy + targetBox.size.height;
          final double spaceBelow = screenSize.height - targetBottom;
          if (spaceBelow < estimatedPanelHeight + 8) {
            offsetY = -(estimatedPanelHeight + 4);
          }
        }
        return Positioned.fill(
          child: Stack(
            children: [
              // Dismiss area
              GestureDetector(
                  onTap: _removeDropdown, behavior: HitTestBehavior.opaque),
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, offsetY),
                child: _DropdownPanel(
                  items: items,
                  selected: widget.selectedItem,
                  highlightedIndex: _highlightIndex,
                  onHighlight: (i) {
                    setState(() => _highlightIndex = i);
                    _dropdownEntry?.markNeedsBuild();
                  },
                  onSelect: (value) {
                    widget.onItemSelected?.call(value);
                    _controller.text = value;
                    _removeDropdown();
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
    return _dropdownEntry!;
  }

  void _highlightNext() {
    final items = widget.dropdownItems!;
    if (items.isEmpty) return;
    setState(() => _highlightIndex = (_highlightIndex + 1) % items.length);
    _dropdownEntry?.markNeedsBuild();
  }

  void _highlightPrev() {
    final items = widget.dropdownItems!;
    if (items.isEmpty) return;
    setState(() =>
        _highlightIndex = (_highlightIndex - 1 + items.length) % items.length);
    _dropdownEntry?.markNeedsBuild();
  }

  void _highlightHome() {
    final items = widget.dropdownItems!;
    if (items.isEmpty) return;
    setState(() => _highlightIndex = 0);
    _dropdownEntry?.markNeedsBuild();
  }

  void _highlightEnd() {
    final items = widget.dropdownItems!;
    if (items.isEmpty) return;
    setState(() => _highlightIndex = items.length - 1);
    _dropdownEntry?.markNeedsBuild();
  }

  void _confirmSelection() {
    final items = widget.dropdownItems!;
    if (_highlightIndex < 0 || _highlightIndex >= items.length) return;
    final value = items[_highlightIndex];
    widget.onItemSelected?.call(value);
    _controller.text = value;
    _removeDropdown();
    setState(() {});
  }

  void _handleTypeAhead(String ch) {
    final String c = ch.toLowerCase();
    if (!RegExp(r'^[a-z0-9]$').hasMatch(c)) return;
    _typeAheadBuffer += c;
    _typeAheadClearTimer?.cancel();
    _typeAheadClearTimer =
        Timer(const Duration(milliseconds: 800), () => _typeAheadBuffer = '');
    final items = widget.dropdownItems!;
    int idx =
        items.indexWhere((s) => s.toLowerCase().startsWith(_typeAheadBuffer));
    if (idx < 0) {
      idx = items.indexWhere((s) => s.toLowerCase().startsWith(c));
    }
    if (idx >= 0) {
      setState(() => _highlightIndex = idx);
      _dropdownEntry?.markNeedsBuild();
    }
  }
}

class _DropdownPanel extends StatelessWidget {
  final List<String> items;
  final String? selected;
  final ValueChanged<String> onSelect;
  final int highlightedIndex;
  final ValueChanged<int> onHighlight;

  const _DropdownPanel({
    required this.items,
    required this.selected,
    required this.onSelect,
    required this.highlightedIndex,
    required this.onHighlight,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kTransparent,
      child: Semantics(
        container: true,
        label: 'Options',
        child: Container(
          constraints: const BoxConstraints(maxHeight: 280, minWidth: 160),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: kGrey100, // black background
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final value = items[index];
              final bool isSelected = selected == value;
              return _DropdownItem(
                label: value,
                isSelected: isSelected,
                highlighted: index == highlightedIndex,
                onHover: () => onHighlight(index),
                onTap: () => onSelect(value),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DropdownItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final bool highlighted;
  final VoidCallback onTap;
  final VoidCallback onHover;
  const _DropdownItem(
      {required this.label,
      required this.isSelected,
      required this.highlighted,
      required this.onTap,
      required this.onHover});

  @override
  State<_DropdownItem> createState() => _DropdownItemState();
}

class _DropdownItemState extends State<_DropdownItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        widget.onHover();
        setState(() => _hover = true);
      },
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Semantics(
          button: true,
          selected: widget.isSelected,
          label: widget.label,
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: (widget.highlighted || _hover)
                  ? kInputBackground
                  : kTransparent,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 16.0,
                  height: 16.0,
                  child: widget.isSelected
                      ? SvgPicture.asset(
                          'assets/icons/32/checkmark.svg',
                          width: 16.0,
                          height: 16.0,
                          colorFilter:
                              const ColorFilter.mode(kWhite, BlendMode.srcIn),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: 8.0),
                Expanded(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
