import 'package:flutter/widgets.dart';
import 'package:vettore/data/database.dart';
import 'package:drift/drift.dart';

// A script to calculate the color density based on the weight and save it.
//
// Formula: (weightInGrams - 4) / 35 = density in g/ml
//
// To run this script, use the following command from the root of the project:
// flutter run -t tool/calculate_density.dart

Future<void> main() async {
  // We need to initialize the Flutter binding to use the database.
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();

  try {
    print('Reading vendor colors from the database...');
    final allColors = await db.select(db.vendorColors).get();

    if (allColors.isEmpty) {
      print('No vendor colors found in the database.');
      return;
    }

    print('Calculating and updating density for ${allColors.length} colors...');

    for (final color in allColors) {
      if (color.weightInGrams != null) {
        final rawWeight = color.weightInGrams! - 4.0;
        final density = rawWeight / 35.0;

        print(
            '  ${color.name}: ${density.toStringAsFixed(4)} g/ml (from ${color.weightInGrams}g)');

        await (db.update(db.vendorColors)..where((c) => c.id.equals(color.id)))
            .write(
          VendorColorsCompanion(
            colorDensity: Value(density),
          ),
        );
      } else {
        print('  Skipping ${color.name} (no weight data).');
      }
    }

    print('\nCalculation complete.');
  } finally {
    await db.close();
  }
}
