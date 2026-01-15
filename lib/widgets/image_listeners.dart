import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grufio/providers/image_providers.dart';
import 'package:grufio/providers/project_image_providers.dart';
import 'package:grufio/services/image_detail_controller.dart';

/// Small helper widget to wire project/image listeners and sync DPI/phys px into the controller.
class ImageListeners extends ConsumerStatefulWidget {
  const ImageListeners({
    super.key,
    required this.projectId,
    required this.controller,
  });
  final int projectId;
  final ImageDetailController controller;

  @override
  ConsumerState<ImageListeners> createState() => _ImageListenersState();
}

class _ImageListenersState extends ConsumerState<ImageListeners> {
  int? _lastImageId;
  @override
  Widget build(BuildContext context) {
    final int? imageId =
        ref.watch(projectImageIdProvider(widget.projectId)).value;
    if (imageId != null && imageId != _lastImageId) {
      _lastImageId = imageId;
      // Seed phys px
      widget.controller.listenImagePhysPx(
        ref: ref,
        imageId: imageId,
        onDims: (w, h) => widget.controller.applyRemotePx(
          widthPx: w,
          heightPx: h,
        ),
      );
      // Sync DPI
      ref.read(imageDpiProvider(imageId).future).then((dpiVal) {
        if (!mounted) return;
        if (dpiVal != null && dpiVal > 0) {
          widget.controller.setUiDpi(dpiVal);
        }
      });
    }
    return const SizedBox.shrink();
  }
}
