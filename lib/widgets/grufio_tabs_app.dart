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
const double _kTabBorderWidth = 1.0;

// --- Constants for Close Button ---
const double _kCloseButtonSize = 20.0;
const double _kCloseButtonIconSize = 16.0;
const double _kCloseButtonBorderRadius = 4.0;

// --- Colors from theme
const Color _kContentColor = kTabTextColor;
const Color _kContentColorInactive = kTabTextColorInactive; // font inactive
const Color _kContentColorHover = kTabTextColor; // hover text/icon
const Color _kTabHoverColor = kTabBackgroundHover;
const Color _kCloseButtonHoverColor = kTabCloseHoverBackground;
const Color _kTabActiveColor = kTabBackgroundActive; // active tab background
const Color _kTabInactiveBgColor =
    kTabBackgroundInactive; // background inactive

class GrufioTab extends StatefulWidget {
  final String iconPath;
  final String? label;
  final bool isActive;
  final bool showLeftBorder;
  final bool showRightBorder;
  final VoidCallback onTap;
  final VoidCallback? onClose;
  final double? width;

  const GrufioTab({
    super.key,
    required this.iconPath,
    required this.isActive,
    required this.onTap,
    this.label,
    this.onClose,
    this.width,
    this.showLeftBorder = false,
    this.showRightBorder = true,
  });

  @override
  State<GrufioTab> createState() => _GrufioTabState();
}

class _GrufioTabState extends State<GrufioTab> {
  bool _isHovered = false;
  bool _isCloseButtonHovered = false;

  Widget _buildCloseButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isCloseButtonHovered = true),
      onExit: (_) => setState(() => _isCloseButtonHovered = false),
      child: GestureDetector(
        onTap: widget.onClose!,
        child: Container(
          width: _kCloseButtonSize,
          height: _kCloseButtonSize,
          decoration: BoxDecoration(
            color:
                _isCloseButtonHovered ? _kCloseButtonHoverColor : kTransparent,
            borderRadius: BorderRadius.circular(_kCloseButtonBorderRadius),
          ),
          child: SvgPicture.asset(
            'assets/icons/16/close--filled.svg',
            width: _kCloseButtonIconSize,
            height: _kCloseButtonIconSize,
            colorFilter: ColorFilter.mode(
              _isCloseButtonHovered
                  ? _kContentColorHover
                  : _kContentColorInactive,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isClosable = widget.onClose != null;
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
              if (isClosable) ...[
                const SizedBox(width: _kTabSpacing),
                Opacity(
                  opacity: _isHovered ? 1.0 : 0.0,
                  child: _buildCloseButton(),
                ),
              ],
            ],
          );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ColoredBox(
          color: _kTabInactiveBgColor, // ensure tab strip background F0F0F0
          child: Container(
            width: widget.width,
            height: _kTabHeight,
            padding: widget.label == null
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(
                    horizontal: _kTabHorizontalPadding),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? _kTabActiveColor
                  : (_isHovered ? _kTabHoverColor : _kTabInactiveBgColor),
              border: Border(
                left: widget.showLeftBorder
                    ? const BorderSide(
                        color: kBordersColor, width: _kTabBorderWidth)
                    : BorderSide.none,
                right: widget.showRightBorder
                    ? const BorderSide(
                        color: kBordersColor,
                        width: _kTabBorderWidth,
                      )
                    : BorderSide.none,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
