import 'package:flutter_riverpod/flutter_riverpod.dart';
// project_provider not needed here
import 'package:vettore/providers/image_providers.dart';
import 'package:vettore/services/settings_service.dart';

class ImageSpec {
  const ImageSpec({this.widthPx, this.heightPx, this.dpi});
  final int? widthPx;
  final int? heightPx;
  final int? dpi;
}

final imageSpecProvider = Provider.family<ImageSpec, int>((ref, imageId) {
  final dims = ref.watch(imageDimensionsProvider(imageId)).asData?.value;
  final dpi = ref.watch(imageDpiProvider(imageId)).asData?.value;
  return ImageSpec(widthPx: dims?.$1, heightPx: dims?.$2, dpi: dpi);
});

// Persist user-selected units per project for Image tab width/height inputs
final imageWidthUnitProvider =
    StateProvider.family<String, int>((ref, projectId) {
  final settings = ref.read(settingsServiceProvider);
  return settings.imageDefaultUnit;
});
final imageHeightUnitProvider =
    StateProvider.family<String, int>((ref, projectId) {
  final settings = ref.read(settingsServiceProvider);
  return settings.imageDefaultUnit;
});
