import 'package:vettore/data/database.dart';
import 'package:drift/drift.dart';

// A data class to hold a palette and its colors
class FullPalette {
  final Palette palette;
  final List<PaletteColorWithComponents> colors;

  FullPalette({required this.palette, required this.colors});
}

class PaletteColorWithComponents {
  final PaletteColor color;
  final List<ColorComponent> components;

  PaletteColorWithComponents({required this.color, required this.components});
}

class PaletteRepository {
  final AppDatabase _db;

  PaletteRepository(this._db);

  // Watch for changes to all palettes and their colors
  Stream<List<FullPalette>> watchAllPalettes() {
    final paletteStream = _db.select(_db.palettes).watch();

    return paletteStream.asyncMap((palettes) async {
      final fullPalettes = <FullPalette>[];
      for (final palette in palettes) {
        final colors = await (_db.select(_db.paletteColors)
              ..where((c) => c.paletteId.equals(palette.id)))
            .get();

        final colorsWithComponents = <PaletteColorWithComponents>[];
        for (final color in colors) {
          final components = await (_db.select(_db.colorComponents)
                ..where((c) => c.paletteColorId.equals(color.id)))
              .get();
          colorsWithComponents.add(
              PaletteColorWithComponents(color: color, components: components));
        }
        fullPalettes
            .add(FullPalette(palette: palette, colors: colorsWithComponents));
      }
      return fullPalettes;
    });
  }

  // Get a single full palette by its ID
  Stream<FullPalette> watchPalette(int id) {
    final paletteQuery =
        (_db.select(_db.palettes)..where((p) => p.id.equals(id)));
    final colorsQuery =
        (_db.select(_db.paletteColors)..where((c) => c.paletteId.equals(id)));

    return paletteQuery.watchSingle().asyncExpand((palette) {
      return colorsQuery.watch().asyncMap((colors) async {
        final colorsWithComponents = <PaletteColorWithComponents>[];
        for (final color in colors) {
          final components = await (_db.select(_db.colorComponents)
                ..where((c) => c.paletteColorId.equals(color.id)))
              .get();
          colorsWithComponents.add(
              PaletteColorWithComponents(color: color, components: components));
        }
        return FullPalette(palette: palette, colors: colorsWithComponents);
      });
    });
  }

  // Add a new palette with its colors
  Future<int> addPalette(
      PalettesCompanion palette, List<PaletteColorsCompanion> colors) {
    return _db.transaction(() async {
      final paletteId = await _db.into(_db.palettes).insert(palette);
      for (final color in colors) {
        await _db
            .into(_db.paletteColors)
            .insert(color.copyWith(paletteId: Value(paletteId)));
      }
      return paletteId;
    });
  }

  // Delete a palette and all its associated colors
  Future<void> deletePalette(int id) {
    return _db.transaction(() async {
      await (_db.delete(_db.paletteColors)
            ..where((c) => c.paletteId.equals(id)))
          .go();
      await (_db.delete(_db.palettes)..where((p) => p.id.equals(id))).go();
    });
  }

  // Update a palette's details
  Future<void> updatePaletteDetails(PalettesCompanion palette) {
    return _db.update(_db.palettes).replace(palette);
  }

  // Add a new color to an existing palette
  Future<void> addColorToPalette(PaletteColorsCompanion color) {
    return _db.into(_db.paletteColors).insert(color);
  }

  // Update an existing color
  Future<void> updateColor(PaletteColorsCompanion color) {
    return _db.update(_db.paletteColors).replace(color);
  }

  Future<void> updateColorWithComponents(
    PaletteColorsCompanion color,
    List<ColorComponentsCompanion> components,
  ) {
    return _db.updatePaletteColorWithComponents(color, components);
  }

  // Delete a color from a palette
  Future<void> deleteColor(int id) {
    return (_db.delete(_db.paletteColors)..where((c) => c.id.equals(id))).go();
  }

  //-
  //-         Palette Color Component Methods
  //-

  Future<int> addComponent(ColorComponentsCompanion component) =>
      _db.into(_db.colorComponents).insert(component);

  Future<bool> updateComponent(ColorComponentsCompanion component) =>
      _db.update(_db.colorComponents).replace(component);

  Future<int> deleteComponent(int id) =>
      (_db.delete(_db.colorComponents)..where((c) => c.id.equals(id))).go();

  Stream<List<ColorComponent>> watchColorComponents(int paletteColorId) {
    return (_db.select(_db.colorComponents)
          ..where((c) => c.paletteColorId.equals(paletteColorId)))
        .watch();
  }
}
