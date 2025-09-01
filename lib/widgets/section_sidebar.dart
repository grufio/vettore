import 'package:flutter/widgets.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vettore/widgets/input_value_type.dart';
import 'package:vettore/theme/app_theme_typography.dart';

class SectionSidebar extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SectionSidebar({
    super.key,
    required this.title,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
          top: 8.0, left: 12.0, right: 12.0, bottom: 12.0),
      decoration: const BoxDecoration(
        color: kWhite,
        border: Border(
          bottom: BorderSide(color: kBordersColor, width: 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: appTextStyles.bodyMMedium.copyWith(
                fontWeight: FontWeight.bold, color: kGrey100, height: 1.0),
          ),
          if (children.isNotEmpty) const SizedBox(height: 12.0),
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 12.0),
          ],
        ],
      ),
    );
  }
}

// Row component co-located with SectionSidebar
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

  factory SectionInput.fullText({
    Key? key,
    required TextEditingController controller,
    String? placeholder,
    String? suffixText,
    String? actionIconAsset,
    VoidCallback? onActionTap,
  }) {
    return SectionInput(
      key: key,
      full: InputValueType.text(
        controller: controller,
        placeholder: placeholder,
        suffixText: suffixText,
      ),
      actionIconAsset: actionIconAsset,
      onActionTap: onActionTap,
    );
  }

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

class _ReservedActionIcon extends StatefulWidget {
  final String? asset;
  final VoidCallback? onTap;

  const _ReservedActionIcon({this.asset, this.onTap});

  @override
  State<_ReservedActionIcon> createState() => _ReservedActionIconState();
}

class _ReservedActionIconState extends State<_ReservedActionIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool hasAsset = widget.asset != null && widget.asset!.isNotEmpty;

    final Widget box = MouseRegion(
      cursor: hasAsset ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        width: 24.0,
        height: 24.0,
        decoration: BoxDecoration(
          color: _hovered && hasAsset ? kGrey10 : kTransparent,
          borderRadius: BorderRadius.circular(4.0),
        ),
        alignment: Alignment.center,
        child: hasAsset
            ? SvgPicture.asset(
                widget.asset!,
                width: 16.0,
                height: 16.0,
                colorFilter: ColorFilter.mode(
                    _hovered ? kGrey100 : kGrey70, BlendMode.srcIn),
              )
            : null,
      ),
    );

    if (!hasAsset) return box;
    if (widget.onTap == null) return box;
    return GestureDetector(onTap: widget.onTap, child: box);
  }
}
