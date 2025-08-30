import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:vettore/widgets/thumbnail_tile.dart';

class PreviewGallery extends StatelessWidget {
  final List<Uint8List> items;
  final double minTileWidth;
  final double spacing;
  final EdgeInsetsGeometry padding;

  const PreviewGallery({
    super.key,
    required this.items,
    this.minTileWidth = 220.0,
    this.spacing = 16.0,
    this.padding = const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int columns =
            width.isFinite ? (width / minTileWidth).floor().clamp(1, 12) : 3;

        return MasonryGridView.count(
          crossAxisCount: columns,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          padding: padding,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ThumbnailTile(
              imageBytes: items[index],
              footerHeight: 72.0,
              lines: const ['Waldstück', '324x240px', '30.12.2005, 12:24'],
              textPadding: 12.0,
              lineSpacing: 12.0,
            );
          },
        );
      },
    );
  }
}
