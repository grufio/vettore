import 'dart:ui';

import 'package:vettore/widgets/input_value_type/unit_conversion.dart';

/// Returns the canvas preview size in pixels for on-screen rendering only.
/// Strictly derived from the project's stored value+unit; no image coupling.
Size getCanvasPreviewPx({
  required double widthValue,
  required String widthUnit,
  required double heightValue,
  required String heightUnit,
  int previewDpi = 96,
}) {
  // Convert via shared unit conversion helper
  final double wPx = convertUnit(
    value: widthValue,
    fromUnit: widthUnit,
    toUnit: 'px',
    dpi: previewDpi,
  );
  final double hPx = convertUnit(
    value: heightValue,
    fromUnit: heightUnit,
    toUnit: 'px',
    dpi: previewDpi,
  );
  return Size(wPx, hPx);
}

/// Returns image preview size in pixels from image metadata only.
/// Independent from any canvas fields.
Size getImagePreviewPx({
  required int? width,
  required int? height,
}) {
  final double w = (width ?? 0).toDouble();
  final double h = (height ?? 0).toDouble();
  return Size(w, h);
}
