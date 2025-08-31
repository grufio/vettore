import 'package:flutter/widgets.dart';
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
  final String suffixText;

  const InputValueType({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.textAlign = TextAlign.start,
    this.autofocus = false,
    this.placeholder,
    this.suffixText = 'px',
  });

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
    _controllerListener = () {
      if (!mounted) return;
      setState(() {});
    };
    _focusListener = () {
      if (!mounted) return;
      setState(() {});
    };
    _controller.addListener(_controllerListener);
    _focusNode.addListener(_focusListener);
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
    final TextStyle textStyle =
        appTextStyles.bodyM.copyWith(color: kGrey100, height: 1.0);
    final TextStyle placeholderStyle =
        appTextStyles.bodyM.copyWith(color: kGrey60, height: 1.0);

    return Container(
      height: 24.0,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: kGrey10,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/32/color-palette.svg',
            width: 16.0,
            height: 16.0,
            colorFilter: const ColorFilter.mode(kGrey70, BlendMode.srcIn),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                if ((_controller.text.isEmpty) &&
                    !_focusNode.hasFocus &&
                    (widget.placeholder != null))
                  IgnorePointer(
                    child: Text(
                      widget.placeholder!,
                      style: placeholderStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                EditableText(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: textStyle,
                  cursorColor: kGrey100,
                  backgroundCursorColor: kGrey10,
                  selectionColor: kGrey20,
                  textAlign: widget.textAlign,
                  autofocus: widget.autofocus,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Text(
            widget.suffixText,
            style: appTextStyles.bodyM.copyWith(color: kGrey70, height: 1.0),
          ),
        ],
      ),
    );
  }
}
