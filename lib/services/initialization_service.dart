import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vettore/models/palette_color.dart';
import 'package:vettore/models/palette_model.dart';
import 'package:vettore/models/project_model.dart';
import 'package:vettore/models/vector_object_model.dart';
import 'package:vettore/models/vendor_color_model.dart';
import 'package:vettore/models/color_component_model.dart';

class InitializationService {
  Future<void> initialize() async {
    debugPrint('Initializing application...');

    // 1. Initialize Hive
    await Hive.initFlutter();
    debugPrint('Hive initialized.');

    // 2. Register all adapters
    _registerAdapters();
    debugPrint('All Hive adapters registered.');

    // 3. Open all boxes safely
    await _openBoxes();
    debugPrint('All Hive boxes opened.');

    debugPrint('Application initialization complete.');
  }

  void _registerAdapters() {
    Hive.registerAdapter(PaletteAdapter());
    Hive.registerAdapter(PaletteColorAdapter());
    Hive.registerAdapter(VectorObjectAdapter());
    Hive.registerAdapter(ProjectAdapter());
    Hive.registerAdapter(VendorColorAdapter());
    Hive.registerAdapter(ColorComponentAdapter());
  }

  Future<void> _openBoxes() async {
    await _openBoxSafely('settings');
    await _openBoxSafely<Palette>('palettes');
    await _openBoxSafely<Project>('projects');
    await _openBoxSafely<VendorColor>('vendor_colors');
    await _openBoxSafely<ColorComponent>('color_components');
  }

  Future<void> _openBoxSafely<T>(String name) async {
    try {
      await Hive.openBox<T>(name);
    } catch (e) {
      debugPrint('Error opening box $name: $e. Deleting and recreating.');
      await Hive.deleteBoxFromDisk(name);
      await Hive.openBox<T>(name);
    }
  }
}
