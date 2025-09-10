import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vettore/theme/app_theme_colors.dart';

class ButtonToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String onIconAsset; // shown when value == true (linked)
  final String offIconAsset; // shown when value == false (unlinked)
  final bool disabled;

  const ButtonToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.onIconAsset = 'assets/icons/32/link.svg',
    this.offIconAsset = 'assets/icons/32/unlink.svg',
    this.disabled = false,
  });

  @override
  State<ButtonToggle> createState() => _ButtonToggleState();
}

class _ButtonToggleState extends State<ButtonToggle> {
  bool _hovered = false;

  void _toggle() => widget.onChanged(!widget.value);

  @override
  Widget build(BuildContext context) {
    final String asset =
        widget.value ? widget.onIconAsset : widget.offIconAsset;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = widget.disabled ? false : true),
      onExit: (_) => setState(() => _hovered = false),
      child: Semantics(
        button: true,
        label: widget.value ? 'Unlink dimensions' : 'Link dimensions',
        enabled: !widget.disabled,
        onTap: widget.disabled ? null : _toggle,
        child: GestureDetector(
          onTap: widget.disabled ? null : _toggle,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              color: _hovered && !widget.disabled ? kGrey10 : kTransparent,
              borderRadius: BorderRadius.circular(4.0),
              border: widget.value && !widget.disabled
                  ? Border.all(color: kBordersColor, width: 1.0)
                  : null,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              asset,
              width: 16.0,
              height: 16.0,
              colorFilter: ColorFilter.mode(
                widget.disabled ? kGrey70 : (_hovered ? kGrey100 : kGrey70),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
