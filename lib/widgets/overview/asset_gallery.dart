import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';
// ignore_for_file: always_use_package_imports
import '../thumbnail_tile.dart';
import '../../providers/tabs_providers.dart';

class AssetGallery extends ConsumerWidget {
  const AssetGallery({super.key});

  Future<List<Map<String, dynamic>>> _loadProjects() async {
    try {
      final String jsonString =
          await rootBundle.loadString('data/projects.json');
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic> && decoded['projects'] is List) {
        return (decoded['projects'] as List)
            .whereType<Map<String, dynamic>>()
            .toList(growable: false);
      }
    } catch (_) {}
    return const <Map<String, dynamic>>[];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadProjects(),
      builder: (context, snapshot) {
        final projects = snapshot.data ?? const <Map<String, dynamic>>[];
        return LayoutBuilder(builder: (context, constraints) {
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
          for (int i = 0; i < projects.length; i++) {
            final p = projects[i];
            final String title = (p['title'] ?? '').toString();
            final String status = (p['status'] ?? '').toString();
            final int? updatedAt = (p['updated_at'] is num)
                ? (p['updated_at'] as num).toInt()
                : null;
            String line3 = '';
            if (updatedAt != null) {
              String two(int n) => n.toString().padLeft(2, '0');
              final dt = DateTime.fromMillisecondsSinceEpoch(updatedAt);
              line3 =
                  '${two(dt.day)}.${two(dt.month)}.${dt.year}, ${two(dt.hour)}:${two(dt.minute)}';
            }
            final int projectId = i + 1; // stable id derived from index for now
            items.add(GestureDetector(
              onTap: () {
                // Defer provider writes and navigation to the next frame
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(tabsServiceProvider).addOrSelectProjectTab(
                        projectId: projectId,
                        label: title.isEmpty ? 'Untitled' : title,
                      );
                  context.go('/project/$projectId');
                });
              },
              child: RepaintBoundary(
                child: ThumbnailTile(
                  lines: [title.isEmpty ? 'Untitled' : title, status, line3],
                ),
              ),
            ));
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
        });
      },
    );
  }
}
