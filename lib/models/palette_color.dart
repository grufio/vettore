import 'package:hive/hive.dart';
import 'color_component_model.dart';

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

  PaletteColor.from(PaletteColor other)
    : title = other.title,
      color = other.color,
      status = other.status,
      components = List<ColorComponent>.from(
        other.components.map((c) => ColorComponent.from(c)),
      );
}
