import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:vettore/data/database.dart';

// A data class to hold a palette and its colors
class FullPalette extends Equatable {
  const FullPalette({required this.palette, required this.colors});
  final Palette palette;
  final List<PaletteColorWithComponents> colors;

  @override
  List<Object?> get props => [palette, colors];
}

class PaletteColorWithComponents extends Equatable {
  const PaletteColorWithComponents(
      {required this.color, required this.components});
  final PaletteColor color;
  final List<ColorComponent> components;

  @override
  List<Object?> get props => [color, components];
}

// An intermediate class to hold the raw results of our join query.
class _PaletteWithColorAndComponent {
  _PaletteWithColorAndComponent(this.palette, this.color, this.component);
  final Palette palette;
  final PaletteColor? color;
  final ColorComponent? component;
}

class PaletteRepository {
  PaletteRepository(this._db);
  final AppDatabase _db;

  // A stream that watches for changes to all palettes and their nested data.
  // This uses an efficient join query to avoid the N+1 problem.
  Stream<List<FullPalette>> watchAllPalettes() {
    final paletteColors = _db.alias(_db.paletteColors, 'c');
    final components = _db.alias(_db.colorComponents, 'comp');

    final query = _db.select(_db.palettes).join([
      leftOuterJoin(
          paletteColors, paletteColors.paletteId.equalsExp(_db.palettes.id)),
      leftOuterJoin(
          components, components.paletteColorId.equalsExp(paletteColors.id)),
    ]);

    return query.watch().map((rows) {
      final results = rows.map((row) {
        return _PaletteWithColorAndComponent(
          row.readTable(_db.palettes),
          row.readTableOrNull(paletteColors),
          row.readTableOrNull(components),
        );
      }).toList();

      // Group by the top-level palette
      final groupedByPalette = groupBy(results, (result) => result.palette.id);

      return groupedByPalette.values.map((paletteRows) {
        final firstRow = paletteRows.first;
        final palette = firstRow.palette;

        // Group the non-null colors for this palette
        final groupedByColor = groupBy(
            paletteRows
                .where((row) => row.color != null)
                .map((row) => row), // No-op map to fix type inference
            (row) => row.color!.id);

        final colorsWithComponents = groupedByColor.values.map((colorRows) {
          final firstColorRow = colorRows.first;
          final color = firstColorRow.color!;

          // Collect all non-null components for this color
          final components = colorRows
              .where((row) => row.component != null)
              .map((row) => row.component!)
              .toList();

          return PaletteColorWithComponents(
              color: color, components: components);
        }).toList();

        return FullPalette(palette: palette, colors: colorsWithComponents);
      }).toList();
    });
  }

  // A stream that watches for changes to a single palette and its nested data.
  // This is now efficient and only queries for the specific palette.
  Stream<FullPalette> watchPalette(int id) {
    return watchAllPalettes().map((list) => list.firstWhere(
        (p) => p.palette.id == id,
        orElse: () =>
            throw Exception('Palette with id $id not found in stream.')));
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
    return _db.transaction(() async {
      // First, get the IDs of all colors in the palette
      final colorsInPalette = await (_db.select(_db.paletteColors)
            ..where((c) => c.paletteId.equals(id)))
          .get();
      final colorIds = colorsInPalette.map((c) => c.id).toList();

      // If there are colors, delete their components first
      if (colorIds.isNotEmpty) {
        await (_db.delete(_db.colorComponents)
              ..where((comp) => comp.paletteColorId.isIn(colorIds)))
            .go();
      }

      // Then delete the colors themselves
      await (_db.delete(_db.paletteColors)
            ..where((c) => c.paletteId.equals(id)))
          .go();

      // Finally, delete the palette
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

  // Find a vendor color by its name (case-insensitive)
  Future<VendorColor?> findVendorColorByName(String name) {
    return (_db.select(_db.vendorColors)
          ..where((c) => c.name.lower().equals(name.toLowerCase())))
        .getSingleOrNull();
  }

  // Create a new palette color with a list of components in a transaction
  Future<void> addColorWithComponents(
      PaletteColorsCompanion color, List<ColorComponentsCompanion> components) {
    return _db.transaction(() async {
      final colorId = await _db.into(_db.paletteColors).insert(color);
      for (final component in components) {
        await _db
            .into(_db.colorComponents)
            .insert(component.copyWith(paletteColorId: Value(colorId)));
      }
    });
  }
}
