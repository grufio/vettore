import 'package:flutter/widgets.dart';
import 'package:grufio/icons/grufio_icons.dart';
import 'package:grufio/theme/app_theme_colors.dart';
import 'package:grufio/theme/app_theme_typography.dart';

class HoverSelectorSuffix extends StatefulWidget {
  const HoverSelectorSuffix({
    super.key,
    required this.suffixText,
    required this.iconAsset,
    required this.onTap,
    this.showAsIcon = false,
    this.onTapDownGlobal,
  });
  final String? suffixText;
  final String iconAsset;
  final VoidCallback onTap;
  final bool showAsIcon;
  final ValueChanged<Offset>? onTapDownGlobal;

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
                child: () {
                  if (widget.iconAsset == 'chevron-down') {
                    return const Icon(Grufio.chevronDown,
                        size: 12.0, color: kGrey100);
                  }
                  return const SizedBox(width: 12.0, height: 12.0);
                }(),
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
