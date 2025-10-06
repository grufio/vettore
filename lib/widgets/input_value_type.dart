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
import 'package:vettore/widgets/input_value_type/controller.dart';
import 'package:vettore/widgets/input_value_type/dropdown_overlay.dart'
    as ivt_ovl;

/// Visual/behavior variants for the right-side affordance.
/// - regular: fixed suffix text (if provided), no dropdown.
/// - selector: suffix text that turns into a chevron on hover; opens dropdown.
/// - dropdown: chevron-only suffix; opens dropdown.
enum InputVariant {
  regular,
  selector,
  dropdown,
}

// (Removed old Shortcuts/Actions intents; RawAutocomplete now manages keys)

/// Input field with optional dropdown behaviors and custom suffix.
///
/// When [dropdownItems] is provided, the suffix acts based on [variant]:
/// - [InputVariant.selector] shows suffix text that flips to a chevron on hover.
/// - [InputVariant.dropdown] shows only a chevron.
/// For read-only mode, selection/cursor are disabled and the caret is hidden.
class InputValueType extends StatefulWidget {
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
  final BoxFit? prefixIconFit;
  final AlignmentGeometry? prefixIconAlignment;
  final bool readOnly;
  // When false, user cannot select/mark the text (cursor hidden, no selection handles)
  final bool enableSelection;
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
    this.prefixIconFit,
    this.prefixIconAlignment,
    this.readOnly = false,
    this.enableSelection = true,
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
      enableSelection: true,
    );
  }

  @override
  State<InputValueType> createState() => _InputValueTypeState();
}

