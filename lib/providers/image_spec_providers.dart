import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/providers/project_provider.dart';

class ImageSpec {
  final int? widthPx;
  final int? heightPx;
  final int? dpi;
  const ImageSpec({this.widthPx, this.heightPx, this.dpi});
}

final imageSpecProvider = Provider.family<ImageSpec, int>((ref, imageId) {
  final dims = ref.watch(imageDimensionsProvider(imageId)).asData?.value;
  final dpi = ref.watch(imageDpiProvider(imageId)).asData?.value;
  return ImageSpec(widthPx: dims?.$1, heightPx: dims?.$2, dpi: dpi);
});
