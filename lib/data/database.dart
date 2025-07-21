import 'dart:io';
import 'dart:typed_data';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'database.g.dart';

//-
//-
//-         TABLE DEFINITIONS
//-
//-

// Project Table
class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BlobColumn get imageData => blob()();
  BlobColumn get thumbnailData => blob()();
  BoolColumn get isConverted => boolean().withDefault(const Constant(false))();
  TextColumn get vectorObjects => text().withDefault(const Constant('[]'))();
  RealColumn get imageWidth => real().nullable()();
  RealColumn get imageHeight => real().nullable()();
  IntColumn get uniqueColorCount => integer().nullable()();
  BlobColumn get originalImageData => blob().nullable()();
  RealColumn get originalImageWidth => real().nullable()();
  RealColumn get originalImageHeight => real().nullable()();
  IntColumn get filterQualityIndex =>
      integer().withDefault(const Constant(1))();
  IntColumn get paletteId => integer().nullable().references(Palettes, #id)();
}

// Palette Table
class Palettes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get sizeInMl => real().withDefault(const Constant(60.0))();
  RealColumn get factor => real().withDefault(const Constant(1.5))();
  BlobColumn get thumbnail => blob().nullable()();
}

// Palette Color Table
class PaletteColors extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get paletteId => integer().references(Palettes, #id)();
  TextColumn get title => text()();
  IntColumn get color => integer()();
  TextColumn get status => text().withDefault(const Constant(''))();
}

// Vendor Color Table
class VendorColors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get code => text()();
  TextColumn get imageUrl => text().withDefault(const Constant(''))();
}

@DataClassName('VendorColorVariant')
class VendorColorVariants extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vendorColorId => integer().references(VendorColors, #id)();
  IntColumn get size => integer()();
  IntColumn get stock => integer().withDefault(const Constant(0))();
}

// Color Component Table (linking PaletteColors and VendorColors)
class ColorComponents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get paletteColorId => integer().references(PaletteColors, #id)();
  IntColumn get vendorColorId => integer().references(VendorColors, #id)();
  RealColumn get percentage => real()();
}

//-
//-
//-         DATABASE CLASS
//-
//-

@DriftDatabase(tables: [
  Projects,
  Palettes,
  PaletteColors,
  VendorColors,
  VendorColorVariants,
  ColorComponents
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // This is a safe, additive migration.
        // It will apply changes incrementally without deleting user data.
        if (from < 2) {
          // Version 2 added the imageUrl to vendor colors.
          // Note: The old destructive migration likely handled this, but this is
          // the correct, safe way for any future migrations.
          await m.addColumn(vendorColors, vendorColors.imageUrl);
        }
        if (from < 4) {
          // Version 4 added the variants table.
          await m.createTable(vendorColorVariants);
        }
        if (from < 5) {
          // Version 5 added the components table.
          await m.createTable(colorComponents);
        }
        if (from < 6) {
          // Version 6 added the thumbnail to palettes.
          await m.addColumn(palettes, palettes.thumbnail);
        }
      },
    );
  }

  Future<List<VendorColorWithVariants>> get allVendorColorsWithVariants async {
    final colors = await select(vendorColors).get();
    final variants = await select(vendorColorVariants).get();

    return colors.map((color) {
      final colorVariants = variants
          .where((variant) => variant.vendorColorId == color.id)
          .toList();
      return VendorColorWithVariants(color: color, variants: colorVariants);
    }).toList();
  }

  Future<void> updatePaletteColorWithComponents(
    PaletteColorsCompanion color,
    List<ColorComponentsCompanion> components,
  ) {
    return transaction(() async {
      await update(paletteColors).replace(color);

      // First, delete existing components for this color
      await (delete(colorComponents)
            ..where((c) => c.paletteColorId.equals(color.id.value)))
          .go();

      // Then, insert the new ones
      await batch((batch) {
        batch.insertAll(
          colorComponents,
          components.map(
            (c) => ColorComponentsCompanion(
              paletteColorId: color.id,
              vendorColorId: c.vendorColorId,
              percentage: c.percentage,
            ),
          ),
        );
      });
    });
  }
}

class VendorColorWithVariants {
  final VendorColor color;
  final List<VendorColorVariant> variants;

  VendorColorWithVariants({
    required this.color,
    required this.variants,
  });
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
