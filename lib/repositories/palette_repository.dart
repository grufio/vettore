import 'package:vettore/data/database.dart';
import 'package:drift/drift.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

// A data class to hold a palette and its colors
class FullPalette extends Equatable {
  final Palette palette;
  final List<PaletteColorWithComponents> colors;

  const FullPalette({required this.palette, required this.colors});

  @override
  List<Object?> get props => [palette, colors];
}

class PaletteColorWithComponents extends Equatable {
  final PaletteColor color;
  final List<ColorComponent> components;

  const PaletteColorWithComponents(
      {required this.color, required this.components});

  @override
  List<Object?> get props => [color, components];
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

  // Updates the colors for a given palette, replacing all old colors.
  Future<void> updatePaletteColors(
      int paletteId, List<PaletteColorsCompanion> newColors) {
    return _db.transaction(() async {
      // First, delete all existing colors (and their components) for the palette.
      final colorsInPalette = await (_db.select(_db.paletteColors)
            ..where((c) => c.paletteId.equals(paletteId)))
          .get();
      final colorIds = colorsInPalette.map((c) => c.id).toList();

      if (colorIds.isNotEmpty) {
        await (_db.delete(_db.colorComponents)
              ..where((comp) => comp.paletteColorId.isIn(colorIds)))
            .go();
        await (_db.delete(_db.paletteColors)
              ..where((c) => c.paletteId.equals(paletteId)))
            .go();
      }

      // Then, insert the new colors.
      for (final color in newColors) {
        await _db.into(_db.paletteColors).insert(color);
      }
    });
  }

  // Delete a palette and all its associated colors
  Future<void> deletePalette(int id) {
    print('[DeletePalette] Starting transaction for palette ID: $id');
    return _db.transaction(() async {
      // First, get the IDs of all colors in the palette
      print('[DeletePalette] Getting color IDs for palette $id...');
      final colorsInPalette = await (_db.select(_db.paletteColors)
            ..where((c) => c.paletteId.equals(id)))
          .get();
      final colorIds = colorsInPalette.map((c) => c.id).toList();
      print('[DeletePalette] Found ${colorIds.length} colors.');

      // If there are colors, delete their components first
      if (colorIds.isNotEmpty) {
        print(
            '[DeletePalette] Deleting components for color IDs: $colorIds...');
        await (_db.delete(_db.colorComponents)
              ..where((comp) => comp.paletteColorId.isIn(colorIds)))
            .go();
        print('[DeletePalette] Components deleted.');
      }

      // Then delete the colors themselves
      print('[DeletePalette] Deleting colors for palette ID: $id...');
      await (_db.delete(_db.paletteColors)
            ..where((c) => c.paletteId.equals(id)))
          .go();
      print('[DeletePalette] Colors deleted.');

      // Finally, delete the palette
      print('[DeletePalette] Deleting palette with ID: $id...');
      await (_db.delete(_db.palettes)..where((p) => p.id.equals(id))).go();
      print('[DeletePalette] Palette deleted. Transaction complete.');
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
