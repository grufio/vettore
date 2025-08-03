import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vettore/theme/app_theme_colors.dart';

class _CloseButton extends StatefulWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color:
                _isHovered ? Colors.grey.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.close,
            size: 16,
            color: _isHovered ? Colors.black : Colors.black54,
          ),
        ),
      ),
    );
  }
}

class GrufioTab extends StatefulWidget {
  final String iconPath;
  final String? label;
  final bool isActive;
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
  });

  @override
  State<GrufioTab> createState() => _GrufioTabState();
}

class _GrufioTabState extends State<GrufioTab> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isClosable = widget.onClose != null;
    final Color contentColor =
        (widget.isActive || _isHovered) ? Colors.black : Colors.black54;

    final iconWidget = SvgPicture.asset(
      widget.iconPath,
      width: 16,
      height: 16,
      colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
    );

    final child = widget.label == null
        ? Center(child: iconWidget)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget,
              const SizedBox(width: 8),
              Text(
                widget.label!,
                style: TextStyle(
                  color: contentColor,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
              if (isClosable) ...[
                const SizedBox(width: 8),
                Opacity(
                  opacity: _isHovered ? 1.0 : 0.0,
                  child: _CloseButton(onTap: widget.onClose!),
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
          height: 40.0,
          padding: widget.label == null
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: widget.isActive
                ? Colors.white
                : (_isHovered
                    ? Colors.grey.withOpacity(0.15)
                    : Colors.transparent),
            border: const Border(
              right: BorderSide(
                color: kBordersColor,
                width: 1.0,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TabData {
  final String iconPath;
  final String? label;
  final double? width;

  _TabData({required this.iconPath, this.label, this.width});
}

class GrufioTabsAppBar extends StatefulWidget implements PreferredSizeWidget {
  const GrufioTabsAppBar({super.key});

  @override
  State<GrufioTabsAppBar> createState() => _GrufioTabsAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(40.0);
}

class _GrufioTabsAppBarState extends State<GrufioTabsAppBar> {
  int _activeIndex = 0;

  final List<_TabData> _tabs = [
    _TabData(iconPath: 'assets/icons/32/home.svg', width: 40.0),
    _TabData(
      iconPath: 'assets/icons/32/color-palette.svg',
      label: 'MouseOverTab',
    ),
  ];

  void _setActiveIndex(int index) {
    setState(() {
      _activeIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      toolbarHeight: 40.0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          color: kBackgroundColor,
          border: Border(
            bottom: BorderSide(
              color: kBordersColor,
              width: 1.0,
            ),
          ),
        ),
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_tabs.length, (index) {
          final tabData = _tabs[index];
          return GrufioTab(
            isActive: _activeIndex == index,
            iconPath: tabData.iconPath,
            label: tabData.label,
            width: tabData.width,
            onTap: () => _setActiveIndex(index),
            onClose: tabData.label != null ? () {} : null,
          );
        }),
      ),
    );
  }
}
