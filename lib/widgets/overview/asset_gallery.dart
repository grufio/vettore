import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/providers/image_providers.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/widgets/context_menu.dart';
import 'package:vettore/widgets/thumbnail_tile.dart';

final vendorsStreamProvider = StreamProvider<List<Vendor>>((ref) {
  final db = ref.read(appDatabaseProvider);
  return db.select(db.vendors).watch();
});

class AssetGallery extends ConsumerWidget {
  const AssetGallery({
    super.key,
    this.onOpenProject,
    this.onOpenVendor,
    this.showProjects = true,
    this.showVendors = true,
  });

  final ValueChanged<int>? onOpenProject;
  final void Function(int vendorId, String vendorBrand)? onOpenVendor;
  final bool showProjects;
  final bool showVendors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsStreamProvider);
    final projects = projectsAsync.asData?.value ?? const <DbProject>[];
    final vendors =
        ref.watch(vendorsStreamProvider).asData?.value ?? const <Vendor>[];
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        // Choose columns so tile widths are whole logical pixels after padding/gaps
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
        if (found != null) {
          columns = found;
        }
        final items = <Widget>[];
        if (showVendors) {
          for (final v in vendors) {
            final now = DateTime.now();
            String two(int n) => n.toString().padLeft(2, '0');
            final formatted =
                '${two(now.day)}.${two(now.month)}.${now.year}, ${two(now.hour)}:${two(now.minute)}';
            items.add(RepaintBoundary(
                child: GestureDetector(
              key: ValueKey('vendor:${v.id}'),
              onTap: () => onOpenVendor?.call(v.id, v.vendorBrand),
              onDoubleTap: () => onOpenVendor?.call(v.id, v.vendorBrand),
              child: ThumbnailTile(
                lines: [v.vendorName, v.vendorBrand, formatted],
              ),
            )));
          }
        }
        if (showProjects) {
          for (final p in projects) {
            items.add(KeyedSubtree(
                key: ValueKey('project:${p.id}'),
                child:
                    RepaintBoundary(child: Consumer(builder: (context, ref, _) {
                  final Uint8List? bytes = (p.imageId != null)
                      ? ref.watch(imageBytesProvider(p.imageId!)
                          .select((av) => av.asData?.value))
                      : null;
                  String two(int n) => n.toString().padLeft(2, '0');
                  final dt = DateTime.fromMillisecondsSinceEpoch(p.createdAt);
                  final line3 =
                      '${two(dt.day)}.${two(dt.month)}.${dt.year}, ${two(dt.hour)}:${two(dt.minute)}';

                  final int? dpi = (p.imageId != null)
                      ? ref.watch(imageDpiProvider(p.imageId!)
                          .select((av) => av.asData?.value))
                      : null;
                  final String line2 =
                      (dpi == null || dpi == 0) ? '' : '$dpi dpi';
                  return _ProjectThumbnail(
                    bytes: bytes,
                    title: p.title,
                    lines: [p.title, line2, line3],
                    onOpen: () => onOpenProject?.call(p.id),
                    onDelete: () async {
                      final repo = ref.read(projectRepositoryProvider);
                      await repo.delete(p.id);
                    },
                  );
                }))));
          }
        }
        // Compute grid child aspect ratio to match ThumbnailTile layout:
        // height = image (width * 3/4) + footer (72)
        final double colWidth = tileWidthFor(columns).roundToDouble();
        const double footerHeight = 72.0;
        final double childAspectRatio =
            colWidth > 0 ? colWidth / (colWidth * 0.75 + footerHeight) : 1.0;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
          itemCount: items.length,
          itemBuilder: (context, index) => items[index],
        );
      },
    );
  }
}

class _ProjectThumbnail extends StatefulWidget {
  const _ProjectThumbnail({
    required this.bytes,
    required this.title,
    required this.onOpen,
    required this.onDelete,
    this.lines,
  });
  final Uint8List? bytes;
  final String title;
  final List<String>? lines;
  final VoidCallback onOpen;
  final Future<void> Function() onDelete;
  @override
  State<_ProjectThumbnail> createState() => _ProjectThumbnailState();
}

class _ProjectThumbnailState extends State<_ProjectThumbnail> {
  bool _focused = false;

  void _showMenu(Offset pos) {
    setState(() => _focused = true);
    ContextMenu.show(
      context: context,
      globalPosition: pos,
      items: [
        ContextMenuItem(label: 'Open', onTap: widget.onOpen),
        ContextMenuItem(
          label: 'Delete',
          onTap: () async {
            await widget.onDelete();
          },
        ),
      ],
      onClose: () => setState(() => _focused = false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onOpen,
      onDoubleTap: widget.onOpen,
      onSecondaryTapDown: (d) => _showMenu(d.globalPosition),
      onTapDown: (_) => setState(() => _focused = false),
      child: ThumbnailTile(
        imageBytes: widget.bytes,
        lines: widget.lines ?? [widget.title, '', ''],
        borderColor: _focused ? kInputFocus : kBordersColor,
      ),
    );
  }
}
