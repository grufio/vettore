import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:vettore/widgets/thumbnail_tile.dart';
import 'package:vettore/widgets/content_filter_bar.dart';
import 'package:vettore/widgets/content_toolbar.dart';
import 'package:vettore/providers/project_provider.dart';

class VendorColorsOverviewPage extends ConsumerStatefulWidget {
  final int vendorId;
  final String vendorBrand;
  const VendorColorsOverviewPage(
      {super.key, required this.vendorId, required this.vendorBrand});

  @override
  ConsumerState<VendorColorsOverviewPage> createState() =>
      _VendorColorsOverviewPageState();
}

class _VendorColorsOverviewPageState
    extends ConsumerState<VendorColorsOverviewPage> {
  String _activeFilterId = 'all';

  @override
  Widget build(BuildContext context) {
    // db available if needed
    final aggAsync = ref.watch(vendorColorsAggregatedProvider(widget.vendorId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ContentToolbarTitle(title: widget.vendorBrand),
        ContentFilterBar(
          items: const [
            FilterItem(id: 'completed', label: 'Completed'),
            FilterItem(id: 'all', label: 'All'),
          ],
          activeId: _activeFilterId,
          onChanged: (id) => setState(() => _activeFilterId = id),
          height: 40.0,
          horizontalPadding: 24.0,
          gap: 4.0,
        ),
        Expanded(
          child: Builder(builder: (context) {
            final agg =
                aggAsync.asData?.value ?? const <VendorColorAggregated>[];
            return LayoutBuilder(builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final int columns =
                  width.isFinite ? (width / 280.0).floor().clamp(1, 12) : 3;
              return MasonryGridView.count(
                crossAxisCount: columns,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
                itemCount: agg.length,
                itemBuilder: (context, index) {
                  final row = agg[index];
                  final sizes = row.sizes
                      .split(',')
                      .where((e) => e.trim().isNotEmpty)
                      .map((e) => '${e.trim()}ml')
                      .join(', ');
                  final density = row.color.colorDensity?.toString() ?? '';
                  final assetPath =
                      row.color.imageUrl.isNotEmpty ? row.color.imageUrl : null;
                  final Color? bg = (assetPath == null &&
                          row.rgbHex != null &&
                          row.rgbHex!.isNotEmpty)
                      ? _parseHex(row.rgbHex!)
                      : null;
                  return ThumbnailTile(
                    assetPath: assetPath,
                    imageBytes: null,
                    backgroundFill: bg,
                    lines: [row.color.name, sizes, density],
                  );
                },
              );
            });
          }),
        ),
      ],
    );
  }
}

Color _parseHex(String hex) {
  final s = hex.replaceAll('#', '');
  final v = int.parse(s, radix: 16);
  return Color(0xFF000000 | v);
}
