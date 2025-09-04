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
// Removed: keyboard services, handled by RawAutocomplete and TextField
// Removed: async utilities
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/theme/app_theme_typography.dart';

enum InputVariant {
  regular,
  selector,
  dropdown,
}

// (Removed old Shortcuts/Actions intents; RawAutocomplete now manages keys)

class InputValueType extends StatefulWidget {
  // Visual/behavior variants for the right-side affordance
  // regular: just suffix text (if provided)
  // selector: suffix text by default; on hover shows dropdown icon; click opens dropdown
  // dropdownIconOnly: only shows dropdown icon; click opens dropdown
  static const InputVariant defaultVariant = InputVariant.regular;
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
  final InputVariant variant;
  final String? dropdownIconAsset;

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
    this.variant = InputValueType.defaultVariant,
    this.dropdownIconAsset,
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
  late final VoidCallback _controllerListener;
  late final VoidCallback _focusListener;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _targetKey = GlobalKey();
  // Dropdown is driven by RawAutocomplete; no direct guard needed.
  // Deprecated overlay/highlight state removed with RawAutocomplete
  bool _forceOpen = false;
  bool _selectionToggle = false;

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
        if (_forceOpen) {
          setState(() => _forceOpen = false);
        }
      }
      setState(() {});
    };
    _controller.addListener(_controllerListener);
    _focusNode.addListener(_focusListener);
    // Attach controller if present
    widget.dropdownController?._attach(
      () => _focusNode.requestFocus(),
      () => _focusNode.unfocus(),
      () => _focusNode.hasFocus
          ? _focusNode.unfocus()
          : _focusNode.requestFocus(),
      () {},
      () {},
      () {},
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
    // Overlay and keyboard nodes removed in RawAutocomplete version
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

    return RawAutocomplete<String>(
      textEditingController: _controller,
      focusNode: _focusNode,
      optionsBuilder: (TextEditingValue value) {
        if (isReadOnly) return const Iterable<String>.empty();
        final items = widget.dropdownItems ?? const <String>[];
        if (items.isEmpty) return const Iterable<String>.empty();
        final q = value.text.trim().toLowerCase();
        if (_forceOpen || q.isEmpty) return items;
        return items.where((s) => s.toLowerCase().startsWith(q));
      },
      displayStringForOption: (s) => s,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
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
                    : (focusNode.hasFocus ? kInputFocus : kTransparent),
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
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        if (!isReadOnly) {
                          focusNode.requestFocus();
                        }
                      },
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          if (controller.text.isEmpty &&
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
                                controller: controller,
                                focusNode: focusNode,
                                style: textStyle,
                                cursorColor:
                                    isReadOnly ? kTransparent : kGrey100,
                                decoration: const InputDecoration(
                                  isCollapsed: true,
                                  isDense: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                textAlign: widget.textAlign,
                                autofocus:
                                    isReadOnly ? false : widget.autofocus,
                                onChanged: isReadOnly ? null : widget.onChanged,
                                onSubmitted:
                                    isReadOnly ? null : widget.onSubmitted,
                                readOnly: isReadOnly,
                                enableInteractiveSelection: !isReadOnly,
                                showCursor: !isReadOnly,
                                selectionControls:
                                    materialTextSelectionControls,
                                enabled: !isReadOnly,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildSuffix(isReadOnly),
              ],
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final List<String> items = options.toList();
        final Size screenSize = MediaQuery.of(context).size;
        const double itemHeight = 28.0;
        const int maxVisible = 8;
        final int visibleCount =
            items.length < maxVisible ? items.length : maxVisible;
        final double estimatedPanelHeight = 8 + (visibleCount * itemHeight) + 8;
        double offsetY = 28;
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
        return CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, offsetY),
          child: Material(
            color: kTransparent,
            child: Semantics(
              container: true,
              label: 'Options',
              child: Container(
                constraints:
                    const BoxConstraints(maxHeight: 280, minWidth: 160),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: kGrey100,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final value = items[index];
                    final bool isSelected = (value == widget.selectedItem);
                    return _DropdownItem(
                      label: value,
                      isSelected: isSelected,
                      highlighted: false,
                      onHover: () {},
                      onTap: () => onSelected(value),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
      onSelected: (value) {
        widget.onItemSelected?.call(value);
        if (_forceOpen) setState(() => _forceOpen = false);
      },
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
    final bool hasDropdown =
        (widget.dropdownItems != null && widget.dropdownItems!.isNotEmpty) &&
            !isReadOnly;
    final String iconAsset =
        widget.dropdownIconAsset ?? 'assets/icons/32/chevron--down.svg';

    switch (widget.variant) {
      case InputVariant.regular:
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
      case InputVariant.selector:
        if (!hasDropdown) {
          // Fallback to regular suffix text when no dropdown
          if (widget.suffixText == null) return const SizedBox.shrink();
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 8.0),
              Text(
                widget.suffixText!,
                style: appTextStyles.bodyM.copyWith(
                    color: isReadOnly ? kGrey70 : kGrey70, height: 1.0),
              ),
            ],
          );
        }
        return _HoverSelectorSuffix(
          suffixText: widget.suffixText,
          iconAsset: iconAsset,
          onTap: _openOptions,
        );
      case InputVariant.dropdown:
        if (!hasDropdown) return const SizedBox.shrink();
        return _IconSuffixButton(
          iconAsset: iconAsset,
          onTap: _openOptions,
        );
    }
  }

  void _openOptions() {
    if (widget.readOnly) return;
    if ((widget.dropdownItems ?? const <String>[]).isEmpty) return;
    setState(() => _forceOpen = true);
    _focusNode.requestFocus();
    // Force RawAutocomplete to recompute options by changing text value to same
    _controller.value = _controller.value.copyWith(
      text: _controller.text,
      selection: TextSelection.collapsed(offset: _controller.text.length),
      composing: TextRange.empty,
    );
  }

  // Removed legacy overlay and keyboard navigation helpers
}

