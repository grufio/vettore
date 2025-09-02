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

class _InputValueTypeState extends State<InputValueType> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final VoidCallback _controllerListener;
  late final VoidCallback _focusListener;

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
        final int end = _controller.text.length;
        _controller.selection = const TextSelection.collapsed(offset: 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_controllerListener);
    _focusNode.removeListener(_focusListener);
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

    return Container(
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
            colorFilter: ColorFilter.mode(
                isReadOnly ? kGrey70 : kGrey70, BlendMode.srcIn),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: MouseRegion(
              cursor: isReadOnly
                  ? SystemMouseCursors.basic
                  : SystemMouseCursors.text,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  if (_controller.text.isEmpty && widget.placeholder != null)
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
          if (widget.suffixText != null) ...[
            const SizedBox(width: 8.0),
            Text(
              widget.suffixText!,
              style: appTextStyles.bodyM
                  .copyWith(color: isReadOnly ? kGrey70 : kGrey70, height: 1.0),
            ),
          ],
        ],
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
}
