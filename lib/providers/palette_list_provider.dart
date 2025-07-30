import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/repositories/palette_repository.dart';

final paletteListStreamProvider =
    StreamProvider.autoDispose<List<FullPalette>>((ref) {
  final paletteRepository = ref.watch(paletteRepositoryProvider);
  return paletteRepository.watchAllPalettes();
});

final paletteListLogicProvider = Provider((ref) {
  return PaletteListLogic(ref);
});

class PaletteListLogic {
  final Ref _ref;

  PaletteListLogic(this._ref);

  Future<void> createNewCustomPalette(String name) async {
    final paletteRepository = _ref.read(paletteRepositoryProvider);
    final newPalette = PalettesCompanion.insert(
      name: name,
      isPredefined:
          const Value(true), // Corrected: Custom palettes are 'predefined'
    );
    await paletteRepository.addPalette(newPalette, []);
  }

  Future<void> deletePalette(int id) async {
    final projectRepository = _ref.read(projectRepositoryProvider);
    final paletteRepository = _ref.read(paletteRepositoryProvider);

    // Find the project associated with this palette
    final project = await projectRepository.findProjectByPaletteId(id);

    if (project != null) {
      // If a project is found, reset it. The reset logic handles clearing the palette.
      await _ref.read(projectLogicProvider(project.id)).resetImage();
    } else {
      // If no project is found (orphaned palette), just delete the palette.
      await paletteRepository.deletePalette(id);
    }
  }

  Future<void> createPaletteFromAiRecipe(
      Uint8List imageData, String paletteName) async {
    final aiService = _ref.read(aiServiceProvider);
    final paletteRepository = _ref.read(paletteRepositoryProvider);

    // 1. Get the recipe from the AI service
    final recipeData = await aiService.importRecipeFromImage(imageData);
    final componentsData = recipeData['components'] as List<dynamic>? ?? [];

    if (componentsData.isEmpty) {
      throw Exception('AI could not find any color components in the image.');
    }

    // 2. Create the new palette
    final newPalette = PalettesCompanion.insert(name: paletteName);
    final paletteId = await paletteRepository.addPalette(newPalette, []);

    // 3. Process each color component from the recipe
    for (final colorData in componentsData) {
      final colorName = colorData['name'] as String?;
      if (colorName == null) continue;

      final colorComponentsList = <ColorComponentsCompanion>[];
      double totalPercentage = 0;

      // Assuming `colorData['components']` is the list of vendor colors
      final subComponents = colorData['components'] as List<dynamic>? ?? [];

      for (final componentData in subComponents) {
        final vendorColorName = componentData['name'] as String?;
        final percentage = (componentData['percentage'] as num?)?.toDouble();

        if (vendorColorName == null || percentage == null) continue;

        final vendorColor =
            await paletteRepository.findVendorColorByName(vendorColorName);
        if (vendorColor != null) {
          colorComponentsList.add(
            ColorComponentsCompanion.insert(
              paletteColorId: -1, // Dummy ID, will be replaced in repo
              vendorColorId: vendorColor.id,
              percentage: percentage,
            ),
          );
          totalPercentage += percentage;
        }
      }

      if (colorComponentsList.isNotEmpty) {
        // Normalize percentages if they don't add up to 100
        if (totalPercentage != 100.0 && totalPercentage > 0) {
          for (int i = 0; i < colorComponentsList.length; i++) {
            final oldComp = colorComponentsList[i];
            colorComponentsList[i] = oldComp.copyWith(
              percentage:
                  Value((oldComp.percentage.value / totalPercentage) * 100.0),
            );
          }
        }

        // TODO: Calculate the mixed color
        final newColor = PaletteColorsCompanion.insert(
          paletteId: paletteId,
          title: colorName,
          color: Colors.grey.value, // Placeholder color
        );
        await paletteRepository.addColorWithComponents(
            newColor, colorComponentsList);
      }
    }
  }
}
