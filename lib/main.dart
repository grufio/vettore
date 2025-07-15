import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:vettore/color_settings.dart';
import 'package:vettore/palette_model.dart';
import 'package:vettore/palettes_overview.dart';
import 'package:vettore/settings_image.dart';
import 'package:vettore/palette_color.dart';
import 'package:vettore/project_model.dart';
import 'package:vettore/vector_object_model.dart';
import 'package:vettore/project_editor_page.dart';
import 'package:vettore/project_overview_page.dart';
import 'package:vettore/data/color_seeder.dart';
import 'package:vettore/vendor_color_model.dart';
import 'package:vettore/color_component_model.dart';
import 'package:vettore/loading_page.dart';

Future<void> _openBoxSafely<T>(String name) async {
  try {
    await Hive.openBox<T>(name);
  } on HiveError catch (e) {
    debugPrint('Error opening box $name: $e. Deleting and recreating.');
    await Hive.deleteBoxFromDisk(name);
    await Hive.openBox<T>(name);
  }
}

Future<void> main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(PaletteAdapter());
  Hive.registerAdapter(PaletteColorAdapter());
  Hive.registerAdapter(VectorObjectAdapter());
  Hive.registerAdapter(ProjectAdapter());
  Hive.registerAdapter(VendorColorAdapter());
  Hive.registerAdapter(ColorComponentAdapter());

  await _openBoxSafely('settings');
  await _openBoxSafely<Palette>('palettes');
  await _openBoxSafely<Project>('projects');
  await _openBoxSafely<VendorColor>('vendor_colors');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vettore',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoadingPage(),
    );
  }
}
