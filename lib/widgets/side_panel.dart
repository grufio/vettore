import 'package:flutter/widgets.dart';
import 'package:vettore/theme/app_theme_colors.dart';

enum SidePanelSide { left, right }

class SidePanel extends StatelessWidget {
  const SidePanel({
    super.key,
    required this.side,
    required this.child,
    this.width = 260.0,
    this.topPadding = 8.0,
    this.horizontalPadding = 16.0,
    this.resizable = false,
    this.minWidth = 100.0,
    this.maxWidth = 300.0,
    this.onResizeDelta,
    this.onResetWidth,
  });
  final SidePanelSide side;
  final double width;
  final double topPadding;
  final double horizontalPadding;
  final Widget child;
  final bool resizable;
  final double minWidth;
  final double maxWidth;
  final ValueChanged<double>? onResizeDelta;
  final VoidCallback? onResetWidth;

  @override
  Widget build(BuildContext context) {
    final Border border = side == SidePanelSide.left
        ? const Border(
            right: BorderSide(color: kBordersColor),
          )
        : const Border(
            left: BorderSide(color: kBordersColor),
          );

    return SizedBox(
      width: width.clamp(minWidth, maxWidth),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: kWhite,
            ),
            foregroundDecoration: BoxDecoration(
              border: border,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: topPadding),
                Expanded(child: child),
              ],
            ),
          ),
          if (resizable)
            Align(
              alignment: side == SidePanelSide.left
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragUpdate: (details) {
                    onResizeDelta?.call(
                      side == SidePanelSide.left
                          ? details.delta.dx
                          : -details.delta.dx,
                    );
                  },
                  onDoubleTap: onResetWidth,
                  child: const SizedBox(
                    width: 8.0,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
