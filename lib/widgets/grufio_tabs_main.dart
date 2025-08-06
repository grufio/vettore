import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// --- Constants for Tab Dimensions and Styles ---
const double _kTabHeight = 40.0;
const double _kTabIconSize = 16.0;
const double _kTabHorizontalPadding = 12.0;
const double _kTabSpacing = 8.0;
const double _kTabFontSize = 12.0;
const String _kTabFontFamily = 'Inter';

// --- Colors ---
const Color _kContentColor = Colors.black;
const Color _kContentColorInactive = Colors.black54;
final Color _kTabHoverColor = Colors.grey.withOpacity(0.15);
const Color _kTabActiveColor = Colors.white;

class GrufioTabContent extends StatefulWidget {
  final String iconPath;
  final String? label;
  final bool isActive;
  final double? width;

  const GrufioTabContent({
    super.key,
    required this.iconPath,
    required this.isActive,
    this.label,
    this.width,
  });

  @override
  State<GrufioTabContent> createState() => _GrufioTabContentState();
}

class _GrufioTabContentState extends State<GrufioTabContent> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // The `isActive` state is passed from the parent `MacosTabView`.
    // The `_isHovered` state is managed locally.
    final Color contentColor = (widget.isActive || _isHovered)
        ? _kContentColor
        : _kContentColorInactive;

    final iconWidget = SvgPicture.asset(
      widget.iconPath,
      width: _kTabIconSize,
      height: _kTabIconSize,
      colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
    );

    final child = widget.label == null
        ? Center(child: iconWidget)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget,
              const SizedBox(width: _kTabSpacing),
              Text(
                widget.label!,
                style: TextStyle(
                  color: contentColor,
                  fontSize: _kTabFontSize,
                  fontFamily: _kTabFontFamily,
                ),
              ),
            ],
          );

    // MouseRegion is used to detect hover and change style accordingly.
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        width: widget.width,
        height: _kTabHeight,
        padding: widget.label == null
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: _kTabHorizontalPadding),
        decoration: BoxDecoration(
          color: widget.isActive
              ? _kTabActiveColor
              : (_isHovered ? _kTabHoverColor : Colors.transparent),
        ),
        child: child,
      ),
    );
  }
}
