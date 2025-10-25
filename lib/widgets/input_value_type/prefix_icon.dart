import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vettore/icons/grufio_icons.dart';
import 'package:vettore/theme/app_theme_colors.dart';

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
        // Known default mappings; otherwise keep SVG
        if (asset.endsWith('/help.svg') || asset.endsWith('help.svg')) {
          return Icon(Grufio.help, size: size, color: color);
        }
        if (asset.endsWith('/width.svg') || asset.endsWith('width.svg')) {
          return Icon(Grufio.width, size: size, color: color);
        }
        if (asset.endsWith('/height.svg') || asset.endsWith('height.svg')) {
          return Icon(Grufio.height, size: size, color: color);
        }
        return SvgPicture.asset(
          asset,
          width: size,
          height: size,
          fit: fit,
          alignment: alignment,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
      }(),
    );
  }
}
