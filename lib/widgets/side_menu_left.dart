import 'package:flutter/widgets.dart';
// ignore_for_file: always_use_package_imports
import '../icons/grufio_icons.dart';
import '../theme/app_theme_colors.dart';
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
    // Remove side panel background; only the active item has a fill.
    const Color bg = kTransparent;

    return Container(
      width: 40.0,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: bg,
        border: Border(
          right: BorderSide(color: kBordersColor),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          children: [
            _MenuIconButton(
              icon: Grufio.documentBlank,
              selected: selectedIndex == 0,
              onTap: () => onSelect(0),
            ),
            const SizedBox(height: 8.0),
            _MenuIconButton(
              icon: Grufio.image,
              selected: selectedIndex == 1,
              onTap: () => onSelect(1),
            ),
            const SizedBox(height: 8.0),
            _MenuIconButton(
              icon: Grufio.colorPalette,
              selected: selectedIndex == 2,
              onTap: () => onSelect(2),
            ),
          ],
        ),
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
    final Color iconColor = selected ? kWhite : kGrey100;
    // Row background remains transparent; selected state draws a 24×24 pill
    // behind the icon with 4px radius.
    const BoxDecoration deco = BoxDecoration(color: kTransparent);
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: deco,
        child: _CrispBox(
          w: 24.0,
          h: 24.0,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (selected)
                const DecoratedBox(
                  decoration: BoxDecoration(
                    color: kGrey100,
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                ),
              Center(
                child: Icon(
                  icon,
                  size: 20.0,
                  color: iconColor,
                ),
              ),
            ],
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
  });
  final Widget child;
  final double w;
  final double h;

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
      child: Center(child: child),
    );
  }
}

// _SnapCenterDelegate removed; using Center alignment for precise centering.
