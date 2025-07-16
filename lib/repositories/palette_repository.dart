import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vettore/models/palette_model.dart';

/// A repository that handles all the database operations for palettes.
class PaletteRepository {
  final Box<Palette> _palettesBox;

  PaletteRepository(this._palettesBox);

  /// Returns a [ValueListenable] that can be used to listen for changes
  /// to the palettes box.
  ValueListenable<Box<Palette>> getPalettesListenable() {
    return _palettesBox.listenable();
  }

  /// Returns a single palette from the database.
  Palette? getPalette(dynamic key) {
    final palette = _palettesBox.get(key);
    return palette?.copyWith(key: key);
  }

  /// Adds a new palette to the database.
  Future<void> addPalette(Palette palette) async {
    int id = await _palettesBox.add(palette);
    palette.key = id;
    await _palettesBox.put(id, palette);
  }

  /// Updates an existing palette in the database.
  Future<void> updatePalette(Palette palette) async {
    await _palettesBox.put(palette.key, palette);
  }

  /// Deletes a palette from the database.
  Future<void> deletePalette(int key) async {
    await _palettesBox.delete(key);
  }
}
