import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:vettore/theme/app_theme_colors.dart';

class ArtboardView extends StatelessWidget {
  final TransformationController controller;
  final double boardW;
  final double boardH;
  final double canvasW;
  final double canvasH;
  final Uint8List? bytes;
  final double outerPad;
  final Key? viewportKey;

  const ArtboardView({
    super.key,
    required this.controller,
    required this.boardW,
    required this.boardH,
    required this.canvasW,
    required this.canvasH,
    required this.bytes,
    this.outerPad = 0.0,
    this.viewportKey,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: LayoutBuilder(builder: (context, constraints) {
        final double maxSide = constraints.maxWidth > constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final EdgeInsets margin = EdgeInsets.all(maxSide * 2);
        return ClipRect(
          child: InteractiveViewer(
            key: viewportKey,
            transformationController: controller,
            minScale: 0.25,
            maxScale: 8.0,
            scaleEnabled: true,
            panEnabled: true,
            constrained: false,
            boundaryMargin: margin,
            child: RepaintBoundary(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(outerPad),
                  child: SizedBox(
                    width: boardW,
                    height: boardH,
                    child: Stack(
                      children: [
                        Positioned(
                          left: (boardW - canvasW) / 2,
                          top: (boardH - canvasH) / 2,
                          width: canvasW,
                          height: canvasH,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Positioned.fill(
                                child: ColoredBox(color: kWhite),
                              ),
                              if (bytes != null)
                                Center(
                                  child: ClipRect(
                                    child: OverflowBox(
                                      minWidth: 0,
                                      minHeight: 0,
                                      maxWidth: double.infinity,
                                      maxHeight: double.infinity,
                                      child: Image.memory(
                                        bytes!,
                                        fit: BoxFit.none,
                                        alignment: Alignment.center,
                                        filterQuality: FilterQuality.none,
                                        cacheWidth: null,
                                        cacheHeight: null,
                                        gaplessPlayback: true,
                                      ),
                                    ),
                                  ),
                                ),
                              LayoutBuilder(builder: (context, constraints) {
                                final double s =
                                    controller.value.getMaxScaleOnAxis();
                                final double dpr =
                                    MediaQuery.of(context).devicePixelRatio;
                                return IgnorePointer(
                                  child: CustomPaint(
                                    painter: HairlineBorderPainter(
                                        scale: s, dpr: dpr),
                                    size: Size(constraints.maxWidth,
                                        constraints.maxHeight),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class HairlineCanvasBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = kGrey100
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Offset.zero & size, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HairlineBorderPainter extends CustomPainter {
  final double scale;
  final double dpr;
  const HairlineBorderPainter({required this.scale, required this.dpr});

  @override
  void paint(Canvas canvas, Size size) {
    final double s = scale <= 0 ? 1.0 : scale;
    final double ratio = dpr <= 0 ? 1.0 : dpr;
    final double inset = 0.5 / (ratio * s);
    final Rect rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2.0,
      size.height - inset * 2.0,
    );

    final Paint p = Paint()
      ..color = kGrey100
      ..strokeWidth = 0.0
      ..isAntiAlias = false
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, p);
  }

  @override
  bool shouldRepaint(covariant HairlineBorderPainter oldDelegate) =>
      oldDelegate.scale != scale || oldDelegate.dpr != dpr;
}
