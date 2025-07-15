import 'package:hive/hive.dart';
import 'package:vettore/color_component_model.dart';

part 'palette_color.g.dart';

@HiveType(typeId: 2)
class PaletteColor {
  @HiveField(0)
  String title;

  @HiveField(1)
  int color;

  @HiveField(2)
  String status;

  @HiveField(3)
  List<ColorComponent> components;

  PaletteColor({
    required this.title,
    required this.color,
    this.status = '',
    List<ColorComponent>? components,
  }) : components = components ?? [];
}
