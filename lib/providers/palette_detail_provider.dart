import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/repositories/palette_repository.dart';

// Provides a stream of a single palette with all its colors and their components.
final paletteDetailStreamProvider =
    StreamProvider.autoDispose.family<FullPalette, int>((ref, id) {
  final paletteRepository = ref.watch(paletteRepositoryProvider);
  return paletteRepository.watchPalette(id);
});

// Provides a stream of just the components for a single palette color.
final paletteColorComponentsStreamProvider =
    StreamProvider.autoDispose.family<List<ColorComponent>, int>((ref, id) {
  final paletteRepository = ref.watch(paletteRepositoryProvider);
  return paletteRepository.watchColorComponents(id);
});

// Provides the business logic for the palette detail page.
final paletteDetailLogicProvider =
    Provider.autoDispose.family<PaletteDetailLogic, int>((ref, paletteId) {
  final paletteRepository = ref.watch(paletteRepositoryProvider);
  return PaletteDetailLogic(ref, paletteId, paletteRepository);
});

class PaletteDetailLogic {
  final Ref _ref;
  final int paletteId;
  final PaletteRepository _paletteRepository;

  PaletteDetailLogic(this._ref, this.paletteId, this._paletteRepository);

  Future<void> updateDetails({
    required String name,
    required double size,
    required double factor,
  }) async {
    final updatedPalette = PalettesCompanion(
      id: Value(paletteId),
      name: Value(name),
      sizeInMl: Value(size),
      factor: Value(factor),
    );
    await _paletteRepository.updatePaletteDetails(updatedPalette);
  }

  Future<void> updateColorAndComponents(
      PaletteColorsCompanion color, List<ColorComponentsCompanion> components) {
    return _paletteRepository.updateColorWithComponents(color, components);
  }

  Future<void> updateColor(PaletteColorsCompanion color) {
    return _paletteRepository.updateColor(color);
  }

  Future<void> addColor(PaletteColorsCompanion color) async {
    await _paletteRepository.addColorToPalette(color);
  }

  Future<void> deleteColor(int colorId) async {
    await _paletteRepository.deleteColor(colorId);
  }

  Future<void> addComponent(ColorComponentsCompanion component) async {
    await _paletteRepository.addComponent(component);
  }

  Future<void> updateComponent(ColorComponentsCompanion component) async {
    await _paletteRepository.updateComponent(component);
  }

  Future<void> deleteComponent(int componentId) async {
    await _paletteRepository.deleteComponent(componentId);
  }
}
