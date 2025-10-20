import 'package:flutter_riverpod/flutter_riverpod.dart';

class CanvasSpec {
  const CanvasSpec({
    required this.widthPx,
    required this.heightPx,
  });
  final double widthPx;
  final double heightPx;

  CanvasSpec copyWith({double? widthPx, double? heightPx}) {
    return CanvasSpec(
      widthPx: widthPx ?? this.widthPx,
      heightPx: heightPx ?? this.heightPx,
    );
  }
}

class CanvasSpecNotifier extends StateNotifier<CanvasSpec> {
  CanvasSpecNotifier()
      : super(const CanvasSpec(widthPx: 100.0, heightPx: 100.0));

  void setSpec(CanvasSpec spec) {
    state = spec;
  }
}

final canvasSpecProvider =
    StateNotifierProvider<CanvasSpecNotifier, CanvasSpec>((ref) {
  return CanvasSpecNotifier();
});
