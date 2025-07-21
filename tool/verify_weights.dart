import 'package:flutter/widgets.dart';
import 'package:vettore/data/database.dart';

// A simple script to verify the color weights in the database.
//
// To run this script, use the following command from the root of the project:
// flutter run -t tool/verify_weights.dart

Future<void> main() async {
  // We need to initialize the Flutter binding to use the database.
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();

  try {
    print('Reading vendor colors from the database...\n');
    final allColors = await db.select(db.vendorColors).get();

    if (allColors.isEmpty) {
      print('No vendor colors found in the database.');
      return;
    }

    // Determine the longest name for formatting
    final longestName = allColors.fold<int>(
        0, (max, c) => c.name.length > max ? c.name.length : max);

    for (final color in allColors) {
      final name = color.name.padRight(longestName);
      final weight = color.weightInGrams?.toStringAsFixed(2) ?? 'N/A';
      print('  ${name}  |  Weight: ${weight}g');
    }

    print('\nVerification complete.');
  } finally {
    await db.close();
  }
}
