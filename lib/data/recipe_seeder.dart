import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:vettore/models/color_component_model.dart';
import 'package:vettore/models/palette_color.dart';
import 'package:vettore/models/palette_model.dart';

class RecipeSeeder {
  static const String _recipeSeedCompleteKey = 'recipe_seed_v1_complete';

  static Future<void> seedRecipes() async {
    final settingsBox = Hive.box('settings');
    final isSeeded = settingsBox.get(
      _recipeSeedCompleteKey,
      defaultValue: false,
    );

    if (isSeeded) {
      return;
    }

    final palettesBox = Hive.box<Palette>('palettes');

    // Check if the master palette already exists to avoid duplicates on re-runs
    final masterPaletteExists = palettesBox.values.any(
      (p) => p.name == 'Master Recipes',
    );
    if (masterPaletteExists) {
      return;
    }

    final masterPalette = Palette()..name = 'Master Recipes';

    masterPalette.colors.addAll([
      _buildRecipe1(),
      _buildRecipe2(),
      _buildRecipe3(),
      _buildRecipe4(),
      _buildRecipe5(),
      _buildRecipe6(),
      _buildRecipe7(),
      _buildRecipe8(),
      _buildRecipe9(),
      _buildRecipe10(),
    ]);

    await palettesBox.add(masterPalette);
    await settingsBox.put(_recipeSeedCompleteKey, true);
  }

  static PaletteColor _buildRecipe1() {
    return PaletteColor(
        title: 'Warm Grey',
        color: const Color(0xFFa1a19b).toARGB32(),
        status: 'verified',
      )
      ..getComponents().addAll([
        ColorComponent(name: 'Titanium White', percentage: 97.72),
        ColorComponent(name: 'Burnt Sienna', percentage: 1.63),
        ColorComponent(name: 'Ultramarine Blue', percentage: 0.65),
      ]);
  }

  static PaletteColor _buildRecipe2() {
    return PaletteColor(
        title: 'Green Grey',
        color: const Color(0xFFa2a29c).toARGB32(),
        status: 'verified',
      )
      ..getComponents().addAll([
        ColorComponent(name: 'Titanium White', percentage: 97.23),
        ColorComponent(name: 'Ivory Black', percentage: 2.12),
        ColorComponent(name: 'Permanent Yellow', percentage: 0.65),
      ]);
  }

  static PaletteColor _buildRecipe3() {
    return PaletteColor(
        title: 'Turquoise Grey',
        color: const Color(0xFFa5a9a8).toARGB32(),
        status: 'verified',
      )
      ..getComponents().addAll([
        ColorComponent(name: 'Titanium White', percentage: 96.65),
        ColorComponent(name: 'Ivory Black', percentage: 1.68),
        ColorComponent(name: 'Phtalo Blue', percentage: 1.68),
      ]);
  }

  static PaletteColor _buildRecipe4() {
    return PaletteColor(
        title: 'Violet Grey',
        color: const Color(0xFFa9a6a8).toARGB32(),
        status: 'verified',
      )
      ..getComponents().addAll([
        ColorComponent(name: 'Titanium White', percentage: 96.65),
        ColorComponent(name: 'Ivory Black', percentage: 1.68),
        ColorComponent(name: 'Carmine Red', percentage: 1.68),
      ]);
  }

  static PaletteColor _buildRecipe5() {
    return PaletteColor(
        title: 'Payne\'s Grey',
        color: const Color(0xFF4d525a).toARGB32(),
        status: 'verified',
      )
      ..getComponents().addAll([
        ColorComponent(name: 'Ivory Black', percentage: 53.57),
        ColorComponent(name: 'Ultramarine Blue', percentage: 35.71),
        ColorComponent(name: 'Titanium White', percentage: 10.71),
      ]);
  }

  static PaletteColor _buildRecipe6() {
    return PaletteColor(
        title: 'Brown Grey',
        color: const Color(0xFF6f6d64).toARGB32(),
        status: 'verified',
      )
      ..getComponents().addAll([
        ColorComponent(name: 'Ivory Black', percentage: 50.0),
        ColorComponent(name: 'Burnt Umber', percentage: 37.5),
        ColorComponent(name: 'Titanium White', percentage: 12.5),
      ]);
  }

  static PaletteColor _buildRecipe7() {
    return PaletteColor(
        title: 'Blue Grey',
        color: const Color(0xFF67696e).toARGB32(),
        status: 'verified',
      )
      ..getComponents().addAll([
        ColorComponent(name: 'Ivory Black', percentage: 50.0),
        ColorComponent(name: 'Phtalo Blue', percentage: 25.0),
        ColorComponent(name: 'Titanium White', percentage: 25.0),
      ]);
  }

  static PaletteColor _buildRecipe8() {
    return PaletteColor(
        title: 'Bright Green',
        color: const Color(0xFF00a551).toARGB32(),
        status: 'verified',
      )
      ..getComponents().addAll([
        ColorComponent(name: 'Phtalo Green', percentage: 50.0),
        ColorComponent(name: 'Lemon Yellow', percentage: 50.0),
      ]);
  }

  static PaletteColor _buildRecipe9() {
    return PaletteColor(
        title: 'Bright Orange',
        color: const Color(0xFFf57a00).toARGB32(),
        status: 'verified',
      )
      ..getComponents().addAll([
        ColorComponent(name: 'Permanent Yellow', percentage: 75.0),
        ColorComponent(name: 'Carmine Red', percentage: 25.0),
      ]);
  }

  static PaletteColor _buildRecipe10() {
    return PaletteColor(
        title: 'Flesh Tone',
        color: const Color(0xFFf5c5a9).toARGB32(),
        status: 'verified',
      )
      ..getComponents().addAll([
        ColorComponent(name: 'Titanium White', percentage: 80.0),
        ColorComponent(name: 'Permanent Yellow', percentage: 15.0),
        ColorComponent(name: 'Carmine Red', percentage: 5.0),
      ]);
  }
}
