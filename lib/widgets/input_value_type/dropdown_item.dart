import 'package:flutter/widgets.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// ignore_for_file: always_use_package_imports
import '../../icons/grufio_icons.dart';
import '../../theme/app_theme_colors.dart';

class DropdownItem extends StatefulWidget {
  const DropdownItem({
    super.key,
    required this.label,
    required this.isSelected,
    required this.highlighted,
    required this.onTap,
    required this.onHover,
  });
  final String label;
  final bool isSelected;
  final bool highlighted;
  final VoidCallback onTap;
  final VoidCallback onHover;

  @override
  State<DropdownItem> createState() => _DropdownItemState();
}

class _DropdownItemState extends State<DropdownItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        widget.onHover();
        setState(() => _hover = true);
      },
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 24.0,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: _hover ? kInputBackground : kTransparent,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 16.0,
                height: 16.0,
                child: widget.isSelected
                    ? const Icon(Grufio.checkmark, size: 16.0, color: kWhite)
                    : const SizedBox.shrink(),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    color: kWhite,
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
