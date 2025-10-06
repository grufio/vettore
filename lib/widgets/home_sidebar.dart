import 'package:flutter/material.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/theme/app_theme_typography.dart';

class HomeSidebar extends StatelessWidget {
  final List<String> items;
  final ValueChanged<int> onTap;
  final double width;
  final double rowHeight;
  final double topPadding;
  final double horizontalPadding;

  const HomeSidebar({
    super.key,
    required this.items,
    required this.onTap,
    this.width = 240.0,
    this.rowHeight = 24.0,
    this.topPadding = 8.0,
    this.horizontalPadding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle baseTextStyle = appTextStyles.bodyM;

    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: kWhite,
        border: Border(
          right: BorderSide(color: kBordersColor, width: 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: topPadding),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Section: Projects
                _SidebarRow(
                  label: 'Projects',
                  height: rowHeight,
                  horizontalPadding: horizontalPadding,
                  textStyle:
                      baseTextStyle.copyWith(fontWeight: FontWeight.bold),
                  onTap: () => onTap(0),
                ),
                _SidebarRow(
                  label: 'All',
                  height: rowHeight,
                  horizontalPadding: horizontalPadding,
                  textStyle: baseTextStyle,
                  onTap: () => onTap(1),
                ),
                _SidebarRow(
                  label: 'Current',
                  height: rowHeight,
                  horizontalPadding: horizontalPadding,
                  textStyle: baseTextStyle,
                  onTap: () => onTap(2),
                ),
                _SidebarRow(
                  label: 'Archived',
                  height: rowHeight,
                  horizontalPadding: horizontalPadding,
                  textStyle: baseTextStyle,
                  onTap: () => onTap(3),
                ),
                const SizedBox(height: 8.0),
                // Divider between sections
                const _SectionDivider(),
                const SizedBox(height: 8.0),

                // Section: Palettes
                _SidebarRow(
                  label: 'Palettes',
                  height: rowHeight,
                  horizontalPadding: horizontalPadding,
                  textStyle:
                      baseTextStyle.copyWith(fontWeight: FontWeight.bold),
                  onTap: () => onTap(4),
                ),
                _SidebarRow(
                  label: 'All',
                  height: rowHeight,
                  horizontalPadding: horizontalPadding,
                  textStyle: baseTextStyle,
                  onTap: () => onTap(5),
                ),
                _SidebarRow(
                  label: 'Current',
                  height: rowHeight,
                  horizontalPadding: horizontalPadding,
                  textStyle: baseTextStyle,
                  onTap: () => onTap(6),
                ),
                _SidebarRow(
                  label: 'Archived',
                  height: rowHeight,
                  horizontalPadding: horizontalPadding,
                  textStyle: baseTextStyle,
                  onTap: () => onTap(7),
                ),
                const SizedBox(height: 8.0),
                const _SectionDivider(),
                const SizedBox(height: 8.0),

                // Section: Libraries
                _SidebarRow(
                  label: 'Libraries',
                  height: rowHeight,
                  horizontalPadding: horizontalPadding,
                  textStyle:
                      baseTextStyle.copyWith(fontWeight: FontWeight.bold),
                  onTap: () => onTap(8),
                ),
                _SidebarRow(
                  label: 'All',
                  height: rowHeight,
                  horizontalPadding: horizontalPadding,
                  textStyle: baseTextStyle,
                  onTap: () => onTap(9),
                ),
                _SidebarRow(
                  label: 'Current',
                  height: rowHeight,
                  horizontalPadding: horizontalPadding,
                  textStyle: baseTextStyle,
                  onTap: () => onTap(10),
                ),
                _SidebarRow(
                  label: 'Archived',
                  height: rowHeight,
                  horizontalPadding: horizontalPadding,
                  textStyle: baseTextStyle,
                  onTap: () => onTap(11),
                ),
                const SizedBox(height: 8.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarRow extends StatefulWidget {
  final String label;
  final double height;
  final double horizontalPadding;
  final TextStyle textStyle;
  final VoidCallback onTap;

  const _SidebarRow({
    required this.label,
    required this.height,
    required this.horizontalPadding,
    required this.textStyle,
    required this.onTap,
  });

  @override
  State<_SidebarRow> createState() => _SidebarRowState();
}

class _SidebarRowState extends State<_SidebarRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: widget.height,
          padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
          decoration: BoxDecoration(
            color: _isHovered ? kGrey20 : kWhite,
            // No per-row borders; section dividers are handled externally
            border: null,
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            widget.label,
            style: widget.textStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 1.0,
      child: ColoredBox(color: kBordersColor),
    );
  }
}
