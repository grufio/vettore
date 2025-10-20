import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class ImageLayerState {
  const ImageLayerState({
    required this.offsetX,
    required this.offsetY,
    required this.scale,
    required this.rotationDeg,
    required this.opacity,
    required this.visible,
  });

  const ImageLayerState.initial()
      : offsetX = 0,
        offsetY = 0,
        scale = 1,
        rotationDeg = 0,
        opacity = 1,
        visible = true;
  final double offsetX;
  final double offsetY;
  final double scale;
  final double rotationDeg;
  final double opacity; // 0..1
  final bool visible;

  ImageLayerState copyWith({
    double? offsetX,
    double? offsetY,
    double? scale,
    double? rotationDeg,
    double? opacity,
    bool? visible,
  }) {
    return ImageLayerState(
      offsetX: offsetX ?? this.offsetX,
      offsetY: offsetY ?? this.offsetY,
      scale: scale ?? this.scale,
      rotationDeg: rotationDeg ?? this.rotationDeg,
      opacity: opacity ?? this.opacity,
      visible: visible ?? this.visible,
    );
  }
}

class ImageLayerNotifier extends StateNotifier<ImageLayerState> {
  ImageLayerNotifier() : super(const ImageLayerState.initial());

  void set(ImageLayerState s) => state = s;
  void setOffset(double x, double y) =>
      state = state.copyWith(offsetX: x, offsetY: y);
  void setScale(double s) => state = state.copyWith(scale: s);
  void setRotation(double deg) => state = state.copyWith(rotationDeg: deg);
  void setOpacity(double o) =>
      state = state.copyWith(opacity: o.clamp(0.0, 1.0));
  void setVisible(bool v) => state = state.copyWith(visible: v);
}

// Family by imageId so each image gets its own layer state
final imageLayerStateProvider =
    StateNotifierProvider.family<ImageLayerNotifier, ImageLayerState, int>(
        (ref, imageId) {
  return ImageLayerNotifier();
});
