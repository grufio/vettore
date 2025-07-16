import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vettore/models/color_component_model.dart';
import 'package:vettore/models/palette_color.dart';
import 'package:vettore/models/palette_model.dart';

class PaletteRepository {
  final Box<Palette> _palettesBox;

  PaletteRepository(this._palettesBox);

  // Get a listenable value for all palettes
  ValueListenable<Box<Palette>> getPalettesListenable() {
    return _palettesBox.listenable();
  }

  // Get a single palette by its key
  Palette? getPalette(dynamic key) {
    return _palettesBox.get(key);
  }

  // Add a new palette
  Future<void> addPalette(Palette palette) async {
    await _palettesBox.add(palette);
  }

  // Update an existing palette (by saving the object)
  Future<void> updatePalette(Palette palette) async {
    await palette.save();
  }

  // Deep update a single color within a palette to prevent state corruption
  Future<void> updateColor(
    Palette palette,
    int colorIndex,
    PaletteColor updatedColor,
  ) async {
    final targetColor = palette.colors[colorIndex];

    // Update the simple properties
    targetColor.title = updatedColor.title;
    targetColor.color = updatedColor.color;
    targetColor.status = updatedColor.status;

    // Perform a deep delete of old components
    // We use a separate loop for deletion to avoid concurrent modification issues
    final componentsToDelete = List<ColorComponent>.from(
      targetColor.components,
    );
    for (var component in componentsToDelete) {
      await component.delete();
    }
    targetColor.components.clear();

    // Add new, clean components
    for (var componentData in updatedColor.components) {
      final newComponent = ColorComponent(
        name: componentData.name,
        percentage: componentData.percentage,
      );
      targetColor.components.add(newComponent);
    }

    await palette.save();
  }

  // Delete a palette
  Future<void> deletePalette(Palette palette) async {
    await palette.delete();
  }
}
