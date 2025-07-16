import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:vettore/models/color_component_model.dart';
import 'package:vettore/models/palette_model.dart';
import 'package:vettore/models/palette_color.dart';

class MigrationService {
  /// This migration script converts the database from an embedded-document model
  /// for color components to a referenced model.
  ///
  /// IMPORTANT: This script is designed to be run ONCE.
  /// It assumes that the PaletteColor model has been temporarily modified
  /// to contain BOTH the old `List<ColorComponent> components` field and the
  /// new `List<int> componentKeys` field.
  static Future<void> migrateComponentsToSeparateBox() async {
    debugPrint('Starting database migration...');

    final palettesBox = Hive.box<Palette>('palettes');
    final componentsBox = Hive.box<ColorComponent>('color_components');

    if (palettesBox.isEmpty) {
      debugPrint('No palettes found. Migration not needed.');
      return;
    }

    // A simple check to prevent re-running the migration.
    final firstPalette = palettesBox.values.first;
    if (firstPalette.colors.isNotEmpty &&
        firstPalette.colors.first.componentKeys.isNotEmpty) {
      debugPrint('Migration appears to have already been completed. Skipping.');
      return;
    }

    debugPrint('Found ${palettesBox.length} palettes to migrate.');

    final palettesToUpdate = palettesBox.values.toList();

    for (final palette in palettesToUpdate) {
      for (final color in palette.colors) {
        // Only migrate if there are components and keys are empty
        if (color.components.isNotEmpty && color.componentKeys.isEmpty) {
          final List<int> newKeys = [];
          for (final component in color.components) {
            // Add component to its own box and get its new auto-incrementing key
            final newKey = await componentsBox.add(component);
            newKeys.add(newKey);
          }
          // Assign the new list of keys
          color.componentKeys = newKeys;
        }
      }
      // Save the entire palette with the updated color objects
      await palettesBox.put(palette.key, palette);
    }

    debugPrint('Migration complete: All component keys have been populated.');
  }
}
