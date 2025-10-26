import 'package:flutter/widgets.dart';
import 'package:vettore/icons/grufio_icons.dart';
import 'package:vettore/theme/app_theme_colors.dart';

class SnackbarImage extends StatelessWidget {
  const SnackbarImage({
    super.key,
    this.onZoomIn,
    this.onZoomOut,
    this.onFitToScreen,
  });
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onFitToScreen;

  static const double _height = 40.0;
  static const double _iconSize = 24.0;
  static const double _gap = 12.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: kBordersColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IconButton(
            asset: 'zoom-in',
            onTap: onZoomIn,
          ),
          const SizedBox(width: _gap),
          _IconButton(
            asset: 'zoom-out',
            onTap: onZoomOut,
          ),
          const SizedBox(width: _gap),
          _IconButton(
            asset: 'zoom-fit',
            onTap: onFitToScreen,
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.asset, this.onTap});
  final String asset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) =>
      _IconButtonInner(asset: asset, onTap: onTap);
}

class _IconButtonInner extends StatefulWidget {
  const _IconButtonInner({required this.asset, this.onTap});
  final String asset;
  final VoidCallback? onTap;

  @override
  State<_IconButtonInner> createState() => _IconButtonInnerState();
}

class _IconButtonInnerState extends State<_IconButtonInner> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: SnackbarImage._iconSize,
          height: SnackbarImage._iconSize,
          child: Center(
            child: () {
              final Color color = _hovered ? kGrey100 : kGrey70;
              final double size = SnackbarImage._iconSize;
              if (widget.asset == 'zoom-in') {
                return Icon(Grufio.zoomIn, size: size, color: color);
              }
              if (widget.asset == 'zoom-out') {
                return Icon(Grufio.zoomOut, size: size, color: color);
              }
              if (widget.asset == 'zoom-fit') {
                return Icon(Grufio.zoomFit, size: size, color: color);
              }
              return SizedBox(width: size, height: size);
            }(),
          ),
        ),
      ),
    );
  }
}
