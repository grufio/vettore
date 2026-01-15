import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/widgets.dart';
import 'package:grufio/theme/app_theme_colors.dart';

class ImageUploadText extends StatefulWidget {
  const ImageUploadText({
    super.key,
    this.onImageDropped,
    this.onUploadTap,
    this.leadingIconAsset,
    this.leadingIconSize = 64.0,
    this.uploadLabel = 'Upload image',
    this.formatsText = 'Allowed formats are .png and .jpg',
  });
  final Future<void> Function(Uint8List bytes)? onImageDropped;
  final VoidCallback? onUploadTap;
  final String? leadingIconAsset;
  final double leadingIconSize;
  final String uploadLabel;
  final String formatsText;

  @override
  State<ImageUploadText> createState() => _ImageUploadTextState();
}

class _ImageUploadTextState extends State<ImageUploadText> {
  bool _isDragging = false;
  bool _isHoveringLink = false;

  static const double _fontSize = 12.0;
  static const double _lineHeightPx = 20.0;
  static const double _lineHeight =
      _lineHeightPx / _fontSize; // line height in px / font size

  Future<void> _handleDrop(DropDoneDetails details) async {
    if (widget.onImageDropped == null || details.files.isEmpty) return;
    final bytes = await details.files.first.readAsBytes();
    await widget.onImageDropped!(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: _handleDrop,
      child: SizedBox.expand(
        child: Center(
          child: IgnorePointer(
            ignoring: _isDragging,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.leadingIconAsset != null) ...[
                  Center(
                    child: SizedBox(
                      width: widget.leadingIconSize,
                      height: widget.leadingIconSize,
                    ),
                  ),
                  const SizedBox(height: _lineHeightPx),
                ],
                const Text(
                  'No image available.',
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontWeight: FontWeight.bold,
                    color: kGrey100,
                    height: _lineHeight,
                  ),
                ),
                // No extra gap between title and next line
                const Text(
                  'Drag an image into this area or',
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontWeight: FontWeight.w400,
                    color: kGrey90,
                    height: _lineHeight,
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _isHoveringLink = true),
                  onExit: (_) => setState(() => _isHoveringLink = false),
                  child: GestureDetector(
                    onTap: widget.onUploadTap,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      widget.uploadLabel,
                      style: TextStyle(
                        fontSize: _fontSize,
                        fontWeight: FontWeight.w400,
                        color: kInputFocus,
                        height: _lineHeight,
                        decoration: _isHoveringLink
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: _lineHeightPx),
                Text(
                  widget.formatsText,
                  style: const TextStyle(
                    fontSize: _fontSize,
                    fontWeight: FontWeight.w400,
                    color: kGrey90,
                    height: _lineHeight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
