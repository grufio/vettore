import 'package:flutter/material.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/theme/app_theme_typography.dart';

/// Active filter chip
/// - height: 20px
/// - padding left/right: 8px
/// - font: medium 12px, color kGrey90
/// - background: kChipActiveBackground
class ContentChip extends StatefulWidget {
  const ContentChip.active({super.key, required this.label}) : isActive = true;
  const ContentChip.inactive({super.key, required this.label})
      : isActive = false;
  final String label;
  final bool isActive;

  @override
  State<ContentChip> createState() => _ContentChipState();
}

class _ContentChipState extends State<ContentChip> {
  bool _isHovered = false;

  @override
  void didUpdateWidget(covariant ContentChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When a chip transitions from active -> inactive, clear any stale hover
    if (oldWidget.isActive && !widget.isActive) {
      _isHovered = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = widget.isActive
        ? appTextStyles.bodyMMedium
        : appTextStyles.bodyMMedium.copyWith(color: kGrey60);

    final child = Container(
      height: 20.0,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.isActive
            ? kChipActiveBackground
            : (_isHovered ? kChipHoverBackground : kTransparent),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        widget.label,
        style: textStyle,
        strutStyle: const StrutStyle(height: 1.0, leading: 0),
        overflow: TextOverflow.ellipsis,
      ),
    );

    if (widget.isActive) return child;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: child,
    );
  }
}
