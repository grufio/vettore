import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grufio/providers/image_providers.dart';
import 'package:grufio/widgets/input_value_type/unit_value_controller.dart';

/// Controller to centralize image detail state: units, DPI, and dimension seeding.
/// This is a minimal introduction used by the Image Detail page, so it wraps
/// two UnitValueControllers and provides a small API surface. Further logic can
/// be migrated here in subsequent steps.
class ImageDetailController extends ChangeNotifier {
  ImageDetailController({
    String initialWidthUnit = 'px',
    String initialHeightUnit = 'px',
    int uiDpi = 96,
  })  : _widthVC = UnitValueController(unit: initialWidthUnit, dpi: uiDpi),
        _heightVC = UnitValueController(unit: initialHeightUnit, dpi: uiDpi);

  final UnitValueController _widthVC;
  final UnitValueController _heightVC;

  UnitValueController get widthVC => _widthVC;
  UnitValueController get heightVC => _heightVC;

  void setUiDpi(int dpi) {
    if (dpi <= 0) return;
    _widthVC.setDpi(dpi);
    _heightVC.setDpi(dpi);
  }

  void setUnits({String? widthUnit, String? heightUnit}) {
    if (widthUnit != null) _widthVC.setUnit(widthUnit);
    if (heightUnit != null) _heightVC.setUnit(heightUnit);
  }

  /// Hooks to persist unit changes (wired by the page with project context)
  void Function(String unit)? onWidthUnitChanged;
  void Function(String unit)? onHeightUnitChanged;

  void handleWidthUnitChange(String unit) {
    _widthVC.setUnit(unit);
    onWidthUnitChanged?.call(unit);
  }

  void handleHeightUnitChange(String unit) {
    _heightVC.setUnit(unit);
    onHeightUnitChanged?.call(unit);
  }

  /// Apply remote physical pixel values (4-dec floats)
  void applyRemotePx({double? widthPx, double? heightPx}) {
    if (widthPx != null) _widthVC.setValuePx(widthPx);
    if (heightPx != null) _heightVC.setValuePx(heightPx);
    if (widthPx != null && heightPx != null && widthPx > 0) {
      _widthVC.setAspect(heightPx / widthPx);
    }
  }

  // Listening plumbing
  int? _lastDimsImageId;

  // Listen to physical pixel values and seed controllers with floats
  void listenImagePhysPx({
    required WidgetRef ref,
    required int imageId,
    required void Function(double? widthPx, double? heightPx) onDims,
  }) {
    if (_lastDimsImageId == imageId) return;
    _lastDimsImageId = imageId;
    ref.listen<AsyncValue<(double?, double?)>>(
      imagePhysPixelsProvider(imageId),
      (prev, next) {
        final (double?, double?)? dims = next.asData?.value;
        if (dims != null) {
          onDims(dims.$1, dims.$2);
        }
      },
    );
    final (double?, double?)? seed =
        ref.read(imagePhysPixelsProvider(imageId)).asData?.value;
    if (seed != null) {
      onDims(seed.$1, seed.$2);
    }
  }
}
