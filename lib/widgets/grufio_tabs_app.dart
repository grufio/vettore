import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:vettore/models/grufio_tab_data.dart';
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

// --- Colors ---
const Color _kContentColor = Colors.black;
const Color _kContentColorInactive = Colors.black54;
final Color _kTabHoverColor = Colors.grey.withOpacity(0.15);
final Color _kCloseButtonHoverColor = Colors.grey.withOpacity(0.2);
const Color _kTabActiveColor = Colors.white;

class GrufioTab extends StatefulWidget {
  final String iconPath;
  final String? label;
  final bool isActive;
  final bool showLeftBorder;
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
            color: _isCloseButtonHovered
                ? _kCloseButtonHoverColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(_kCloseButtonBorderRadius),
          ),
          child: Icon(
            Icons.close,
            size: _kCloseButtonIconSize,
            color:
                _isCloseButtonHovered ? _kContentColor : _kContentColorInactive,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isClosable = widget.onClose != null;
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
            border: Border(
              left: widget.showLeftBorder
                  ? const BorderSide(
                      color: kBordersColor, width: _kTabBorderWidth)
                  : BorderSide.none,
              right: const BorderSide(
                color: kBordersColor,
                width: _kTabBorderWidth,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GrufioToolBar extends ToolBar {
  final List<GrufioTabData> tabs;
  final int activeIndex;
  final ValueChanged<int> onTabSelected;
  final ValueChanged<int>? onTabClosed;

  GrufioToolBar({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onTabSelected,
    this.onTabClosed,
  }) : super(
          title: Row(
            children: [
              ...List.generate(tabs.length, (index) {
                final tabData = tabs[index];
                final bool isClosable =
                    onTabClosed != null && tabData.label != null;
                return GrufioTab(
                  isActive: activeIndex == index,
                  iconPath: tabData.iconPath,
                  label: tabData.label,
                  width: tabData.width,
                  showLeftBorder: index == 0,
                  onTap: () => onTabSelected(index),
                  onClose: isClosable ? () => onTabClosed(index) : null,
                );
              }),
            ],
          ),
          titleWidth: 400.0,
          actions: const [
            ToolBarSpacer(),
          ],
        );
}