// Controller moved to input_value_type/controller.dart

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
  // Persist selected item (for checkmark) across openings, even if parent doesn't manage it
  String? _selectedItem;
  TextEditingValue? _beforeOpenValue;
  // selection flip no longer used with overlay dropdown
  bool _usingOverlay = false;
  OverlayEntry? _dropdownEntry;
  // Keyboard navigation
  final ValueNotifier<int?> _highlightedIndex = ValueNotifier<int?>(null);
  ScrollController? _listScrollController;
  Offset? _lastTapGlobal;
  FocusNode? _overlayFocusNode;

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
    widget.dropdownController?.attach(
      () => _focusNode.requestFocus(),
      () => _focusNode.unfocus(),
      () => _focusNode.hasFocus
          ? _focusNode.unfocus()
          : _focusNode.requestFocus(),
      _highlightNext,
      _highlightPrev,
      _confirmHighlighted,
    );
    // Initialize persisted selection for highlighting
    _selectedItem = widget.selectedItem ??
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
        // Ensure any open overlay is closed when becoming read-only
        _removeDropdown();
      }
    }
    // Keep selection in sync if parent changes
    if (oldWidget.selectedItem != widget.selectedItem &&
        widget.selectedItem != null) {
      _selectedItem = widget.selectedItem;
    }

    // If dropdownItems changed, ensure selection still valid. In controlled mode,
    // rely on widget.selectedItem. In uncontrolled, clamp to first available.
    final List<String> oldItems = oldWidget.dropdownItems ?? const <String>[];
    final List<String> newItems = widget.dropdownItems ?? const <String>[];
    if (!_listEquals(oldItems, newItems)) {
      if (widget.selectedItem != null) {
        // Controlled: if selectedItem not in new list, do nothing here (parent should update)
      } else {
        // Uncontrolled: ensure internal selection and suffix are valid
        if (_selectedItem != null && !newItems.contains(_selectedItem)) {
          _selectedItem = newItems.isNotEmpty ? newItems.first : null;
        }
      }
      // If dropdown items became empty, close any open overlay
      if (newItems.isEmpty) {
        _removeDropdown();
      }
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
    _highlightedIndex.dispose();
    _listScrollController?.dispose();
    _overlayFocusNode?.dispose();
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
              fit: widget.prefixIconFit ?? BoxFit.none,
              alignment: widget.prefixIconAlignment ?? Alignment.centerLeft,
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
                            enableInteractiveSelection:
                                !isReadOnly && widget.enableSelection,
                            showCursor: !isReadOnly && widget.enableSelection,
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
          showAsIcon: (_dropdownEntry != null) || _usingOverlay || _forceOpen,
          onTapDownGlobal: (pos) => _lastTapGlobal = pos,
        );
      case InputVariant.dropdown:
        if (!hasDropdown) return const SizedBox.shrink();
        return _IconSuffixButton(
          iconAsset: iconAsset,
          onTap: _openOptions,
          onTapDown: (details) => _lastTapGlobal = details.globalPosition,
        );
    }
  }

  void _openOptions() {
    if (widget.readOnly) return;
    if ((widget.dropdownItems ?? const <String>[]).isEmpty) return;
    if (_dropdownEntry != null) return; // prevent double-insert while open
    _beforeOpenValue = _controller.value;
    setState(() {
      _usingOverlay = true;
    });
    _showOverlayDropdown();
  }

  void _showOverlayDropdown() {
    _removeDropdown();
    final items = widget.dropdownItems ?? const <String>[];
    // Determine selection basis for initial highlight
    final String selectionBasis =
        (widget.selectedItem ?? _selectedItem ?? _controller.text);
    // Determine initial highlighted index
    final int initialIndex =
        selectionBasis != null ? items.indexOf(selectionBasis) : -1;
    _highlightedIndex.value = initialIndex >= 0 ? initialIndex : 0;
    // Recreate list scroll controller with initial offset to avoid jump animation
    _listScrollController?.dispose();
    final double initialOffset =
        (_highlightedIndex.value ?? 0) * ivt_ovl.kDropdownItemHeight;
    _listScrollController =
        ScrollController(initialScrollOffset: initialOffset);
    _overlayFocusNode?.dispose();
    _overlayFocusNode = FocusNode();
    _dropdownEntry = ivt_ovl.createDropdownOverlay(
      context: context,
      layerLink: _layerLink,
      targetKey: _targetKey,
      items: items,
      selectedValue: selectionBasis,
      isValueDropdownVariant: false,
      onItemSelected: (value) {
        widget.onItemSelected?.call(value);
        setState(() {
          // Only update internal selection when uncontrolled
          if (widget.selectedItem == null) {
            _selectedItem = value;
          }
        });
        // Return focus to the input field after a selection
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _focusNode.requestFocus();
        });
      },
      onDismiss: _removeDropdown,
      panelWidth: ivt_ovl.kDropdownPanelWidth,
      highlightedIndexListenable: _highlightedIndex,
      listScrollController: _listScrollController,
      onHighlightNext: _highlightNext,
      onHighlightPrev: _highlightPrev,
      onHighlightHome: () {
        _highlightedIndex.value = 0;
        _markOverlayNeedsBuild();
      },
      onHighlightEnd: () {
        final items = widget.dropdownItems ?? const <String>[];
        if (items.isEmpty) return;
        _highlightedIndex.value = items.length - 1;
        _markOverlayNeedsBuild();
      },
      onConfirm: _confirmHighlighted,
      onEscape: _removeDropdown,
      centerGlobal: _lastTapGlobal,
      focusNode: _overlayFocusNode,
    );
    if (!mounted) return;
    // Insert only if not already mounted
    if (!(_dropdownEntry!.mounted)) {
      Overlay.of(context).insert(_dropdownEntry!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlayFocusNode?.requestFocus();
    });
    _markOverlayNeedsBuild();
  }

  void _removeDropdown() {
    ivt_ovl.removeDropdownOverlay(_dropdownEntry);
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

  // Keyboard helpers
  void _highlightNext() {
    final items = widget.dropdownItems ?? const <String>[];
    if (items.isEmpty) return;
    final int current = _highlightedIndex.value ?? -1;
    final int next = (current + 1).clamp(0, items.length - 1);
    _highlightedIndex.value = next;
    _markOverlayNeedsBuild();
  }

  void _highlightPrev() {
    final items = widget.dropdownItems ?? const <String>[];
    if (items.isEmpty) return;
    final int current = _highlightedIndex.value ?? 0;
    final int prev = (current - 1).clamp(0, items.length - 1);
    _highlightedIndex.value = prev;
    _markOverlayNeedsBuild();
  }

  void _confirmHighlighted() {
    final items = widget.dropdownItems ?? const <String>[];
    final int idx = _highlightedIndex.value ?? -1;
    if (idx < 0 || idx >= items.length) return;
    final String value = items[idx];
    widget.onItemSelected?.call(value);
    setState(() {
      if (widget.selectedItem == null) {
        _selectedItem = value;
      }
    });
    _removeDropdown();
    // Return focus to the input field after confirm
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
    });
  }

  void _markOverlayNeedsBuild() {
    _dropdownEntry?.markNeedsBuild();
  }

  // Removed legacy overlay and keyboard navigation helpers
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

// Removed legacy _DropdownPanel; RawAutocomplete's optionsViewBuilder is used

// Legacy, kept for compatibility; replaced by DropdownItem in separate file
class _IconSuffixButton extends StatefulWidget {
  final String iconAsset;
  final VoidCallback onTap;
  final void Function(TapDownDetails)? onTapDown;
  const _IconSuffixButton(
      {required this.iconAsset, required this.onTap, this.onTapDown});

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
        onTapDown: widget.onTapDown,
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
