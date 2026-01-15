import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore_for_file: always_use_package_imports
import '../providers/application_providers.dart';
import '../providers/image_providers.dart';
import '../widgets/input_value_type/unit_conversion.dart';

class ImageDetailService {
  const ImageDetailService();

  /// Convert a user-typed value in [unit] to physical pixels (float) using [dpi].
  double toPhysPx(double value, String unit, int dpi) {
    return convertUnit(value: value, fromUnit: unit, toUnit: 'px', dpi: dpi);
  }

  /// Compute physical target pixels, keeping the untouched side from current phys,
  /// and using aspect ratio when [linked] is true.
  (double, double) computeTargetPhys({
    required double? typedW,
    required String wUnit,
    required double? typedH,
    required String hUnit,
    required int dpi,
    required double curPhysW,
    required double curPhysH,
    required bool linked,
  }) {
    double targetPhysW =
        (typedW != null) ? toPhysPx(typedW, wUnit, dpi) : curPhysW;
    double targetPhysH =
        (typedH != null) ? toPhysPx(typedH, hUnit, dpi) : curPhysH;
    if (linked && curPhysW > 0 && curPhysH > 0) {
      if (typedW != null && typedH == null) {
        targetPhysH = targetPhysW * (curPhysH / curPhysW);
      } else if (typedH != null && typedW == null) {
        targetPhysW = targetPhysH * (curPhysW / curPhysH);
      }
    }
    return (targetPhysW, targetPhysH);
  }

  /// Round physical floats to raster integer pixels for OpenCV/preview.
  (int, int) rasterFromPhys(double physW, double physH) {
    return (physW.round(), physH.round());
  }

  /// Persist physical floats to DB for an image id.
  Future<void> persistPhys(
      WidgetRef ref, int imageId, double physW, double physH) async {
    final repo = ref.read(imageRepositoryPgProvider);
    final int? dpi = await repo.getDpi(imageId);
    await repo.setDpiAndPhys(imageId, dpi ?? 96, physW, physH);
    ref.invalidate(imagePhysPixelsProvider(imageId));
  }

  /// Perform resize using OpenCV via project provider and invalidate raster providers.
  Future<void> performResize(
    WidgetRef ref, {
    required int projectId,
    required int targetW,
    required int targetH,
    required String interpolationName,
  }) async {
    await ref
        .read(projectLogicProvider(projectId))
        .resizeToCv(targetW, targetH, interpolationName);
    final int? imageId = ref.read(imageIdStableProvider(projectId));
    if (imageId != null) {
      ref.invalidate(imageBytesProvider(imageId));
      // Raster dimensions provider removed; preview size should derive from bytes.
    }
  }
}

final imageDetailServiceProvider = Provider<ImageDetailService>((ref) {
  return const ImageDetailService();
});
