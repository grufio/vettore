import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vettore/models/palette_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  // Delete a palette
  Future<void> deletePalette(Palette palette) async {
    await palette.delete();
  }
}
