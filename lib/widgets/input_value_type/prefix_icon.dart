import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      child: SvgPicture.asset(
        asset,
        width: size,
        height: size,
        fit: fit,
        alignment: alignment,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}
