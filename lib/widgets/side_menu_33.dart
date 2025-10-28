import 'package:flutter/widgets.dart';
import 'package:vettore/icons/grufio_icons.dart';
import 'package:vettore/theme/app_theme_colors.dart';

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
        child: SizedBox(
          width: 33.0,
          height: 32.0,
          child: Center(
            child: Icon(
              icon,
              size: 20.0,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
