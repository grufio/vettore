
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

  Future<void> importAiRecipe(
      int paletteId, int colorId, Uint8List imageData) async {
    final aiService = _ref.read(aiServiceProvider);

    try {
      // 1. Get the recipe from the AI service
      final recipeData = await aiService.importRecipeFromImage(imageData);
      final componentsData = recipeData['components'] as List<dynamic>;

      final newComponents = <ColorComponentsCompanion>[];
      for (final componentData in componentsData) {
        final vendorColorName = componentData['name'] as String?;
        final percentage = (componentData['percentage'] as num?)?.toDouble();

        if (vendorColorName == null || percentage == null) continue;

        final vendorColor =
            await _paletteRepository.findVendorColorByName(vendorColorName);
        if (vendorColor != null) {
          newComponents.add(
            ColorComponentsCompanion.insert(
              paletteColorId: colorId,
              vendorColorId: vendorColor.id,
              percentage: percentage,
            ),
          );
        }
      }

      if (newComponents.isEmpty) {
        throw Exception(
            'Could not match any of the AI-detected colors to the vendor library.');
      }

      // 2. Get the full, existing color object to satisfy the `replace` operation.
      final fullPalette =
          await _ref.read(paletteDetailStreamProvider(paletteId).future);
      final existingColor =
          fullPalette.colors.firstWhere((c) => c.color.id == colorId);

      // 3. Create a complete companion for the update.
      final colorToUpdate = PaletteColorsCompanion(
        id: Value(colorId),
        paletteId: Value(existingColor.color.paletteId),
        title: Value(existingColor.color.title),
        color: Value(existingColor.color.color),
        status: Value(existingColor.color.status),
      );

      // 4. Replace the old components with the new ones.
      await _paletteRepository.updateColorWithComponents(
          colorToUpdate, newComponents);
    } catch (e) {
      // Rethrow the exception to be caught by the UI layer
      rethrow;
    }
  }
}
