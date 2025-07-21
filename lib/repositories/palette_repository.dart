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
  Palette? getPalette(int key) {
    return _palettesBox.get(key);
  }

  /// Adds a new palette to the database and returns its key.
  Future<int> addPalette(Palette palette) async {
    return await _palettesBox.add(palette);
  }

  /// Updates an existing palette in the database.
  Future<void> updatePalette(int key, Palette palette) async {
    await _palettesBox.put(key, palette);
  }

  /// Deletes a palette from the database.
  Future<void> deletePalette(int key) async {
    await _palettesBox.delete(key);
  }
}
