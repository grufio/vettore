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
class Vendors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get vendorName => text()();
  TextColumn get vendorBrand => text()();
}

class VendorColors extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vendorId => integer().nullable().references(Vendors, #id)();
  TextColumn get name => text()();
  TextColumn get code => text()();
  TextColumn get imageUrl => text().withDefault(const Constant(''))();
  RealColumn get weightInGrams => real().nullable()();
  RealColumn get colorDensity => real().nullable()();
  TextColumn get pigmentCode => text().nullable()();
  TextColumn get opacity => text().nullable()();
  IntColumn get lightfastness => integer().nullable()();
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

// Lego Colors Table (official)
@DataClassName('DbLegoColor')
class LegoColors extends Table {
  IntColumn get blColorId => integer().named('bl_color_id')();
  TextColumn get name => text()();
  TextColumn get rgbHex => text().named('rgb_hex').nullable()();
  IntColumn get startYear => integer().named('start_year').nullable()();
  IntColumn get endYear => integer().named('end_year').nullable()();
  TextColumn get groupName => text().named('group').nullable()();

  @override
  Set<Column> get primaryKey => {blColorId};
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
  Vendors,
  VendorColors,
  VendorColorVariants,
  ColorComponents,
  Settings,
  Images,
  Projects,
  LegoColors
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 18;

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
        if (from < 15) {
          // Introduce vendors table and link vendor_colors to vendors
          // Create vendors table if missing (snake_case)
          await m.database.customStatement(
              "CREATE TABLE IF NOT EXISTS vendors (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, vendor_name TEXT NOT NULL, vendor_brand TEXT NOT NULL)");
          // Add vendor_id to vendor_colors if it doesn't exist
          final hasVendorId = await m.database
              .customSelect(
                  "SELECT 1 FROM pragma_table_info('vendor_colors') WHERE name = 'vendor_id' LIMIT 1")
              .get();
          if (hasVendorId.isEmpty) {
            await m.addColumn(vendorColors, vendorColors.vendorId);
          }
          // Seed a default vendor (Schmincke / Norma professional) and backfill existing rows
          await m.database.customStatement(
              "INSERT INTO vendors (vendor_name, vendor_brand) SELECT 'Schmincke','Norma professional' WHERE NOT EXISTS (SELECT 1 FROM vendors WHERE vendor_brand='Norma professional')");
          await m.database.customStatement(
              "UPDATE vendor_colors SET vendor_id = (SELECT id FROM vendors WHERE vendor_brand='Norma professional' LIMIT 1) WHERE vendor_id IS NULL");
          // Helpful indexes (snake_case)
          await m.database.customStatement(
              'CREATE INDEX IF NOT EXISTS idx_vendor_colors_vendor_id ON vendor_colors(vendor_id)');
          await m.database.customStatement(
              'CREATE UNIQUE INDEX IF NOT EXISTS idx_vendor_colors_vendor_code ON vendor_colors(vendor_id, code)');
        }
        if (from < 16) {
          // Add pigment_code, opacity, lightfastness to vendor_colors (guarded)
          final hasPigment = await m.database
              .customSelect(
                  "SELECT 1 FROM pragma_table_info('vendor_colors') WHERE name = 'pigment_code' LIMIT 1")
              .get();
          if (hasPigment.isEmpty) {
            await m.addColumn(vendorColors, vendorColors.pigmentCode);
          }
          final hasOpacity = await m.database
              .customSelect(
                  "SELECT 1 FROM pragma_table_info('vendor_colors') WHERE name = 'opacity' LIMIT 1")
              .get();
          if (hasOpacity.isEmpty) {
            await m.addColumn(vendorColors, vendorColors.opacity);
          }
          final hasLf = await m.database
              .customSelect(
                  "SELECT 1 FROM pragma_table_info('vendor_colors') WHERE name = 'lightfastness' LIMIT 1")
              .get();
          if (hasLf.isEmpty) {
            await m.addColumn(vendorColors, vendorColors.lightfastness);
          }
        }
        if (from < 17) {
          // previous temp table version; ignore
        }
        if (from < 18) {
          await m.database.customStatement('DROP TABLE IF EXISTS lego_colors');
          await m.database
              .customStatement('CREATE TABLE IF NOT EXISTS lego_colors ('
                  'bl_color_id INTEGER PRIMARY KEY NOT NULL, '
                  'name TEXT NOT NULL, '
                  'rgb_hex TEXT, '
                  'start_year INTEGER, '
                  'end_year INTEGER, '
                  '"group" TEXT)');
          await m.database.customStatement(
              'CREATE INDEX IF NOT EXISTS idx_lego_colors_name ON lego_colors(name)');
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
