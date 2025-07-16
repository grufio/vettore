import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vettore/models/color_component_model.dart';
import 'package:vettore/models/palette_color.dart';
import 'package:vettore/models/palette_model.dart';

class PaletteRepository {
  final Box<Palette> _palettesBox;

  PaletteRepository(this._palettesBox);

  ValueListenable<Box<Palette>> getPalettesListenable() {
    return _palettesBox.listenable();
  }

  Palette? getPalette(dynamic key) {
    final palette = _palettesBox.get(key);
    return palette?.copyWith(key: key);
  }

  Future<void> addPalette(Palette palette) async {
    int id = await _palettesBox.add(palette);
    palette.key = id;
    await _palettesBox.put(id, palette);
  }

  Future<void> updatePalette(Palette palette) async {
    await _palettesBox.put(palette.key, palette);
  }

  Future<void> deletePalette(int key) async {
    await _palettesBox.delete(key);
  }
}
