import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive/hive.dart';
import 'package:vettore/vendor_color_model.dart';

class ColorSeeder {
  static const String _vendorColorBoxName = 'vendor_colors';
  static const String _seedCompleteKey = 'vendor_colors_seed_complete';

  static Future<void> seedColors() async {
    final settingsBox = Hive.box('settings');
    // Ensure the box is open before using it.
    final vendorColorBox = await Hive.openBox<VendorColor>(_vendorColorBoxName);
    final isSeeded = settingsBox.get(_seedCompleteKey, defaultValue: false);

    if (isSeeded && vendorColorBox.isNotEmpty) {
      debugPrint('Vendor colors already seeded. Skipping.');
      return;
    }

    debugPrint('Seeding vendor colors...');
    await vendorColorBox.clear(); // Clear any partial data from failed attempts

    await _seedFromFile(vendorColorBox, '35ml');
    await _seedFromFile(vendorColorBox, '120ml');
    await _seedFromFile(vendorColorBox, '200ml');

    debugPrint('Seeding complete. ${vendorColorBox.length} colors loaded.');
    await settingsBox.put(_seedCompleteKey, true);
  }

  static Future<void> _seedFromFile(
    Box<VendorColor> box,
    String sizeString,
  ) async {
    final path = 'lib/input/farben_${sizeString}.csv';
    debugPrint('--> Seeding from $path');
    final rawCsv = await rootBundle.loadString(path);

    debugPrint('--> RAW CSV CONTENT for $path:');
    debugPrint('------------------------------------');
    debugPrint(
      rawCsv.substring(0, (rawCsv.length > 500) ? 500 : rawCsv.length),
    );
    debugPrint('------------------------------------');

    final List<List<dynamic>> csvTable = const CsvToListConverter(
      fieldDelimiter: ',',
      eol: '\n', // Explicitly set the end-of-line character
      shouldParseNumbers: false, // Treat all columns as text initially
    ).convert(rawCsv);

    debugPrint('--> Found ${csvTable.length - 1} data rows in $path');

    // Skip header row
    for (var i = 1; i < csvTable.length; i++) {
      final row = csvTable[i];
      if (row.length >= 2) {
        final vendorColor = VendorColor()
          ..articleNumber = row[0].toString()
          ..name = row[1].toString()
          ..size = int.tryParse(sizeString.replaceAll('ml', '')) ?? 0;
        await box.add(vendorColor);
      } else {
        debugPrint('--> SKIPPING invalid row in $path: $row');
      }
    }
    debugPrint('--> Successfully added ${box.length} colors from this file.');
  }
}
