import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/providers/image_providers.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/widgets/input_value_type/number_utils.dart';

class ImageResizeService {
  const ImageResizeService();

  Future<void> resizeWithTypedUnits({
    required WidgetRef ref,
    required int projectId,
    required double widthValue,
    required String widthUnit,
    required double heightValue,
    required String heightUnit,
    required String interpolation,
  }) async {
    final int? imageId = ref.read(imageIdStableProvider(projectId));
    if (imageId == null) return;
    // Resolve DPI reliably (await provider), default to 96 when missing
    final int dpi = (await ref.read(imageDpiProvider(imageId).future)) ?? 96;
    final int targetW = toPx(widthValue, widthUnit, dpi).round();
    final int targetH = toPx(heightValue, heightUnit, dpi).round();
    if (targetW <= 0 || targetH <= 0) return;
    await ref
        .read(projectLogicProvider(projectId))
        .resizeToCv(targetW, targetH, interpolation);
  }
}
