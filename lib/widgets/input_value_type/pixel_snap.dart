import 'package:flutter/widgets.dart';

/// Wraps a child and aligns it to device pixels to avoid half-pixel blurring.
class PixelSnap extends StatelessWidget {
  final Widget child;
  const PixelSnap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final pixelRatio = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 1.0;
      // Round the local offset to the nearest device pixel
      return Transform.translate(
        offset: Offset(
          (0.0 * pixelRatio).roundToDouble() / pixelRatio,
          (0.0 * pixelRatio).roundToDouble() / pixelRatio,
        ),
        filterQuality: FilterQuality.none,
        child: child,
      );
    });
  }
}
