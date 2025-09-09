import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vettore/theme/app_theme_colors.dart';

class ButtonToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String onIconAsset; // shown when value == true (linked)
  final String offIconAsset; // shown when value == false (unlinked)

  const ButtonToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.onIconAsset = 'assets/icons/32/link.svg',
    this.offIconAsset = 'assets/icons/32/unlink.svg',
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
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _toggle,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 24.0,
          height: 24.0,
          decoration: BoxDecoration(
            color: _hovered ? kGrey10 : kTransparent,
            borderRadius: BorderRadius.circular(4.0),
            border: widget.value
                ? Border.all(color: kBordersColor, width: 1.0)
                : null,
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            asset,
            width: 16.0,
            height: 16.0,
            colorFilter: ColorFilter.mode(
              _hovered ? kGrey100 : kGrey70,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
