import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';

// Keys for settings
const String _apiKeyKey = 'gemini_api_key';
const String _apiEnabledKey = 'is_gemini_api_enabled';
const String _maxObjectColorsKey = 'maxObjectColors';
const String _objectOutputSizeKey = 'objectOutputSize';
const String _outputFontSizeKey = 'outputFontSize';
const String _customPageWidthKey = 'customPageWidth';
const String _customPageHeightKey = 'customPageHeight';
const String _outputBordersKey = 'outputBorders';
const String _printBackgroundKey = 'printBackground';
const String _pageFormatKey = 'pageFormat';
const String _centerImageKey = 'centerImage';
const String _isLandscapeKey = 'isLandscape';
const String _colorSeparationKey = 'colorSeparation';
const String _klKey = 'kl';
const String _kcKey = 'kc';
const String _khKey = 'kh';
const String _printBordersKey = 'printBorders';
const String _printNumbersKey = 'printNumbers';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  // This provider is overridden in main.dart after the service is initialized.
  throw UnimplementedError('SettingsService must be initialized and provided');
});

class SettingsService extends ChangeNotifier {
  final AppDatabase _db;
  final Map<String, String> _cache = {};

  SettingsService(this._db);

  /// Must be called once at startup.
  /// Loads all settings from the database into a memory cache.
  Future<void> init() async {
    final allSettings = await _db.select(_db.settings).get();
    _cache.clear();
    for (final setting in allSettings) {
      _cache[setting.key] = setting.value;
    }
    // No need to notify listeners here, as this is called before the UI is built.
  }

  Future<void> _setSetting(String key, dynamic value) async {
    final stringValue = value.toString();
    await (_db.into(_db.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, value: stringValue),
        ));
    _cache[key] = stringValue;
    notifyListeners();
  }

  T _getParsedValue<T>(String key, T defaultValue) {
    final value = _cache[key];
    if (value == null) return defaultValue;

    if (T == int) {
      return int.tryParse(value) as T? ?? defaultValue;
    }
    if (T == double) {
      return double.tryParse(value) as T? ?? defaultValue;
    }
    if (T == bool) {
      return (value.toLowerCase() == 'true') as T;
    }
    if (T == String) {
      return value as T;
    }
    return defaultValue;
  }

  // Gemini API Settings
  String? get geminiApiKey => _cache[_apiKeyKey];
  Future<void> setGeminiApiKey(String key) => _setSetting(_apiKeyKey, key);

  bool get isGeminiApiEnabled => _getParsedValue(_apiEnabledKey, false);
  Future<void> setGeminiApiEnabled(bool isEnabled) =>
      _setSetting(_apiEnabledKey, isEnabled);

  // Conversion Settings
  int get maxObjectColors => _getParsedValue(_maxObjectColorsKey, 40);
  Future<void> setMaxObjectColors(int value) =>
      _setSetting(_maxObjectColorsKey, value);

  // PDF Output Settings
  double get objectOutputSize => _getParsedValue(_objectOutputSizeKey, 10.0);
  Future<void> setObjectOutputSize(double value) =>
      _setSetting(_objectOutputSizeKey, value);

  double get colorSeparation => _getParsedValue(_colorSeparationKey, 5.0);
  Future<void> setColorSeparation(double value) =>
      _setSetting(_colorSeparationKey, value);

  double get kl => _getParsedValue(_klKey, 1.0);
  Future<void> setKl(double value) => _setSetting(_klKey, value);

  double get kc => _getParsedValue(_kcKey, 1.0);
  Future<void> setKc(double value) => _setSetting(_kcKey, value);

  double get kh => _getParsedValue(_khKey, 1.0);
  Future<void> setKh(double value) => _setSetting(_khKey, value);

  int get outputFontSize => _getParsedValue(_outputFontSizeKey, 10);
  Future<void> setOutputFontSize(int value) =>
      _setSetting(_outputFontSizeKey, value);

  double get outputBorders => _getParsedValue(_outputBordersKey, 10.0);
  Future<void> setOutputBorders(double value) =>
      _setSetting(_outputBordersKey, value);

  // Page Format Settings
  String get pageFormat => _getParsedValue(_pageFormatKey, 'A4');
  Future<void> setPageFormat(String value) =>
      _setSetting(_pageFormatKey, value);

  double get customPageWidth => _getParsedValue(_customPageWidthKey, 210.0);
  Future<void> setCustomPageWidth(double value) =>
      _setSetting(_customPageWidthKey, value);

  double get customPageHeight => _getParsedValue(_customPageHeightKey, 297.0);
  Future<void> setCustomPageHeight(double value) =>
      _setSetting(_customPageHeightKey, value);

  bool get isLandscape => _getParsedValue(_isLandscapeKey, false);
  Future<void> setIsLandscape(bool value) =>
      _setSetting(_isLandscapeKey, value);

  bool get centerImage => _getParsedValue(_centerImageKey, true);
  Future<void> setCenterImage(bool value) =>
      _setSetting(_centerImageKey, value);

  bool get printBackground => _getParsedValue(_printBackgroundKey, false);
  Future<void> setPrintBackground(bool value) =>
      _setSetting(_printBackgroundKey, value);

  bool get printBorders => _getParsedValue(_printBordersKey, true);
  Future<void> setPrintBorders(bool value) =>
      _setSetting(_printBordersKey, value);

  bool get printNumbers => _getParsedValue(_printNumbersKey, true);
  Future<void> setPrintNumbers(bool value) =>
      _setSetting(_printNumbersKey, value);
}
