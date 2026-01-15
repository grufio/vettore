import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grufio/theme/app_theme_colors.dart';
import 'package:grufio/widgets/thumbnail_tile.dart';

/// Square-thumbnail gallery intended for SVG previews (1:1 image area).
/// Data wiring will be added later – for now we render an empty/placeholder grid
/// following the existing HomeGallery layout rules (whole-pixel columns,
/// 24px horizontal padding, 16px cross-axis spacing, fixed 72px footer).
class SvgGallery extends ConsumerWidget {
  const SvgGallery({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraints) {
      final double width = constraints.maxWidth;
      const double horizontalPadding = 24.0 * 2; // left + right
      const double crossAxisSpacing = 16.0;

      final int approxColumns =
          width.isFinite ? (width / 280.0).floor().clamp(1, 12) : 3;

      double tileWidthFor(int c) {
        final totalGaps = crossAxisSpacing * (c - 1);
        final availableWidth =
            (width - horizontalPadding - totalGaps).clamp(0.0, width);
        return c > 0 ? (availableWidth / c) : availableWidth;
      }

      bool isWhole(double v) => (v - v.roundToDouble()).abs() < 0.001;
      int columns = approxColumns;
      int? found;
      for (int c = approxColumns; c >= 1; c--) {
        if (isWhole(tileWidthFor(c))) {
          found = c;
          break;
        }
      }
      if (found == null) {
        for (int c = approxColumns + 1; c <= 12; c++) {
          if (isWhole(tileWidthFor(c))) {
            found = c;
            break;
          }
        }
      }
      if (found != null) columns = found;

      // Placeholder empty list for now (no upload, no picker)
      final List<Widget> items = <Widget>[];

      // Square tiles without footer: aspect ratio 1.0
      final double childAspectRatio = 1.0;

      if (items.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: crossAxisSpacing,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: 1,
            itemBuilder: (context, _) => const ThumbnailTile(
              imageAspectRatio: 1.0,
              footerHeight: 0.0,
              backgroundFill: kGrey20,
              lines: [],
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => items[index],
        ),
      );
    });
  }
}
