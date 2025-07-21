import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String _settingsBoxName = 'settings';

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

final settingsServiceProvider = Provider<SettingsService>((ref) {
  final box = Hive.box(_settingsBoxName);
  return SettingsService(box);
});

class SettingsService extends ChangeNotifier {
  final Box _box;

  SettingsService(this._box) {
    _box.listenable().addListener(() {
      notifyListeners();
    });
  }

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_settingsBoxName);
  }

  // Gemini API Settings
  String? get geminiApiKey => _box.get(_apiKeyKey);
  Future<void> setGeminiApiKey(String key) => _box.put(_apiKeyKey, key);

  bool get isGeminiApiEnabled => _box.get(_apiEnabledKey, defaultValue: false);
  Future<void> setGeminiApiEnabled(bool isEnabled) =>
      _box.put(_apiEnabledKey, isEnabled);

  // Helper to safely parse values that might have been stored as strings
  T _getNumericValue<T>(String key, T defaultValue) {
    final value = _box.get(key);
    if (value is T) {
      return value;
    }
    if (value is String) {
      if (T == int) {
        return int.tryParse(value) as T? ?? defaultValue;
      }
      if (T == double) {
        return double.tryParse(value) as T? ?? defaultValue;
      }
    }
    return defaultValue;
  }

  // Conversion Settings
  int get maxObjectColors => _getNumericValue(_maxObjectColorsKey, 40);
  Future<void> setMaxObjectColors(int value) =>
      _box.put(_maxObjectColorsKey, value);

  // PDF Output Settings
  double get objectOutputSize => _getNumericValue(_objectOutputSizeKey, 10.0);
  Future<void> setObjectOutputSize(double value) =>
      _box.put(_objectOutputSizeKey, value);

  int get outputFontSize => _getNumericValue(_outputFontSizeKey, 10);
  Future<void> setOutputFontSize(int value) =>
      _box.put(_outputFontSizeKey, value);

  double get outputBorders => _getNumericValue(_outputBordersKey, 10.0);
  Future<void> setOutputBorders(double value) =>
      _box.put(_outputBordersKey, value);

  // Page Format Settings
  String get pageFormat => _box.get(_pageFormatKey, defaultValue: 'A4');
  Future<void> setPageFormat(String value) => _box.put(_pageFormatKey, value);

  double get customPageWidth => _getNumericValue(_customPageWidthKey, 210.0);
  Future<void> setCustomPageWidth(double value) =>
      _box.put(_customPageWidthKey, value);

  double get customPageHeight => _getNumericValue(_customPageHeightKey, 297.0);
  Future<void> setCustomPageHeight(double value) =>
      _box.put(_customPageHeightKey, value);

  bool get isLandscape => _box.get(_isLandscapeKey, defaultValue: false);
  Future<void> setIsLandscape(bool value) => _box.put(_isLandscapeKey, value);

  bool get centerImage => _box.get(_centerImageKey, defaultValue: true);
  Future<void> setCenterImage(bool value) => _box.put(_centerImageKey, value);

  bool get printBackground =>
      _box.get(_printBackgroundKey, defaultValue: false);
  Future<void> setPrintBackground(bool value) =>
      _box.put(_printBackgroundKey, value);
}
