import 'package:flutter/widgets.dart';
import 'package:vettore/icons/grufio_icons.dart';
import 'package:vettore/theme/app_theme_colors.dart';
// Context menus not used here; revert to simple tap only

/// 33px full-height side menu with spec styles (external widget).
class SideMenu33 extends StatelessWidget {
  const SideMenu33({
    super.key,
    required this.enabled,
    required this.selectedIndex,
    required this.onSelect,
  });

  final bool enabled;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    // New spec: whole side panel has black background; only the active item
    // has white background with a grey right border and black icon.
    const Color bg = kGrey70;

    return Container(
      width: 33.0,
      height: double.infinity,
      decoration: const BoxDecoration(color: bg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _MenuIconButton(
            icon: Grufio.documentBlank,
            selected: selectedIndex == 0,
            onTap: () => onSelect(0),
          ),
          _MenuIconButton(
            icon: Grufio.image,
            selected: selectedIndex == 1,
            onTap: () => onSelect(1),
          ),
          _MenuIconButton(
            icon: Grufio.colorPalette,
            selected: selectedIndex == 2,
            onTap: () => onSelect(2),
          ),
        ],
      ),
    );
  }
}

class _MenuIconButton extends StatelessWidget {
  const _MenuIconButton({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = selected ? kGrey100 : kWhite;
    final BoxDecoration deco = selected
        ? const BoxDecoration(
            color: kWhite,
            border: Border(right: BorderSide(color: kBordersColor)),
          )
        : const BoxDecoration(color: kGrey70);
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: deco,
        child: _CrispBox(
          w: 33.0,
          h: 32.0,
          childW: 20.0,
          childH: 20.0,
          child: Icon(
            icon,
            size: 20.0,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

class _CrispBox extends StatelessWidget {
  const _CrispBox({
    required this.child,
    required this.w,
    required this.h,
    required this.childW,
    required this.childH,
  });
  final Widget child;
  final double w;
  final double h;
  final double childW;
  final double childH;

  double _snap(BuildContext context, double logical) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    return (logical * dpr).round() / dpr;
  }

  @override
  Widget build(BuildContext context) {
    final sw = _snap(context, w);
    final sh = _snap(context, h);
    return SizedBox(
      width: sw,
      height: sh,
      child: CustomSingleChildLayout(
        delegate: _SnapCenterDelegate(
          MediaQuery.of(context).devicePixelRatio,
          childW,
          childH,
        ),
        child: child,
      ),
    );
  }
}

class _SnapCenterDelegate extends SingleChildLayoutDelegate {
  const _SnapCenterDelegate(this.dpr, this.childW, this.childH);
  final double dpr;
  final double childW;
  final double childH;
  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints.tightFor(width: childW, height: childH);
  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final dx = ((size.width - childSize.width) / 2 * dpr).round() / dpr;
    final dy = ((size.height - childSize.height) / 2 * dpr).round() / dpr;
    return Offset(dx, dy);
  }

  @override
  bool shouldRelayout(covariant _SnapCenterDelegate oldDelegate) =>
      oldDelegate.dpr != dpr;
}
