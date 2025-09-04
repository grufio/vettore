import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vettore/theme/app_theme_typography.dart';
import 'package:vettore/theme/app_theme_colors.dart';

class HoverSelectorSuffix extends StatefulWidget {
  final String? suffixText;
  final String iconAsset;
  final VoidCallback onTap;
  final bool showAsIcon;
  final ValueChanged<Offset>? onTapDownGlobal;
  const HoverSelectorSuffix({
    super.key,
    required this.suffixText,
    required this.iconAsset,
    required this.onTap,
    this.showAsIcon = false,
    this.onTapDownGlobal,
  });

  @override
  State<HoverSelectorSuffix> createState() => _HoverSelectorSuffixState();
}

class _HoverSelectorSuffixState extends State<HoverSelectorSuffix> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bool showIcon = _hover || widget.showAsIcon;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (details) =>
            widget.onTapDownGlobal?.call(details.globalPosition),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8.0),
            if (showIcon)
              SizedBox(
                width: 12.0,
                height: 12.0,
                child: SvgPicture.asset(
                  widget.iconAsset,
                  width: 12.0,
                  height: 12.0,
                  colorFilter:
                      const ColorFilter.mode(kGrey100, BlendMode.srcIn),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 12.0),
                child: SizedBox(
                  height: 12.0,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: widget.suffixText != null
                        ? Text(
                            widget.suffixText!,
                            style: appTextStyles.bodyM
                                .copyWith(color: kGrey70, height: 1.0),
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
