import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/data/database.dart';
import 'package:drift/drift.dart' show OrderingTerm, OrderingMode;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:vettore/widgets/thumbnail_tile.dart';
import 'package:vettore/widgets/content_filter_bar.dart';
import 'package:vettore/widgets/content_toolbar.dart';

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
    final db = ref.watch(appDatabaseProvider);
    final query = (db.select(db.vendorColors)
          ..where((t) => t.vendorId.equals(widget.vendorId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)
          ]))
        .watch();
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
          child: StreamBuilder<List<VendorColor>>(
            stream: query,
            builder: (context, snap) {
              final colors = snap.data ?? const <VendorColor>[];
              return LayoutBuilder(builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final int columns =
                    width.isFinite ? (width / 280.0).floor().clamp(1, 12) : 3;
                return MasonryGridView.count(
                  crossAxisCount: columns,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
                  itemCount: colors.length,
                  itemBuilder: (context, index) {
                    final c = colors[index];
                    return FutureBuilder<List<VendorColorVariant>>(
                      future: (db.select(db.vendorColorVariants)
                            ..where((t) => t.vendorColorId.equals(c.id)))
                          .get(),
                      builder: (context, vSnap) {
                        final variants =
                            vSnap.data ?? const <VendorColorVariant>[];
                        final sizes =
                            variants.map((v) => '${v.size}ml').join(', ');
                        final density = c.colorDensity?.toString() ?? '';
                        final assetPath =
                            c.imageUrl.isNotEmpty ? c.imageUrl : null;
                        return ThumbnailTile(
                          assetPath: assetPath,
                          imageBytes: null,
                          lines: [c.name, sizes, density],
                        );
                      },
                    );
                  },
                );
              });
            },
          ),
        ),
      ],
    );
  }
}
