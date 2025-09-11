import 'package:flutter/material.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/theme/app_theme_typography.dart';

class HomeNavigation extends StatelessWidget {
  final double rowHeight;
  final ValueChanged<int> onTap;
  final double horizontalPadding;
  final int selectedIndex;

  const HomeNavigation({
    super.key,
    required this.onTap,
    this.rowHeight = 24.0,
    this.horizontalPadding = 16.0,
    this.selectedIndex = 1,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle baseTextStyle = appTextStyles.bodyM;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _NavRow(
            label: 'Projects',
            height: rowHeight,
            horizontalPadding: horizontalPadding,
            textStyle: baseTextStyle.copyWith(fontWeight: FontWeight.bold),
            onTap: () => onTap(0),
            selected: selectedIndex == 0),
        _NavRow(
            label: 'All',
            height: rowHeight,
            horizontalPadding: horizontalPadding,
            textStyle: baseTextStyle,
            onTap: () => onTap(1),
            selected: selectedIndex == 1),
        _NavRow(
            label: 'Current',
            height: rowHeight,
            horizontalPadding: horizontalPadding,
            textStyle: baseTextStyle,
            onTap: () => onTap(2),
            selected: selectedIndex == 2),
        _NavRow(
            label: 'Archived',
            height: rowHeight,
            horizontalPadding: horizontalPadding,
            textStyle: baseTextStyle,
            onTap: () => onTap(3),
            selected: selectedIndex == 3),
        const SizedBox(height: 8.0),
        const _SectionDivider(),
        const SizedBox(height: 8.0),
        _NavRow(
            label: 'Palettes',
            height: rowHeight,
            horizontalPadding: horizontalPadding,
            textStyle: baseTextStyle.copyWith(fontWeight: FontWeight.bold),
            onTap: () => onTap(4),
            selected: selectedIndex == 4),
        _NavRow(
            label: 'All',
            height: rowHeight,
            horizontalPadding: horizontalPadding,
            textStyle: baseTextStyle,
            onTap: () => onTap(5),
            selected: selectedIndex == 5),
        _NavRow(
            label: 'Current',
            height: rowHeight,
            horizontalPadding: horizontalPadding,
            textStyle: baseTextStyle,
            onTap: () => onTap(6),
            selected: selectedIndex == 6),
        _NavRow(
            label: 'Archived',
            height: rowHeight,
            horizontalPadding: horizontalPadding,
            textStyle: baseTextStyle,
            onTap: () => onTap(7),
            selected: selectedIndex == 7),
        const SizedBox(height: 8.0),
        const _SectionDivider(),
        const SizedBox(height: 8.0),
        _NavRow(
            label: 'Libraries',
            height: rowHeight,
            horizontalPadding: horizontalPadding,
            textStyle: baseTextStyle.copyWith(fontWeight: FontWeight.bold),
            onTap: () => onTap(8),
            selected: selectedIndex == 8),
        _NavRow(
            label: 'All',
            height: rowHeight,
            horizontalPadding: horizontalPadding,
            textStyle: baseTextStyle,
            onTap: () => onTap(9),
            selected: selectedIndex == 9),
        _NavRow(
            label: 'Current',
            height: rowHeight,
            horizontalPadding: horizontalPadding,
            textStyle: baseTextStyle,
            onTap: () => onTap(10),
            selected: selectedIndex == 10),
        _NavRow(
            label: 'Archived',
            height: rowHeight,
            horizontalPadding: horizontalPadding,
            textStyle: baseTextStyle,
            onTap: () => onTap(11),
            selected: selectedIndex == 11),
        const SizedBox(height: 8.0),
        const _SectionDivider(),
      ],
    );
  }
}

class _NavRow extends StatefulWidget {
  final String label;
  final double height;
  final double horizontalPadding;
  final TextStyle textStyle;
  final VoidCallback onTap;
  final bool selected;

  const _NavRow({
    required this.label,
    required this.height,
    required this.horizontalPadding,
    required this.textStyle,
    required this.onTap,
    this.selected = false,
  });

  @override
  State<_NavRow> createState() => _NavRowState();
}

class _NavRowState extends State<_NavRow> {
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
            color:
                widget.selected ? kSelected : (_isHovered ? kGrey10 : kWhite),
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
    return const SizedBox(height: 1.0, child: ColoredBox(color: kBordersColor));
  }
}
