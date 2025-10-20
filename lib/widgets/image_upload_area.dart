import 'dart:typed_data';

// import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vettore/theme/app_theme_colors.dart';
// import 'package:vettore/widgets/image_upload_text.dart';
import 'package:vettore/widgets/snackbar_image.dart';

class ImageUploadArea extends StatefulWidget {
  const ImageUploadArea({
    super.key,
    required this.onBytesSelected,
    this.initialBytes,
    this.allowedExtensions = const ['png', 'jpg', 'jpeg'],
  });
  final Future<void> Function(Uint8List bytes) onBytesSelected;
  final Uint8List? initialBytes;
  final List<String> allowedExtensions;

  @override
  State<ImageUploadArea> createState() => _ImageUploadAreaState();
}

class _ImageUploadAreaState extends State<ImageUploadArea> {
  Uint8List? _bytes;
  late final PhotoViewController _controller;
  late final PhotoViewScaleStateController _scaleStateController;

  @override
  void initState() {
    super.initState();
    _bytes = widget.initialBytes;
    _controller = PhotoViewController();
    _scaleStateController = PhotoViewScaleStateController();
  }

  @override
  void didUpdateWidget(covariant ImageUploadArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialBytes != oldWidget.initialBytes &&
        widget.initialBytes != null) {
      setState(() {
        _bytes = widget.initialBytes;
        _scaleStateController.scaleState = PhotoViewScaleState.initial;
      });
    }
  }

  // Selection via drag/drop disabled in placeholder mode

  // Upload dialog not shown during initial load placeholder

  void _zoomIn() {
    final currentScale = _controller.scale ?? 1.0;
    _controller.scale = currentScale + 0.25;
  }

  void _zoomOut() {
    final currentScale = _controller.scale ?? 1.0;
    final next = currentScale - 0.25;
    _controller.scale = next < 0.25 ? 0.25 : next;
  }

  void _fitToScreen() {
    _scaleStateController.scaleState = PhotoViewScaleState.initial;
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes == null) {
      // Show a gentle placeholder instead of upload prompt while awaiting bytes
      return const ColoredBox(color: kGrey10);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRect(
          child: PhotoView(
            imageProvider: MemoryImage(_bytes!),
            controller: _controller,
            scaleStateController: _scaleStateController,
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 4.0,
            backgroundDecoration: const BoxDecoration(color: kGrey10),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 16.0,
          child: Center(
            child: SnackbarImage(
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
              onFitToScreen: _fitToScreen,
            ),
          ),
        ),
      ],
    );
  }
}
