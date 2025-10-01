import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/widgets/input_value_type/number_utils.dart';
import 'package:vettore/providers/image_providers.dart';
import 'package:vettore/providers/project_provider.dart';

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
    final int dpi = ref.read(imageDpiProvider(imageId)).asData?.value ?? 72;
    final int targetW = toPx(widthValue, widthUnit, dpi).round();
    final int targetH = toPx(heightValue, heightUnit, dpi).round();
    if (targetW <= 0 || targetH <= 0) return;
    await ref
        .read(projectLogicProvider(projectId))
        .resizeToCv(targetW, targetH, interpolation);
  }
}
