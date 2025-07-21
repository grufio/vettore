import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;
import 'package:vettore/data/database.dart';
import 'package:drift/drift.dart';

// A simple script to fetch color weights from an external website
// and update the local database.
//
// To run this script, use the following command from the root of the project:
// flutter run -t tool/fetch_color_weights.dart

Future<void> main() async {
  // We need to initialize the Flutter binding to use the database.
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();

  try {
    print('Fetching all vendor colors from the database...');
    final allColors = await db.select(db.vendorColors).get();

    if (allColors.isEmpty) {
      print(
          'No vendor colors found in the database. Please run the main app once to seed the data.');
      return;
    }

    print('Found ${allColors.length} colors to process.');

    for (final color in allColors) {
      final colorNameForUrl = color.name.replaceAll(' ', '-').toLowerCase();
      final url =
          'https://www.jacksonsart.com/en-us/schmincke-norma-professional-artists-oil-35ml-$colorNameForUrl';

      print('Processing ${color.name} from $url');

      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final document = html.parse(response.body);
          // The :contains selector is not supported. We find the element manually.
          final allThs = document.querySelectorAll('th');
          dom.Element? weightElement;
          for (final th in allThs) {
            final thText = th.text.trim();
            if (thText == 'Weight (kg)' || thText == 'Weight (Kg)') {
              weightElement = th.nextElementSibling;
              break;
            }
          }

          if (weightElement != null) {
            final weightInKg = double.tryParse(weightElement.text.trim());
            if (weightInKg != null) {
              final weightInGrams = weightInKg * 1000;
              print(
                  '  Found weight: ${weightInKg}kg -> ${weightInGrams.toStringAsFixed(2)}g');

              await (db.update(db.vendorColors)
                    ..where((c) => c.id.equals(color.id)))
                  .write(
                VendorColorsCompanion(
                  weightInGrams: Value(weightInGrams),
                ),
              );
              print('  Updated database for ${color.name}.');
            } else {
              print('  Could not parse weight from: ${weightElement.text}');
            }
          } else {
            print('  Weight information not found on page.');
          }
        } else {
          print('  Failed to fetch page, status code: ${response.statusCode}');
        }
      } catch (e) {
        print('  An error occurred while processing ${color.name}: $e');
      }
      // Add a small delay to avoid overwhelming the server
      await Future.delayed(const Duration(milliseconds: 500));
    }

    print('\nScript finished.');
  } finally {
    await db.close();
  }
}
