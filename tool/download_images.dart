import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:csv/csv.dart';

// A simple script to download Schmincke Norma color swatch images.
//
// It reads the color codes from the provided CSV file, constructs the
// download URL for each color, and saves the image to the assets directory.
//
// To run this script, execute the following command from the project root:
// dart run tool/download_images.dart

void main() async {
  final csvPath = p.join('lib', 'input', 'norma_pro_color_codes.csv');
  final outputDir =
      p.join('assets', 'images', 'libraries', 'schmincke', 'norma');

  final csvFile = File(csvPath);
  if (!await csvFile.exists()) {
    print('Error: CSV file not found at $csvPath');
    return;
  }

  // Ensure the output directory exists
  await Directory(outputDir).create(recursive: true);

  print('Reading CSV file from: $csvPath');
  final input = await csvFile.openRead();
  final fields = await input
      .transform(utf8.decoder)
      .transform(const CsvToListConverter())
      .toList();

  print('Found ${fields.length - 1} colors to download.');

  // Skip the header line
  for (var i = 1; i < fields.length; i++) {
    final row = fields[i];

    if (row.length < 2) {
      print('Warning: Skipping malformed row: $row');
      continue;
    }

    final code = row[0].toString().trim();
    final name = row[1].toString().trim();

    if (code.isEmpty || name.isEmpty) {
      print('Warning: Skipping row with empty code or name: $row');
      continue;
    }

    final imageUrl =
        'https://www.schmincke.de/fileadmin/schmincke_products/farbwischer/$code.jpg';

    // Use the color code for the filename.
    final filename = '$code.jpg';
    final outputPath = p.join(outputDir, filename);

    final outputFile = File(outputPath);
    if (await outputFile.exists()) {
      print('Skipping $name, image already exists: $filename');
      continue;
    }

    try {
      print('Downloading $name ($code) from $imageUrl...');
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        await outputFile.writeAsBytes(response.bodyBytes);
        print(' -> Saved to $outputPath');
      } else {
        print(
            ' !! Failed to download $name. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print(' !! Error downloading $name: $e');
    }
  }

  print('\nImage download process complete.');
}
