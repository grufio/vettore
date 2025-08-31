import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/theme/app_theme_typography.dart';

class AddProjectButton extends StatefulWidget {
  final VoidCallback onTap;

  const AddProjectButton({super.key, required this.onTap});

  @override
  State<AddProjectButton> createState() => _AddProjectButtonState();
}

class _AddProjectButtonState extends State<AddProjectButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = appTextStyles.bodyM.copyWith(
      color: kWhite,
      height: 1.0,
    );
    final Color backgroundColor = _isHovered ? kGrey100 : kButtonColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 24.0,
          padding: const EdgeInsets.only(left: 8.0, right: 12.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            textBaseline: TextBaseline.alphabetic,
            children: [
              SvgPicture.asset(
                'assets/icons/32/add.svg',
                width: 20.0,
                height: 20.0,
                colorFilter: const ColorFilter.mode(kWhite, BlendMode.srcIn),
              ),
              const SizedBox(width: 4.0),
              Text(
                'Add Project',
                style: labelStyle,
                strutStyle: const StrutStyle(height: 1.0, leading: 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
