import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

//-
//-
//-         TABLE DEFINITIONS
//-
//-

// (Legacy Projects table removed)

// Palette Table
class Palettes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get sizeInMl => real().withDefault(const Constant(60.0))();
  RealColumn get factor => real().withDefault(const Constant(1.5))();
  BlobColumn get thumbnail => blob().nullable()();
  BoolColumn get isPredefined => boolean().withDefault(const Constant(false))();
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
  RealColumn get weightInGrams => real().nullable()();
  RealColumn get colorDensity => real().nullable()();
}

@DataClassName('VendorColorVariant')
class VendorColorVariants extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vendorColorId => integer().references(VendorColors, #id)();
  IntColumn get size => integer()();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  RealColumn get weightInGrams => real().nullable()();
}

// Color Component Table (linking PaletteColors and VendorColors)
class ColorComponents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get paletteColorId => integer().references(PaletteColors, #id)();
  IntColumn get vendorColorId => integer().references(VendorColors, #id)();
  RealColumn get percentage => real()();
}

// Settings Table
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

// Images Table (new)
@DataClassName('DbImage')
class Images extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Original image
  BlobColumn get origSrc => blob().nullable()();
  IntColumn get origBytes => integer().nullable()();
  IntColumn get origWidth => integer().nullable()();
  IntColumn get origHeight => integer().nullable()();
  IntColumn get origUniqueColors => integer().nullable()();

  // Converted image
  BlobColumn get convSrc => blob().nullable()();
  IntColumn get convBytes => integer().nullable()();
  IntColumn get convWidth => integer().nullable()();
  IntColumn get convHeight => integer().nullable()();
  IntColumn get convUniqueColors => integer().nullable()();

  // Extras
  BlobColumn get thumbnail => blob().nullable()();
  TextColumn get mimeType => text().nullable()();
}

// Projects Table (renamed from ProjectsNew)
@DataClassName('DbProject')
class Projects extends Table {
  @override
  String get tableName => 'projects';
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get author => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  IntColumn get createdAt => integer()(); // unix ms
  IntColumn get updatedAt => integer()(); // unix ms
  IntColumn get imageId => integer()
      .nullable()
      .references(Images, #id, onDelete: KeyAction.setNull)();
}

//-
//-
//-         DATABASE CLASS
//-
//-

@DriftDatabase(tables: [
  Palettes,
  PaletteColors,
  VendorColors,
  VendorColorVariants,
  ColorComponents,
  Settings,
  Images,
  Projects
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 14;

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
        if (from < 7) {
          // Version 7 added the weight to vendor color variants.
          await m.addColumn(
              vendorColorVariants, vendorColorVariants.weightInGrams);
        }
        if (from < 8) {
          // Version 8 adds the corrected weight column to the main color table.
          await m.addColumn(vendorColors, vendorColors.weightInGrams);
        }
        if (from < 9) {
          // Version 9 adds the color density column.
          await m.addColumn(vendorColors, vendorColors.colorDensity);
        }
        // Legacy migrations referencing old Projects table removed
        if (from < 11) {
          // Version 11 adds the isPredefined flag to palettes.
          await m.addColumn(palettes, palettes.isPredefined);
        }
        if (from < 12) {
          // Version 12 adds the settings table.
          await m.createTable(settings);
        }
        if (from < 13) {
          // Create new tables directly when upgrading from very old versions.
          await m.createTable(images);
          await m.createTable(projects);
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_projects_updatedAt ON projects(updatedAt)');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_projects_title ON projects(title)');
          await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status)');
        }
      },
    );
  }

  Future<void> updatePaletteColorWithComponents(
    PaletteColorsCompanion color,
    List<ColorComponentsCompanion> components,
  ) {
    return transaction(() async {
      // First, update the color itself.
      await update(paletteColors).replace(color);

      // Then, delete all existing components for this color.
      await (delete(colorComponents)
            ..where((c) => c.paletteColorId.equals(color.id.value)))
          .go();

      // Finally, insert the new components.
      await batch((batch) {
        batch.insertAll(
          colorComponents,
          components.map(
            (c) => c.copyWith(paletteColorId: color.id),
          ),
        );
      });
    });
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
    final file = File(p.join(dbFolder.path, 'db_grufio.sqlite'));
    return NativeDatabase(file);
  });
}
