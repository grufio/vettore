import 'package:vettore/data/database.dart';
import 'package:drift/drift.dart';
import 'package:collection/collection.dart';

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

// An intermediate class to hold the raw results of our join query.
class _FullPaletteRow {
  final Palette palette;
  final PaletteColor color;
  final ColorComponent? component;

  _FullPaletteRow(this.palette, this.color, this.component);
}

class PaletteRepository {
  final AppDatabase _db;

  PaletteRepository(this._db);

  // A stream that watches for changes to all palettes and their nested data.
  // This now uses a single, efficient join query.
  Stream<List<FullPalette>> watchAllPalettes() {
    final query = _db.select(_db.palettes).join([
      leftOuterJoin(_db.paletteColors,
          _db.paletteColors.paletteId.equalsExp(_db.palettes.id)),
      leftOuterJoin(_db.colorComponents,
          _db.colorComponents.paletteColorId.equalsExp(_db.paletteColors.id)),
    ]);

    return query.watch().map((rows) {
      final groupedByPalette = <Palette, List<_FullPaletteRow>>{};
      for (final row in rows) {
        final palette = row.readTable(_db.palettes);
        final color = row.readTableOrNull(_db.paletteColors);
        final component = row.readTableOrNull(_db.colorComponents);

        if (color != null) {
          final paletteRow = _FullPaletteRow(palette, color, component);
          (groupedByPalette[palette] ??= []).add(paletteRow);
        } else {
          // Ensure palettes with no colors are still included
          groupedByPalette.putIfAbsent(palette, () => []);
        }
      }

      return groupedByPalette.entries.map((entry) {
        final palette = entry.key;
        final rows = entry.value;

        final groupedByColor = groupBy(rows, (row) => row.color);

        final colorsWithComponents = groupedByColor.entries.map((colorEntry) {
          final color = colorEntry.key;
          final colorRows = colorEntry.value;
          final components = colorRows
              .map((r) => r.component)
              .whereType<ColorComponent>()
              .toList();
          return PaletteColorWithComponents(
              color: color, components: components);
        }).toList();

        return FullPalette(palette: palette, colors: colorsWithComponents);
      }).toList();
    });
  }

  // A stream that watches for changes to a single palette and its nested data.
  // This also now uses a single, efficient join query.
  Stream<FullPalette> watchPalette(int id) {
    return watchAllPalettes()
        .map((list) => list.firstWhere((p) => p.palette.id == id));
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
