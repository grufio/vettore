import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vettore/theme/app_theme_colors.dart';

// --- Constants for Tab Dimensions and Styles ---
const double _kTabHeight = 40.0;
const double _kTabIconSize = 16.0;
const double _kTabHorizontalPadding = 12.0;
const double _kTabSpacing = 8.0;
const double _kTabFontSize = 12.0;
const String _kTabFontFamily = 'Inter';

// --- Colors --- (use app palette)
const Color _kContentColor = kOnBackgroundColor;
const Color _kContentColorInactive = Color(0xFF7D7D7D);
const Color _kContentColorHover = Color(0xFF000000);
const Color _kTabHoverColor = Color(0xFFDCDCDC);
const Color _kTabActiveColor = kSurfaceColor;
const Color _kTabInactiveBgColor = Color(0xFFF0F0F0);

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
    final Color contentColor = _isHovered
        ? _kContentColorHover
        : (widget.isActive ? _kContentColor : _kContentColorInactive);

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
              : (_isHovered ? _kTabHoverColor : _kTabInactiveBgColor),
        ),
        child: child,
      ),
    );
  }
}
