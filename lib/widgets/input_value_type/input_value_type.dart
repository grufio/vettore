import 'package:flutter/material.dart'
    show
        Material,
        MaterialType,
        TextField,
        InputDecoration,
        InputBorder,
        materialTextSelectionControls,
        TextCapitalization;
import 'package:flutter/services.dart' show TextInputFormatter;
import 'package:flutter/widgets.dart';
import 'package:vettore/icons/grufio_icons.dart';
// Removed: keyboard services, handled by RawAutocomplete and TextField
// Removed: async utilities
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/theme/app_theme_typography.dart';
import 'package:vettore/widgets/input_value_type/controller.dart';
import 'package:vettore/widgets/input_value_type/dropdown_overlay.dart'
    as ivt_ovl;
import 'package:vettore/widgets/input_value_type/prefix_icon.dart';
import 'package:vettore/widgets/input_value_type/suffix.dart' as ivt_sfx;

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
    this.prefixIconAsset,
    this.prefixIconFit,
    this.prefixIconAlignment,
    this.prefixIconWidth,
    this.prefixIconHeight,
    this.maxLength,
    this.textCapitalization,
    this.readOnly = false,
    this.enableSelection = true,
    this.dropdownItems,
    this.selectedItem,
    this.onItemSelected,
    this.dropdownController,
    this.variant = InputValueType.defaultVariant,
    this.dropdownIconAsset,
    this.suffixKey,
    this.readOnlyView = false,
    this.inputFormatters,
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
    String prefixIconAsset = 'document-blank',
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
    );
  }
  static const InputVariant defaultVariant = InputVariant.regular;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextAlign textAlign;
  final bool autofocus;
  final String? placeholder;
  final String? suffixText;
  final String? prefixIconAsset;
  final BoxFit? prefixIconFit;
  final AlignmentGeometry? prefixIconAlignment;
  final double? prefixIconWidth;
  final double? prefixIconHeight;
  final int? maxLength;
  final TextCapitalization? textCapitalization;
  final bool readOnly;
  // When false, user cannot select/mark the text (cursor hidden, no selection handles)
  final bool enableSelection;
  // Dropdown support (optional). If provided, tapping the field opens a dropdown.
  final List<String>? dropdownItems;
  // Optional input formatters for the internal TextField
  final List<TextInputFormatter>? inputFormatters;
  final String? selectedItem;
  final ValueChanged<String>? onItemSelected;
  final InputDropdownController? dropdownController;
  final InputVariant variant;
  final String? dropdownIconAsset;
  // Testing/targeting aid: stable key for the tappable suffix widget
  final Key? suffixKey;
  // Read-only visual mode: white bg, visible border, grey70 text/icons, no interactions
  final bool readOnlyView;

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
  bool _hoverField = false;
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
    // Initialize current suffix for valueDropdown/selector so something is visible when not hovering
    // Initialize persisted selection for highlighting
    // Initialize internal selection only when uncontrolled. In controlled
    // mode (selectedItem provided), render strictly from widget.selectedItem.
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
      }
    }
    // Keep selection in sync if parent changes
    // Controlled mode: reflect external selection changes immediately.
    if (oldWidget.selectedItem != widget.selectedItem) {
      if (widget.selectedItem != null) {
        _selectedItem = widget.selectedItem;
      }
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
        // no-op for selector/dropdown
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
    final bool isReadOnly = widget.readOnly || widget.readOnlyView;
    final TextStyle textStyle = appTextStyles.bodyM.copyWith(
      color: widget.readOnlyView ? kGrey70 : (isReadOnly ? kGrey70 : kGrey100),
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

    // Determine if field has dropdown (unused since borders and bg are unified)
    // Borders removed globally; keep variable removed

    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoverField = true),
        onExit: (_) => setState(() => _hoverField = false),
        child: Container(
          key: _targetKey,
          height: 24.0,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: widget.readOnlyView ? kWhite : kGrey10,
            borderRadius: BorderRadius.circular(4.0),
            border: widget.readOnlyView
                ? Border.all(color: kBordersColor)
                : Border.all(
                    color: _focusNode.hasFocus
                        ? kInputFocus
                        : (_hoverField ? kBordersColor : kTransparent),
                  ),
          ),
          child: Row(
            children: [
              // Always show a prefix icon; default substitutes the label
              ...[
                PrefixIcon(
                  asset: widget.prefixIconAsset ?? 'help',
                  size: widget.prefixIconWidth ?? 16.0,
                  fit: widget.prefixIconFit ?? BoxFit.none,
                  alignment: widget.prefixIconAlignment ?? Alignment.centerLeft,
                ),
                const SizedBox(width: 8.0),
              ],
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
                              onSubmitted:
                                  isReadOnly ? null : widget.onSubmitted,
                              maxLength: widget.maxLength,
                              textCapitalization: widget.textCapitalization ??
                                  TextCapitalization.none,
                              readOnly: isReadOnly,
                              enableInteractiveSelection:
                                  !isReadOnly && widget.enableSelection,
                              showCursor: !isReadOnly && widget.enableSelection,
                              selectionControls: materialTextSelectionControls,
                              enabled: !isReadOnly,
                              inputFormatters: widget.inputFormatters,
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
            !widget.readOnlyView;
    Widget suffixTextRow(String text) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8.0),
          Text(
            text,
            style: appTextStyles.bodyM.copyWith(color: kGrey70, height: 1.0),
          ),
        ],
      );
    }

    final String iconAsset = widget.dropdownIconAsset ?? 'chevron-down';

    switch (widget.variant) {
      case InputVariant.regular:
        if (widget.suffixText == null) return const SizedBox.shrink();
        return suffixTextRow(widget.suffixText!);
      case InputVariant.selector:
        if (!hasDropdown) {
          // Fallback to regular suffix text when no dropdown
          if (widget.suffixText == null) return const SizedBox.shrink();
          return suffixTextRow(widget.suffixText!);
        }
        return ivt_sfx.HoverSelectorSuffix(
          key: widget.suffixKey,
          suffixText: widget.suffixText,
          iconAsset: iconAsset,
          onTap: _openOptions,
          showAsIcon: (_dropdownEntry != null) || _usingOverlay || _forceOpen,
          onTapDownGlobal: (pos) => _lastTapGlobal = pos,
        );
      case InputVariant.dropdown:
        if (!hasDropdown) return const SizedBox.shrink();
        return _IconSuffixButton(
          key: widget.suffixKey,
          iconAsset: iconAsset,
          onTap: _openOptions,
          onTapDown: (details) => _lastTapGlobal = details.globalPosition,
        );
    }
  }

  void _openOptions() {
    if (widget.readOnlyView) return;
    if ((widget.dropdownItems ?? const <String>[]).isEmpty) return;
    _beforeOpenValue = _controller.value;
    setState(() {
      _usingOverlay = true;
    });
    _showOverlayDropdown();
  }

  void _showOverlayDropdown() {
    _removeDropdown();
    final items = widget.dropdownItems ?? const <String>[];
    // For valueDropdown, prefer the currently displayed suffix; otherwise use
    // explicit selectedItem, internal selection, or fall back to field text.
    // Always derive the visible selection from controlled selectedItem when
    // provided, otherwise fall back to internal state.
    final String selectionBasis =
        (widget.selectedItem ?? _selectedItem ?? _controller.text);
    // Determine initial highlighted index
    final int initialIndex = items.indexOf(selectionBasis);
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
        // Only update internal selection when uncontrolled
        if (widget.selectedItem == null) {
          setState(() {
            _selectedItem = value;
          });
        }
        // Return focus to the input field after a selection
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _focusNode.requestFocus();
        });
      },
      onDismiss: _removeDropdown,
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
    Overlay.of(context).insert(_dropdownEntry!);
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
  const _IconSuffixButton({
    super.key,
    required this.iconAsset,
    required this.onTap,
    this.onTapDown,
  });
  final String iconAsset;
  final VoidCallback onTap;
  final void Function(TapDownDetails)? onTapDown;

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
          child: () {
            final Color color = _hover ? kGrey100 : kGrey70;
            if (widget.iconAsset == 'chevron-down') {
              return Icon(Grufio.chevronDown, size: 12.0, color: color);
            }
            return const SizedBox(width: 12.0, height: 12.0);
          }(),
        ),
      ),
    );
  }
}

// HoverSelectorSuffix and DropdownItem moved to input_value_type/ subfolder
