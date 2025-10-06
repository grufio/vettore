import 'package:flutter/widgets.dart';
import 'package:vettore/data/database.dart';
import 'package:drift/drift.dart';

// A one-time script to manually patch the weights for a few specific colors.
//
// To run this script, use the following command from the root of the project:
// flutter run -t tool/patch_missing_weights.dart

Future<void> main() async {
  // We need to initialize the Flutter binding to use the database.
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();

  // The map of colors to update, with their correct weights in grams.
  final colorsToUpdate = {
    'Cadmium Yellow Mix': 77.0,
    'Cadmium Red Mix': 73.0,
    'Payne\'s Grey': 56.0,
    'Chromium Oxide Green Brill.': 53.0,
  };

  try {
    print('Starting to patch ${colorsToUpdate.length} missing weights...');

    for (final entry in colorsToUpdate.entries) {
      final colorName = entry.key;
      final weightInGrams = entry.value;

      print('  Updating "$colorName"...');

      final updatedRows = await (db.update(db.vendorColors)
            ..where((c) => c.name.equals(colorName)))
          .write(
        VendorColorsCompanion(
          weightInGrams: Value(weightInGrams),
        ),
      );

      if (updatedRows > 0) {
        print('    Success! Set weight to ${weightInGrams}g.');
      } else {
        print('    Warning: Could not find a color named "$colorName".');
      }
    }

    print('\nPatching complete.');
  } finally {
    await db.close();
  }
}
