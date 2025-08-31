import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vettore/theme/app_theme_colors.dart';

class SectionInput extends StatelessWidget {
  final Widget? left;
  final Widget? right;
  final Widget? full; // optional element spanning both input areas
  final String? actionIconAsset;
  final VoidCallback? onActionTap; // Reserved for later use

  const SectionInput({
    super.key,
    this.left,
    this.right,
    this.full,
    this.actionIconAsset,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget action = _ReservedActionIcon(
      asset: actionIconAsset,
      onTap: onActionTap,
    );

    final List<Widget> children = [];

    if (full != null) {
      children.add(Expanded(flex: 2, child: full!));
    } else {
      children.addAll([
        Expanded(child: left ?? const SizedBox.shrink()),
        const SizedBox(width: 8.0),
        Expanded(child: right ?? const SizedBox.shrink()),
      ]);
    }

    children.addAll([const SizedBox(width: 8.0), action]);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}

class _ReservedActionIcon extends StatelessWidget {
  final String? asset;
  final VoidCallback? onTap;

  const _ReservedActionIcon({this.asset, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool hasAsset = asset != null && asset!.isNotEmpty;
    final Widget box = Container(
      width: 24.0,
      height: 24.0,
      decoration: BoxDecoration(
        color: hasAsset ? kGrey10 : kTransparent,
        borderRadius: BorderRadius.circular(4.0),
      ),
      alignment: Alignment.center,
      child: hasAsset
          ? SvgPicture.asset(
              asset!,
              width: 16.0,
              height: 16.0,
              colorFilter: const ColorFilter.mode(kGrey70, BlendMode.srcIn),
            )
          : null,
    );

    if (!hasAsset || onTap == null) return box;
    return GestureDetector(
        onTap: onTap, behavior: HitTestBehavior.opaque, child: box);
  }
}
