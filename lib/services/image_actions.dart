import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/providers/image_providers.dart';
import 'package:vettore/services/image_detail_service.dart';

class ImageActions {
  const ImageActions();

  Future<void> resizeCommit(
    WidgetRef ref, {
    required int projectId,
    required int imageId,
    required String interpName,
    required double curPhysW,
    required double curPhysH,
    required double? typedW,
    required String wUnit,
    required double? typedH,
    required String hUnit,
    required int dpi,
    required void Function(double wPx, double hPx) onPhysCommitted,
  }) async {
    final service = ref.read(imageDetailServiceProvider);
    final (double targetPhysW, double targetPhysH) = service.computeTargetPhys(
      typedW: typedW,
      wUnit: wUnit,
      typedH: typedH,
      hUnit: hUnit,
      dpi: dpi,
      curPhysW: curPhysW,
      curPhysH: curPhysH,
      linked: false, // caller passes already linked values if needed
    );
    if (targetPhysW <= 0 || targetPhysH <= 0) return;
    final (int targetW, int targetH) =
        service.rasterFromPhys(targetPhysW, targetPhysH);
    await service.performResize(ref,
        projectId: projectId,
        targetW: targetW,
        targetH: targetH,
        interpolationName: interpName);
    await service.persistPhys(ref, imageId, targetPhysW, targetPhysH);
    onPhysCommitted(targetPhysW, targetPhysH);
    ref.invalidate(imagePhysPixelsProvider(imageId));
  }
}

final imageActionsProvider = Provider<ImageActions>((ref) {
  return const ImageActions();
});


