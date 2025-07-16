import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';
import 'package:vettore/models/vendor_color_model.dart';

class ColorSeeder {
  static const String _vendorColorBoxName = 'vendor_colors';
  static const String _seedCompleteKey = 'seed_norma_pro';

  static Future<void> seedColors() async {
    final settingsBox = Hive.box('settings');
    final vendorColorBox = await Hive.openBox<VendorColor>(_vendorColorBoxName);

    debugPrint('[ColorSeeder] Checking if seeding is required...');
    debugPrint('[ColorSeeder] Using seed key: $_seedCompleteKey');
    final isSeeded = settingsBox.get(_seedCompleteKey, defaultValue: false);
    debugPrint('[ColorSeeder] Is seeded flag: $isSeeded');
    debugPrint(
      '[ColorSeeder] Colors in box before check: ${vendorColorBox.length}',
    );

    if (isSeeded) {
      debugPrint('[ColorSeeder] Seeding not required. Skipping.');
      return;
    }

    debugPrint('[ColorSeeder] Seeding required. Starting process...');
    debugPrint('[ColorSeeder] Clearing vendor color box...');
    await vendorColorBox.clear();
    debugPrint(
      '[ColorSeeder] Vendor color box cleared. Items: ${vendorColorBox.length}',
    );

    await _seedFromFile(vendorColorBox);

    debugPrint(
      '[ColorSeeder] Seeding complete. ${vendorColorBox.length} colors loaded.',
    );
    await settingsBox.put(_seedCompleteKey, true);
    debugPrint('[ColorSeeder] Seeded flag set to true.');
  }

  static Future<void> _seedFromFile(Box<VendorColor> box) async {
    const path = 'lib/input/norma_pro_color_codes.csv';
    debugPrint('--> Seeding from $path');
    final rawCsv = await rootBundle.loadString(path);
    final List<List<dynamic>> csvTable = const CsvToListConverter(
      fieldDelimiter: ',',
      // Let the converter auto-detect EOL
      shouldParseNumbers: false,
    ).convert(rawCsv);

    debugPrint('--> Found ${csvTable.length - 1} data rows in $path');

    for (var i = 1; i < csvTable.length; i++) {
      final row = csvTable[i];
      try {
        if (row.length >= 3) {
          final articleNumber = row[0].toString();
          final name = row[1].toString();
          final sizesRaw = row[2].toString();
          final sizes = sizesRaw
              .split(',')
              .map((s) => int.tryParse(s.trim()))
              .where((s) => s != null)
              .cast<int>()
              .toList();

          if (sizes.isEmpty && sizesRaw.trim().isNotEmpty) {
            debugPrint(
              '--> [WARNING] Could not parse int from size string "$sizesRaw" for color "$name"',
            );
          }

          for (final size in sizes) {
            final vendorColor = VendorColor()
              ..articleNumber = articleNumber
              ..name = name
              ..size = size;
            await box.add(vendorColor);
          }
        } else {
          debugPrint(
            '--> [SKIPPING] Invalid row in $path: $row (column count is ${row.length})',
          );
        }
      } catch (e, s) {
        debugPrint('--> [ERROR] Failed to process row $i: $row');
        debugPrint('--> Exception: $e');
        debugPrint('--> Stack Trace: $s');
      }
    }
    debugPrint(
      '--> Successfully added ${box.values.length} colors from this file.',
    );
  }
}
