import 'package:flutter/widgets.dart';
import 'package:grufio/icons/grufio_icons.dart';
import 'package:grufio/theme/app_theme_colors.dart';

class PrefixIcon extends StatelessWidget {
  const PrefixIcon({
    super.key,
    required this.asset,
    this.size = 16.0,
    this.alignment = Alignment.centerLeft,
    this.fit = BoxFit.none,
    this.color = kGrey70,
  });
  final String asset;
  final double size;
  final AlignmentGeometry alignment;
  final BoxFit fit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: () {
        // Deterministic ID mappings
        if (asset == 'help') {
          return SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Icon(Grufio.help, size: size, color: color),
            ),
          );
        }
        if (asset == 'width') {
          return SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Icon(Grufio.width, size: size, color: color),
            ),
          );
        }
        if (asset == 'height') {
          return SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Icon(Grufio.height, size: size, color: color),
            ),
          );
        }
        if (asset == 'document-blank') {
          return SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Icon(Grufio.documentBlank, size: size, color: color),
            ),
          );
        }
        return SizedBox(width: size, height: size);
      }(),
    );
  }
}
