import 'package:flutter/widgets.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vettore/widgets/input_value_type/input_value_type.dart';
import 'package:vettore/theme/app_theme_typography.dart';

class SectionSidebar extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool showTitleToggle;
  final bool titleToggleOn;
  final ValueChanged<bool>? onTitleToggle;

  const SectionSidebar({
    super.key,
    required this.title,
    this.children = const [],
    this.showTitleToggle = false,
    this.titleToggleOn = true,
    this.onTitleToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
          top: 12.0, left: 12.0, right: 12.0, bottom: 12.0),
      decoration: const BoxDecoration(
        color: kWhite,
        border: Border(
          bottom: BorderSide(color: kBordersColor, width: 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                title,
                style: appTextStyles.bodyMMedium.copyWith(
                    fontWeight: FontWeight.bold, color: kGrey100, height: 1.0),
              ),
              const Spacer(),
              if (showTitleToggle)
                _TitleToggle(
                  on: titleToggleOn,
                  onChanged: onTitleToggle,
                ),
            ],
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
  final Widget? action; // optional custom trailing action
  final String? actionIconAsset;
  final VoidCallback? onActionTap; // Reserved for later use
  final bool actionDisabled;

  const SectionInput({
    super.key,
    this.left,
    this.right,
    this.full,
    this.action,
    this.actionIconAsset,
    this.onActionTap,
    this.actionDisabled = false,
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

    // Always reserve trailing action slot to match Title row
    final Widget trailing = action ??
        _ReservedActionIcon(
          asset: actionIconAsset,
          onTap: actionDisabled ? null : onActionTap,
          disabled: actionDisabled,
        );
    children.addAll([const SizedBox(width: 8.0), trailing]);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}

class _ReservedActionIcon extends StatefulWidget {
  final String? asset;
  final VoidCallback? onTap;
  final bool disabled;

  const _ReservedActionIcon({this.asset, this.onTap, this.disabled = false});

  @override
  State<_ReservedActionIcon> createState() => _ReservedActionIconState();
}

class _ReservedActionIconState extends State<_ReservedActionIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool hasAsset = widget.asset != null && widget.asset!.isNotEmpty;

    final Widget box = MouseRegion(
      cursor: hasAsset && !widget.disabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = widget.disabled ? false : true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        width: 24.0,
        height: 24.0,
        decoration: BoxDecoration(
          color:
              _hovered && hasAsset && !widget.disabled ? kGrey10 : kTransparent,
          borderRadius: BorderRadius.circular(4.0),
        ),
        alignment: Alignment.center,
        child: hasAsset
            ? SvgPicture.asset(
                widget.asset!,
                width: 16.0,
                height: 16.0,
                colorFilter: ColorFilter.mode(
                    widget.disabled ? kGrey70 : (_hovered ? kGrey100 : kGrey70),
                    BlendMode.srcIn),
              )
            : null,
      ),
    );

    if (!hasAsset) return box;
    if (widget.onTap == null || widget.disabled) return box;
    return GestureDetector(onTap: widget.onTap, child: box);
  }
}

class _TitleToggle extends StatefulWidget {
  final bool on;
  final ValueChanged<bool>? onChanged;
  const _TitleToggle({required this.on, this.onChanged});

  @override
  State<_TitleToggle> createState() => _TitleToggleState();
}

class _TitleToggleState extends State<_TitleToggle> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final String asset = widget.on
        ? 'assets/icons/32/view.svg'
        : 'assets/icons/32/view--off.svg';
    final Widget box = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: _hover ? kGrey10 : kTransparent,
          borderRadius: BorderRadius.circular(4.0),
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          asset,
          width: 16,
          height: 16,
          colorFilter: const ColorFilter.mode(kGrey70, BlendMode.srcIn),
        ),
      ),
    );
    return GestureDetector(
      onTap: () => widget.onChanged?.call(!widget.on),
      child: box,
    );
  }
}