// Removed legacy _DropdownPanel; RawAutocomplete's optionsViewBuilder is used

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

class _IconSuffixButton extends StatefulWidget {
  final String iconAsset;
  final VoidCallback onTap;
  const _IconSuffixButton({required this.iconAsset, required this.onTap});

  @override
  State<_IconSuffixButton> createState() => _IconSuffixButtonState();
}

class _IconSuffixButtonState extends State<_IconSuffixButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(left: 8.0),
          width: 12.0,
          height: 12.0,
          decoration: BoxDecoration(
            color: _hover ? kGrey10 : kTransparent,
            borderRadius: BorderRadius.circular(4.0),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            widget.iconAsset,
            width: 12.0,
            height: 12.0,
            colorFilter:
                ColorFilter.mode(_hover ? kGrey100 : kGrey70, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

class _HoverSelectorSuffix extends StatefulWidget {
  final String? suffixText;
  final String iconAsset;
  final VoidCallback onTap;
  const _HoverSelectorSuffix(
      {required this.suffixText, required this.iconAsset, required this.onTap});

  @override
  State<_HoverSelectorSuffix> createState() => _HoverSelectorSuffixState();
}

class _HoverSelectorSuffixState extends State<_HoverSelectorSuffix> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 120),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _hover
              ? Container(
                  key: const ValueKey('icon'),
                  margin: const EdgeInsets.only(left: 8.0),
                  width: 12.0,
                  height: 12.0,
                  decoration: BoxDecoration(
                    color: kGrey10,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    widget.iconAsset,
                    width: 12.0,
                    height: 12.0,
                    colorFilter:
                        const ColorFilter.mode(kGrey100, BlendMode.srcIn),
                  ),
                )
              : Row(
                  key: const ValueKey('text'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 8.0),
                    if (widget.suffixText != null)
                      Text(
                        widget.suffixText!,
                        style: appTextStyles.bodyM
                            .copyWith(color: kGrey70, height: 1.0),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
