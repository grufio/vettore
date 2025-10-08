import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:vettore/widgets/artboard_view.dart';
import 'package:vettore/widgets/snackbar_image.dart';

class ImagePreview extends StatelessWidget {
  final TransformationController controller;
  final double boardW;
  final double boardH;
  final double canvasW;
  final double canvasH;
  final Uint8List? bytes;
  final GlobalKey viewportKey;

  const ImagePreview({
    super.key,
    required this.controller,
    required this.boardW,
    required this.boardH,
    required this.canvasW,
    required this.canvasH,
    required this.bytes,
    required this.viewportKey,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ArtboardView(
          controller: controller,
          boardW: boardW,
          boardH: boardH,
          canvasW: canvasW,
          canvasH: canvasH,
          bytes: bytes,
          viewportKey: viewportKey,
        ),
        if (bytes != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 16.0,
            child: Center(
              child: SnackbarImage(
                onZoomIn: () {
                  final double cur = controller.value.getMaxScaleOnAxis();
                  final double next = (cur * 1.25).clamp(0.25, 8.0);
                  final double factor = next / cur;
                  final RenderBox? box = viewportKey.currentContext
                      ?.findRenderObject() as RenderBox?;
                  final Size vp = box?.size ?? const Size(0, 0);
                  if (vp.width == 0 || vp.height == 0) {
                    final Matrix4 m = controller.value.clone();
                    controller.value = m..scale(factor);
                    return;
                  }
                  final Offset viewportCenter =
                      Offset(vp.width / 2, vp.height / 2);
                  final Matrix4 inv =
                      Matrix4.inverted(controller.value.clone());
                  final Offset sceneFocal =
                      MatrixUtils.transformPoint(inv, viewportCenter);
                  final Matrix4 m = controller.value.clone()
                    ..translate(sceneFocal.dx, sceneFocal.dy)
                    ..scale(factor)
                    ..translate(-sceneFocal.dx, -sceneFocal.dy);
                  controller.value = m;
                },
                onZoomOut: () {
                  final double cur = controller.value.getMaxScaleOnAxis();
                  final double next = (cur / 1.25).clamp(0.25, 8.0);
                  final double factor = next / cur;
                  final RenderBox? box = viewportKey.currentContext
                      ?.findRenderObject() as RenderBox?;
                  final Size vp = box?.size ?? const Size(0, 0);
                  if (vp.width == 0 || vp.height == 0) {
                    final Matrix4 m = controller.value.clone();
                    controller.value = m..scale(factor);
                    return;
                  }
                  final Offset viewportCenter =
                      Offset(vp.width / 2, vp.height / 2);
                  final Matrix4 inv =
                      Matrix4.inverted(controller.value.clone());
                  final Offset sceneFocal =
                      MatrixUtils.transformPoint(inv, viewportCenter);
                  final Matrix4 m = controller.value.clone()
                    ..translate(sceneFocal.dx, sceneFocal.dy)
                    ..scale(factor)
                    ..translate(-sceneFocal.dx, -sceneFocal.dy);
                  controller.value = m;
                },
                onFitToScreen: () {
                  controller.value = Matrix4.identity();
                },
              ),
            ),
          ),
      ],
    );
  }
}
