import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/repositories/palette_repository.dart';

final paletteDetailStreamProvider =
    StreamProvider.autoDispose.family<FullPalette, int>((ref, id) {
  final paletteRepository = ref.watch(paletteRepositoryProvider);
  return paletteRepository.watchPalette(id);
});

final paletteDetailLogicProvider =
    Provider.autoDispose.family<PaletteDetailLogic, int>((ref, id) {
  final paletteRepository = ref.read(paletteRepositoryProvider);
  return PaletteDetailLogic(paletteRepository, id);
});

class PaletteDetailLogic {
  final PaletteRepository _paletteRepository;
  final int _paletteId;

  PaletteDetailLogic(this._paletteRepository, this._paletteId);

  Future<void> updateDetails({
    required String name,
    required double size,
    required double factor,
  }) async {
    final updatedPalette = PalettesCompanion(
      id: Value(_paletteId),
      name: Value(name),
      sizeInMl: Value(size),
      factor: Value(factor),
    );
    await _paletteRepository.updatePaletteDetails(updatedPalette);
  }

  Future<void> addColor(PaletteColorsCompanion color) async {
    await _paletteRepository
        .addColorToPalette(color.copyWith(paletteId: Value(_paletteId)));
  }

  Future<void> updateColor(
    PaletteColorsCompanion color,
    List<ColorComponentsCompanion> components,
  ) async {
    await _paletteRepository.updateColorWithComponents(color, components);
  }

  Future<void> deleteColor(int colorId) async {
    await _paletteRepository.deleteColor(colorId);
  }
}
