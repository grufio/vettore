import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
  // Classification for filtering in UI (e.g., 'bricks', 'colors')
  TextColumn get vendorCategory => text().nullable()();
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
  // Original DPI (immutable, from metadata)
  IntColumn get origDpi => integer().named('orig_dpi').nullable()();

  // Converted image
  BlobColumn get convSrc => blob().nullable()();
  IntColumn get convBytes => integer().nullable()();
  IntColumn get convWidth => integer().nullable()();
  IntColumn get convHeight => integer().nullable()();
  IntColumn get convUniqueColors => integer().nullable()();
  // Current DPI (mutable, user-editable)
  IntColumn get dpi => integer().named('dpi').nullable()();

  // Extras
  BlobColumn get thumbnail => blob().nullable()();
  TextColumn get mimeType => text().nullable()();

  // Image layer transform (non-destructive placement over canvas)
  RealColumn get layerOffsetX => real().named('layer_offset_x').nullable()();
  RealColumn get layerOffsetY => real().named('layer_offset_y').nullable()();
  RealColumn get layerScale => real().named('layer_scale').nullable()();
  RealColumn get layerRotationDeg =>
      real().named('layer_rotation_deg').nullable()();
  RealColumn get layerOpacity => real().named('layer_opacity').nullable()();
  BoolColumn get layerVisible => boolean().named('layer_visible').nullable()();
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
  // Model and selected vendor for this project
  TextColumn get model => text().nullable()(); // 'bricks' | 'colors'
  IntColumn get vendorId => integer()
      .nullable()
      .references(Vendors, #id, onDelete: KeyAction.setNull)();
  // Canvas spec stored in pixels (independent of image dpi)
  IntColumn get canvasWidthPx =>
      integer().named('canvas_width_px').withDefault(const Constant(100))();
  IntColumn get canvasHeightPx =>
      integer().named('canvas_height_px').withDefault(const Constant(100))();
  // New: store canvas value + unit (e.g., 100 mm)
  RealColumn get canvasWidthValue =>
      real().named('canvas_width_value').withDefault(const Constant(100.0))();
  TextColumn get canvasWidthUnit =>
      text().named('canvas_width_unit').withDefault(const Constant('mm'))();
  RealColumn get canvasHeightValue =>
      real().named('canvas_height_value').withDefault(const Constant(100.0))();
  TextColumn get canvasHeightUnit =>
      text().named('canvas_height_unit').withDefault(const Constant('mm'))();
  // Grid cell size (value + unit)
  RealColumn get gridCellWidthValue =>
      real().named('grid_cell_width_value').withDefault(const Constant(10.0))();
  TextColumn get gridCellWidthUnit =>
      text().named('grid_cell_width_unit').withDefault(const Constant('mm'))();
  RealColumn get gridCellHeightValue => real()
      .named('grid_cell_height_value')
      .withDefault(const Constant(10.0))();
  TextColumn get gridCellHeightUnit =>
      text().named('grid_cell_height_unit').withDefault(const Constant('mm'))();
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
  int get schemaVersion => 26;

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
        if (from < 19) {
          // Add vendor_category to vendors if missing
          final hasVendorCategory = await m.database
              .customSelect(
                  "SELECT 1 FROM pragma_table_info('vendors') WHERE name = 'vendor_category' LIMIT 1")
              .get();
          if (hasVendorCategory.isEmpty) {
            await m.database.customStatement(
                "ALTER TABLE vendors ADD COLUMN vendor_category TEXT");
          }
          // Add model to projects if missing
          final hasModel = await m.database
              .customSelect(
                  "SELECT 1 FROM pragma_table_info('projects') WHERE name = 'model' LIMIT 1")
              .get();
          if (hasModel.isEmpty) {
            await m.database
                .customStatement("ALTER TABLE projects ADD COLUMN model TEXT");
          }
          // Add vendor_id to projects if missing
          final hasVendorId = await m.database
              .customSelect(
                  "SELECT 1 FROM pragma_table_info('projects') WHERE name = 'vendor_id' LIMIT 1")
              .get();
          if (hasVendorId.isEmpty) {
            await m.database.customStatement(
                "ALTER TABLE projects ADD COLUMN vendor_id INTEGER");
          }
          // Seed Lego vendor and categorize Schmincke/Norma
          await m.database.customStatement(
              "INSERT INTO vendors (vendor_name, vendor_brand, vendor_category) SELECT 'Lego','Lego','bricks' WHERE NOT EXISTS (SELECT 1 FROM vendors WHERE vendor_brand='Lego')");
          await m.database.customStatement(
              "UPDATE vendors SET vendor_category='colors' WHERE vendor_brand='Norma professional' OR vendor_name='Schmincke'");
          // Helpful indexes
          await m.database.customStatement(
              'CREATE INDEX IF NOT EXISTS idx_vendors_vendor_category ON vendors(vendor_category)');
          await m.database.customStatement(
              'CREATE INDEX IF NOT EXISTS idx_projects_model ON projects(model)');
          await m.database.customStatement(
              'CREATE INDEX IF NOT EXISTS idx_projects_vendor_id ON projects(vendor_id)');
        }
        if (from < 20) {
          // Add canvas columns to projects if missing
          final hasCanvasW = await m.database
              .customSelect(
                  "SELECT 1 FROM pragma_table_info('projects') WHERE name = 'canvas_width_px' LIMIT 1")
              .get();
          if (hasCanvasW.isEmpty) {
            await m.database.customStatement(
                "ALTER TABLE projects ADD COLUMN canvas_width_px INTEGER");
          }
          final hasCanvasH = await m.database
              .customSelect(
                  "SELECT 1 FROM pragma_table_info('projects') WHERE name = 'canvas_height_px' LIMIT 1")
              .get();
          if (hasCanvasH.isEmpty) {
            await m.database.customStatement(
                "ALTER TABLE projects ADD COLUMN canvas_height_px INTEGER");
          }
          final hasCanvasDpi = await m.database
              .customSelect(
                  "SELECT 1 FROM pragma_table_info('projects') WHERE name = 'canvas_dpi' LIMIT 1")
              .get();
          if (hasCanvasDpi.isEmpty) {
            await m.database.customStatement(
                "ALTER TABLE projects ADD COLUMN canvas_dpi INTEGER");
          }
        }
        if (from < 21) {
          // Add image layer transform columns to images if missing
          Future<void> addIfMissing(String name, String sql) async {
            final exists = await m.database
                .customSelect(
                    "SELECT 1 FROM pragma_table_info('images') WHERE name = '$name' LIMIT 1")
                .get();
            if (exists.isEmpty) {
              await m.database.customStatement(sql);
            }
          }

          await addIfMissing('layer_offset_x',
              "ALTER TABLE images ADD COLUMN layer_offset_x REAL");
          await addIfMissing('layer_offset_y',
              "ALTER TABLE images ADD COLUMN layer_offset_y REAL");
          await addIfMissing(
              'layer_scale', "ALTER TABLE images ADD COLUMN layer_scale REAL");
          await addIfMissing('layer_rotation_deg',
              "ALTER TABLE images ADD COLUMN layer_rotation_deg REAL");
          await addIfMissing('layer_opacity',
              "ALTER TABLE images ADD COLUMN layer_opacity REAL");
          await addIfMissing('layer_visible',
              "ALTER TABLE images ADD COLUMN layer_visible INTEGER");
        }
        if (from < 22) {
          // Add DPI columns to images if missing
          Future<void> addIfMissingImg(String name, String sql) async {
            final exists = await m.database
                .customSelect(
                    "SELECT 1 FROM pragma_table_info('images') WHERE name = '$name' LIMIT 1")
                .get();
            if (exists.isEmpty) {
              await m.database.customStatement(sql);
            }
          }

          await addIfMissingImg(
              'orig_dpi', "ALTER TABLE images ADD COLUMN orig_dpi INTEGER");
          await addIfMissingImg(
              'dpi', "ALTER TABLE images ADD COLUMN dpi INTEGER");
        }
        if (from < 23) {
          // Remove projects.canvas_dpi by rebuilding the table
          await m.database.customStatement(
              'CREATE TABLE IF NOT EXISTS projects_tmp ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
              'title TEXT NOT NULL, '
              'author TEXT, '
              'status TEXT NOT NULL DEFAULT (\'draft\'), '
              'created_at INTEGER NOT NULL, '
              'updated_at INTEGER NOT NULL, '
              'image_id INTEGER, '
              'model TEXT, '
              'vendor_id INTEGER, '
              'canvas_width_px INTEGER, '
              'canvas_height_px INTEGER, '
              'FOREIGN KEY(image_id) REFERENCES images(id) ON DELETE SET NULL, '
              'FOREIGN KEY(vendor_id) REFERENCES vendors(id) ON DELETE SET NULL)');
          await m.database.customStatement('INSERT INTO projects_tmp '
              '(id, title, author, status, created_at, updated_at, image_id, model, vendor_id, canvas_width_px, canvas_height_px) '
              'SELECT id, title, author, status, created_at, updated_at, image_id, model, vendor_id, canvas_width_px, canvas_height_px '
              'FROM projects');
          await m.database.customStatement('DROP TABLE projects');
          await m.database
              .customStatement('ALTER TABLE projects_tmp RENAME TO projects');
          await m.database.customStatement(
              'CREATE INDEX IF NOT EXISTS idx_projects_updatedAt ON projects(updated_at)');
          await m.database.customStatement(
              'CREATE INDEX IF NOT EXISTS idx_projects_title ON projects(title)');
          await m.database.customStatement(
              'CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status)');
          await m.database.customStatement(
              'CREATE INDEX IF NOT EXISTS idx_projects_model ON projects(model)');
          await m.database.customStatement(
              'CREATE INDEX IF NOT EXISTS idx_projects_vendor_id ON projects(vendor_id)');
        }
        if (from < 24) {
          // Rebuild projects table to enforce NOT NULL + defaults + checks on canvas columns
          await m.database.customStatement(
              'CREATE TABLE IF NOT EXISTS projects_tmp2 ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, '
              'title TEXT NOT NULL, '
              'author TEXT, '
              'status TEXT NOT NULL DEFAULT (\'draft\'), '
              'created_at INTEGER NOT NULL, '
              'updated_at INTEGER NOT NULL, '
              'image_id INTEGER, '
              'model TEXT, '
              'vendor_id INTEGER, '
              'canvas_width_px INTEGER NOT NULL DEFAULT 100 CHECK (canvas_width_px > 0), '
              'canvas_height_px INTEGER NOT NULL DEFAULT 100 CHECK (canvas_height_px > 0), '
              'FOREIGN KEY(image_id) REFERENCES images(id) ON DELETE SET NULL, '
              'FOREIGN KEY(vendor_id) REFERENCES vendors(id) ON DELETE SET NULL)');
          // Copy with backfill (treat 0 or NULL as 100)
          await m.database.customStatement('INSERT INTO projects_tmp2 '
              '(id, title, author, status, created_at, updated_at, image_id, model, vendor_id, canvas_width_px, canvas_height_px) '
              'SELECT id, title, author, status, created_at, updated_at, image_id, model, vendor_id, '
              'COALESCE(NULLIF(canvas_width_px, 0), 100), COALESCE(NULLIF(canvas_height_px, 0), 100) '
              'FROM projects');
          await m.database.customStatement('DROP TABLE projects');
          await m.database
              .customStatement('ALTER TABLE projects_tmp2 RENAME TO projects');
          await m.database.customStatement(
              'CREATE INDEX IF NOT EXISTS idx_projects_updatedAt ON projects(updated_at)');
          await m.database.customStatement(
              'CREATE INDEX IF NOT EXISTS idx_projects_title ON projects(title)');
          await m.database.customStatement(
              'CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status)');
          await m.database.customStatement(
              'CREATE INDEX IF NOT EXISTS idx_projects_model ON projects(model)');
          await m.database.customStatement(
              'CREATE INDEX IF NOT EXISTS idx_projects_vendor_id ON projects(vendor_id)');
        }
        if (from < 25) {
          // Add canvas value+unit columns with defaults; backfill existing rows
          await m.database.customStatement(
              "ALTER TABLE projects ADD COLUMN canvas_width_value REAL DEFAULT 100.0");
          await m.database.customStatement(
              "ALTER TABLE projects ADD COLUMN canvas_width_unit TEXT DEFAULT 'mm'");
          await m.database.customStatement(
              "ALTER TABLE projects ADD COLUMN canvas_height_value REAL DEFAULT 100.0");
          await m.database.customStatement(
              "ALTER TABLE projects ADD COLUMN canvas_height_unit TEXT DEFAULT 'mm'");
          // Backfill: set defaults where NULL
          await m.database.customStatement(
              "UPDATE projects SET canvas_width_value = COALESCE(canvas_width_value, 100.0)");
          await m.database.customStatement(
              "UPDATE projects SET canvas_width_unit = COALESCE(canvas_width_unit, 'mm')");
          await m.database.customStatement(
              "UPDATE projects SET canvas_height_value = COALESCE(canvas_height_value, 100.0)");
          await m.database.customStatement(
              "UPDATE projects SET canvas_height_unit = COALESCE(canvas_height_unit, 'mm')");
        }
        if (from < 26) {
          // Add grid cell size columns with defaults and backfill
          await m.database.customStatement(
              "ALTER TABLE projects ADD COLUMN grid_cell_width_value REAL DEFAULT 10.0");
          await m.database.customStatement(
              "ALTER TABLE projects ADD COLUMN grid_cell_width_unit TEXT DEFAULT 'mm'");
          await m.database.customStatement(
              "ALTER TABLE projects ADD COLUMN grid_cell_height_value REAL DEFAULT 10.0");
          await m.database.customStatement(
              "ALTER TABLE projects ADD COLUMN grid_cell_height_unit TEXT DEFAULT 'mm'");
          await m.database.customStatement(
              "UPDATE projects SET grid_cell_width_value = COALESCE(grid_cell_width_value, 10.0)");
          await m.database.customStatement(
              "UPDATE projects SET grid_cell_width_unit = COALESCE(grid_cell_width_unit, 'mm')");
          await m.database.customStatement(
              "UPDATE projects SET grid_cell_height_value = COALESCE(grid_cell_height_value, 10.0)");
          await m.database.customStatement(
              "UPDATE projects SET grid_cell_height_unit = COALESCE(grid_cell_height_unit, 'mm')");
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
  VendorColorWithVariants({
    required this.color,
    required this.variants,
  });
  final VendorColor color;
  final List<VendorColorVariant> variants;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db_grufio.sqlite'));
    return NativeDatabase(file);
  });
}
