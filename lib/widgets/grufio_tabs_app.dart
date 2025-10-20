import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vettore/theme/app_theme_colors.dart';

// --- Constants for Tab Dimensions and Styles ---
const double _kTabHeight = 40.0;
const double _kTabIconSize = 20.0;
const double _kTabHorizontalPadding = 8.0;
const double _kTabSpacing = 8.0;
const double _kTabFontSize = 12.0;
const String _kTabFontFamily = 'Inter';
const double _kTabBorderWidth = 1.0;

// --- Constants for Close Button ---
const double _kCloseButtonSize = 20.0;
const double _kCloseButtonIconSize = 20.0;
const double _kCloseButtonBorderRadius = 4.0;

// --- Colors directly from theme

class GrufioTab extends StatefulWidget {
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
  final String iconPath;
  final String? label;
  final bool isActive;
  final bool showLeftBorder;
  final bool showRightBorder;
  final VoidCallback onTap;
  final VoidCallback? onClose;
  final double? width;

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
        onTap: widget.onClose,
        child: Container(
          width: _kCloseButtonSize,
          height: _kCloseButtonSize,
          decoration: BoxDecoration(
            color:
                _isCloseButtonHovered ? kTabCloseHoverBackground : kTransparent,
            borderRadius: BorderRadius.circular(_kCloseButtonBorderRadius),
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/32/close.svg',
              width: _kCloseButtonIconSize,
              height: _kCloseButtonIconSize,
              colorFilter: ColorFilter.mode(
                _isCloseButtonHovered ? kGrey100 : kTabTextColorInactive,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isClosable = widget.onClose != null;
    final Color contentColor = widget.isActive
        ? kGrey90
        : (_isHovered ? kGrey100 : kTabTextColorInactive);

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
                  opacity: widget.isActive ? 1.0 : (_isHovered ? 1.0 : 0.0),
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
          color: kTabBackgroundInactive, // ensure tab strip background F0F0F0
          child: Container(
            width: widget.width,
            height: _kTabHeight,
            padding: widget.label == null
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(
                    horizontal: _kTabHorizontalPadding),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? kTabBackgroundActive
                  : (_isHovered ? kTabBackgroundHover : kTabBackgroundInactive),
              border: Border(
                left: widget.showLeftBorder
                    ? const BorderSide(color: kBordersColor)
                    : BorderSide.none,
                right: widget.showRightBorder
                    ? const BorderSide(
                        color: kBordersColor,
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

/// A plus-tab button that matches the inactive tab styling but has no borders.
/// Fixed size: 40x40. Displays only the add icon and triggers [onTap] when pressed.
class GrufioTabButton extends StatefulWidget {
  const GrufioTabButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  State<GrufioTabButton> createState() => _GrufioTabButtonState();
}

class _GrufioTabButtonState extends State<GrufioTabButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color contentColor = _isHovered ? kGrey100 : kTabTextColorInactive;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ColoredBox(
          color: kTabBackgroundInactive,
          child: Container(
            width: _kTabHeight,
            height: _kTabHeight,
            decoration: BoxDecoration(
              color: _isHovered ? kTabBackgroundHover : kTabBackgroundInactive,
              border: const Border(
                right: BorderSide.none,
              ),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/icons/32/add.svg',
              width: 20.0,
              height: 20.0,
              colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}
