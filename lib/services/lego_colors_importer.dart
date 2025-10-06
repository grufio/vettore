import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:vettore/data/database.dart';

class LegoColorsImporter {
  final AppDatabase db;
  LegoColorsImporter(this.db);

  Future<int> importFromAssetsCsv(String assetPath) async {
    final csvString = await rootBundle.loadString(assetPath);
    final List<List<dynamic>> rows = const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(csvString);
    if (rows.isEmpty) return 0;

    // Expect header: legoID,legoName,material,mecabricksRGB,timeline
    final header = rows.first.map((e) => e.toString()).toList();
    final int idxId = header.indexOf('legoID');
    final int idxName = header.indexOf('legoName');
    final int idxMaterial = header.indexOf('material');
    final int idxRgb = header.indexOf('mecabricksRGB');
    final int idxTimeline = header.indexOf('timeline');

    int inserted = 0;
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;
      final String idStr = row[idxId].toString().trim();
      final int? legoId = int.tryParse(idStr);
      if (legoId == null) continue;
      final String name = row[idxName].toString().trim();
      final String material = row[idxMaterial].toString().trim();
      final String rgb = row[idxRgb].toString().trim();
      final String timeline = row[idxTimeline].toString().trim();

      int? startYear;
      int? endYear;
      // timeline like "1950 - 2024" or "2024"
      if (timeline.isNotEmpty) {
        final parts = timeline.split('-').map((s) => s.trim()).toList();
        if (parts.length == 2) {
          startYear = int.tryParse(parts[0]);
          endYear = int.tryParse(parts[1]);
        } else if (parts.length == 1) {
          startYear = int.tryParse(parts[0]);
          endYear = startYear;
        }
      }

      // Upsert with raw SQL to avoid depending on generated companions
      await db.customStatement(
        'INSERT OR REPLACE INTO lego_colors '
        '(lego_id, lego_name, material, mecabricks_rgb, start_year, end_year) '
        'VALUES (?, ?, ?, ?, ?, ?)',
        [legoId, name, material, rgb.isEmpty ? null : rgb, startYear, endYear],
      );
      inserted++;
    }
    return inserted;
  }
}
