import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// ignore_for_file: always_use_package_imports
import '../icons/grufio_icons.dart';
import '../theme/app_theme_colors.dart';
import '../theme/app_theme_typography.dart';

class AddProjectButton extends StatefulWidget {
  const AddProjectButton({super.key, required this.onTap});
  final VoidCallback onTap;

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
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Icon(Grufio.add, size: 20.0, color: kWhite),
              const SizedBox(width: 4.0),
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

class DeleteProjectButton extends StatefulWidget {
  const DeleteProjectButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  State<DeleteProjectButton> createState() => _DeleteProjectButtonState();
}

class _DeleteProjectButtonState extends State<DeleteProjectButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(6.0),
          ),
          alignment: Alignment.center,
          child: Text(
            '- Delete Project',
            style: labelStyle,
            strutStyle: const StrutStyle(height: 1.0, leading: 0),
          ),
        ),
      ),
    );
  }
}

class OutlinedActionButton extends StatefulWidget {
  const OutlinedActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.minWidth,
    this.enabled = true,
  });
  final String label;
  final VoidCallback onTap;
  final double? minWidth;
  final bool enabled;

  @override
  State<OutlinedActionButton> createState() => _OutlinedActionButtonState();
}

class _OutlinedActionButtonState extends State<OutlinedActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.enabled;
    final Color borderColor =
        isEnabled ? (_hovered ? kGrey100 : kGrey70) : kGrey30;
    final Color textColor =
        isEnabled ? (_hovered ? kGrey100 : kGrey70) : kGrey40;
    final TextStyle labelStyle = appTextStyles.bodyMMedium.copyWith(
      color: textColor,
      height: 1.0,
    );

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: isEnabled ? widget.onTap : null,
        child: Container(
          constraints: BoxConstraints(minWidth: widget.minWidth ?? 0),
          height: 24.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(color: borderColor),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: labelStyle,
            strutStyle: const StrutStyle(height: 1.0, leading: 0),
          ),
        ),
      ),
    );
  }
}
