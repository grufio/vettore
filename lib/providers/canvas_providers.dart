import 'package:flutter_riverpod/flutter_riverpod.dart';

class CanvasSpec {
  final double widthPx;
  final double heightPx;
  final int dpi;

  const CanvasSpec({
    required this.widthPx,
    required this.heightPx,
    required this.dpi,
  });

  CanvasSpec copyWith({double? widthPx, double? heightPx, int? dpi}) {
    return CanvasSpec(
      widthPx: widthPx ?? this.widthPx,
      heightPx: heightPx ?? this.heightPx,
      dpi: dpi ?? this.dpi,
    );
  }
}

class CanvasSpecNotifier extends StateNotifier<CanvasSpec> {
  CanvasSpecNotifier()
      : super(const CanvasSpec(widthPx: 100.0, heightPx: 100.0, dpi: 72));

  void setSpec(CanvasSpec spec) {
    state = spec;
  }

  void setDpi(int dpi) {
    state = state.copyWith(dpi: dpi);
  }
}

final canvasSpecProvider =
    StateNotifierProvider<CanvasSpecNotifier, CanvasSpec>((ref) {
  return CanvasSpecNotifier();
});
