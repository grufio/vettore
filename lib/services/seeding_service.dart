import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:vettore/data/database.dart';
import 'package:drift/drift.dart';

class SeedingService {
  final AppDatabase _db;

  SeedingService(this._db);

  Future<void> seedVendorColors() async {
    // This is a safe way to count rows without mapping them.
    final countExp = _db.vendorColors.id.count();
    final query = _db.selectOnly(_db.vendorColors)..addColumns([countExp]);
    final count =
        await query.map((row) => row.read(countExp)).getSingleOrNull() ?? 0;

    if (count == 0) {
      print('Seeding vendor colors...');
      final rawCsv =
          await rootBundle.loadString('lib/input/norma_pro_color_codes.csv');
      final List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(rawCsv);

      for (var i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        final code = row[0].toString().trim();
        final name = row[1].toString().trim();
        final sizesRaw = row.length > 2 ? row[2].toString().trim() : '';
        final imageUrl = 'assets/images/libraries/schmincke/norma/$code.jpg';

        if (code.isNotEmpty && name.isNotEmpty) {
          final colorId = await _db.into(_db.vendorColors).insert(
                VendorColorsCompanion(
                  name: Value(name),
                  code: Value(code),
                  imageUrl: Value(imageUrl),
                ),
              );

          if (sizesRaw.isNotEmpty) {
            final sizes = sizesRaw
                .split(',')
                .map((e) => int.tryParse(e.trim()))
                .whereType<int>()
                .toList();

            final variantsToInsert = sizes
                .map((size) => VendorColorVariantsCompanion(
                      vendorColorId: Value(colorId),
                      size: Value(size),
                    ))
                .toList();

            await _db.batch((batch) {
              batch.insertAll(_db.vendorColorVariants, variantsToInsert);
            });
          }
        }
      }

      print('Seeding complete.');
    } else {
      print('Vendor colors already seeded.');
    }
  }
}
