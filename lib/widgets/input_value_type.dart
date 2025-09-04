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
import 'package:vettore/widgets/input_value_type/suffix.dart' as ivt_sfx;
import 'package:vettore/widgets/input_value_type/dropdown_item.dart' as ivt_di;

enum InputVariant {
  regular,
  selector,
  dropdown,
  valueDropdown,
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
  // Legacy selection toggle no longer needed
  String? _currentSuffix;
  TextEditingValue? _beforeOpenValue;
  // selection flip no longer used with overlay dropdown
  bool _usingOverlay = false;
  OverlayEntry? _dropdownEntry;

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
    // Initialize current suffix for valueDropdown/selector so something is visible when not hovering
    _currentSuffix = widget.selectedItem ??
        widget.suffixText ??
        ((widget.dropdownItems != null && widget.dropdownItems!.isNotEmpty)
            ? widget.dropdownItems!.first
            : null);
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
    // Keep _currentSuffix in sync if parent changes
    if (oldWidget.selectedItem != widget.selectedItem &&
        widget.selectedItem != null) {
      _currentSuffix = widget.selectedItem;
    } else if (oldWidget.suffixText != widget.suffixText &&
        _currentSuffix == null) {
      _currentSuffix = widget.suffixText ??
          ((widget.dropdownItems != null && widget.dropdownItems!.isNotEmpty)
              ? widget.dropdownItems!.first
              : null);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_controllerListener);
    _focusNode.removeListener(_focusListener);
    _removeDropdown();
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
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (!isReadOnly) {
                      _focusNode.requestFocus();
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
                            onSubmitted: isReadOnly ? null : widget.onSubmitted,
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
        return ivt_sfx.HoverSelectorSuffix(
          suffixText: widget.suffixText,
          iconAsset: iconAsset,
          onTap: _openOptions,
          showAsIcon: _usingOverlay || _forceOpen || _focusNode.hasFocus,
        );
      case InputVariant.dropdown:
        if (!hasDropdown) return const SizedBox.shrink();
        return _IconSuffixButton(
          iconAsset: iconAsset,
          onTap: _openOptions,
        );
      case InputVariant.valueDropdown:
        if (!hasDropdown) {
          if (_currentSuffix == null) return const SizedBox.shrink();
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 8.0),
              Text(
                _currentSuffix!,
                style: appTextStyles.bodyM.copyWith(
                    color: isReadOnly ? kGrey70 : kGrey70, height: 1.0),
              ),
            ],
          );
        }
        return ivt_sfx.HoverSelectorSuffix(
          suffixText: _currentSuffix,
          iconAsset: iconAsset,
          onTap: _openOptions,
          showAsIcon: _usingOverlay || _forceOpen || _focusNode.hasFocus,
        );
    }
  }

  void _openOptions() {
    if (widget.readOnly) return;
    if ((widget.dropdownItems ?? const <String>[]).isEmpty) return;
    _focusNode.requestFocus();
    _beforeOpenValue = _controller.value;
    setState(() {
      _usingOverlay = true;
    });
    _showOverlayDropdown();
  }

  void _showOverlayDropdown() {
    _removeDropdown();
    final items = widget.dropdownItems ?? const <String>[];
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
    _dropdownEntry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: Stack(
            children: [
              GestureDetector(
                  onTap: _removeDropdown, behavior: HitTestBehavior.opaque),
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, offsetY),
                child: Material(
                  color: kTransparent,
                  child: Semantics(
                    container: true,
                    label: 'Options',
                    child: SizedBox(
                      width: 100.0,
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 280),
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
                            final bool isSelected = (value ==
                                (widget.selectedItem ?? _currentSuffix));
                            return ivt_di.DropdownItem(
                              label: value,
                              isSelected: isSelected,
                              highlighted: false,
                              onHover: () {},
                              onTap: () {
                                widget.onItemSelected?.call(value);
                                if (widget.variant ==
                                    InputVariant.valueDropdown) {
                                  setState(() => _currentSuffix = value);
                                }
                                _removeDropdown();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    Overlay.of(context).insert(_dropdownEntry!);
  }

  void _removeDropdown() {
    _dropdownEntry?.remove();
    _dropdownEntry = null;
    if (_usingOverlay) {
      setState(() => _usingOverlay = false);
    }
    if (_beforeOpenValue != null) {
      final restore = _beforeOpenValue!;
      _beforeOpenValue = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _controller.value = restore;
      });
    }
  }

  // Removed legacy overlay and keyboard navigation helpers
}

// Removed legacy _DropdownPanel; RawAutocomplete's optionsViewBuilder is used

// Legacy, kept for compatibility; replaced by DropdownItem in separate file
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

// HoverSelectorSuffix and DropdownItem moved to input_value_type/ subfolder
