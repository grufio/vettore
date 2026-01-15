import 'package:flutter_riverpod/flutter_riverpod.dart';

class RuntimeSettings {
  const RuntimeSettings({
    this.maxObjectColors = 32,
    this.colorSeparation = 8,
    this.kl = 1,
    this.kc = 1,
    this.kh = 1,
  });
  final int maxObjectColors;
  final int colorSeparation;
  final int kl;
  final int kc;
  final int kh;
}

/// In-memory processing settings (no persistence, no UI wiring).
final runtimeSettingsProvider = Provider<RuntimeSettings>((ref) {
  return const RuntimeSettings();
});


