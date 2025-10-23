import 'package:flutter/foundation.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/services/lego_colors_importer.dart';
import 'package:vettore/services/settings_service.dart';

/// Runs one-time background initialization tasks on app startup.
///
/// Tasks are guarded by flags persisted in [SettingsService] so they execute
/// at most once across sessions.
class InitService {
  InitService({required AppDatabase db, required SettingsService settings})
      : _db = db,
        _settings = settings;

  final AppDatabase _db;
  final SettingsService _settings;

  // Settings keys
  static const String _kLegoImportDoneKey = 'init.lego_import_done';
  static const String _kVendorCleanupDoneKey = 'init.vendor_cleanup_done';

  /// Execute all guarded startup tasks.
  Future<void> run() async {
    await _importLegoColorsOnce();
    await _cleanupVendorsOnce();
  }

  Future<void> _importLegoColorsOnce() async {
    final int already = _settings.getInt(_kLegoImportDoneKey, 0);
    if (already == 1) return;
    try {
      await LegoColorsImporter(_db)
          .importFromAssetsCsv('assets/csv/lego_colors.csv');
      await _settings.setInt(_kLegoImportDoneKey, 1);
    } catch (e, st) {
      debugPrint('[InitService] LEGO import failed: $e\n$st');
      // Do not set the done flag on failure; allow retry next launch.
    }
  }

  Future<void> _cleanupVendorsOnce() async {
    final int already = _settings.getInt(_kVendorCleanupDoneKey, 0);
    if (already == 1) return;
    try {
      await _db.customStatement(
        "DELETE FROM vendors WHERE vendor_category='bricks' AND (vendor_brand LIKE 'Lego%' OR vendor_name LIKE 'Lego%') AND id NOT IN (SELECT DISTINCT vendor_id FROM vendor_colors WHERE vendor_id IS NOT NULL)",
      );
      await _settings.setInt(_kVendorCleanupDoneKey, 1);
    } catch (e, st) {
      debugPrint('[InitService] vendor cleanup failed: $e\n$st');
      // Do not set the done flag on failure; allow retry next launch.
    }
  }
}
