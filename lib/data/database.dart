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
  RealColumn get sizeInMl => real().withDefault(const Constant(60.0))();
  RealColumn get factor => real().withDefault(const Constant(1.5))();
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
  TextColumn get articleNumber => text()();
  TextColumn get name => text()();
  IntColumn get size => integer()();
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
  ColorComponents,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
