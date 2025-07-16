import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String _settingsBoxName = 'settings';
const String _apiKeyKey = 'gemini_api_key';
const String _apiEnabledKey = 'is_gemini_api_enabled';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  final box = Hive.box(_settingsBoxName);
  return SettingsService(box);
});

class SettingsService {
  final Box _box;

  SettingsService(this._box);

  String? get geminiApiKey {
    return _box.get(_apiKeyKey);
  }

  Future<void> setGeminiApiKey(String key) {
    return _box.put(_apiKeyKey, key);
  }

  bool get isGeminiApiEnabled {
    return _box.get(_apiEnabledKey, defaultValue: false);
  }

  Future<void> setGeminiApiEnabled(bool isEnabled) {
    return _box.put(_apiEnabledKey, isEnabled);
  }
}
