import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grufio/data/database.dart';
import 'package:grufio/providers/project_provider.dart';
import 'package:grufio/widgets/overview/asset_gallery.dart'
    as hg; // providers + widget
import 'package:grufio/widgets/thumbnail_tile.dart';

void main() {
  group('HomeGallery grid', () {
    testWidgets('tile widths are whole logical pixels', (tester) async {
      final vendors = <Vendor>[
        const Vendor(id: 1, vendorName: 'Acme Co', vendorBrand: 'ACME'),
      ];
      final projects = <DbProject>[
        const DbProject(
          id: 10,
          title: 'Project A',
          status: 'active',
          createdAt: 0,
          updatedAt: 0,
          canvasWidthPx: 100,
          canvasHeightPx: 80,
          canvasWidthValue: 100,
          canvasWidthUnit: 'px',
          canvasHeightValue: 80,
          canvasHeightUnit: 'px',
          gridCellWidthValue: 10,
          gridCellWidthUnit: 'px',
          gridCellHeightValue: 10,
          gridCellHeightUnit: 'px',
        ),
      ];

      await tester.pumpWidget(ProviderScope(
        overrides: [
          hg.vendorsStreamProvider.overrideWith((ref) => Stream.value(vendors)),
          projectsStreamProvider.overrideWith((ref) => Stream.value(projects)),
        ],
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(width: 1000, height: 800, child: hg.AssetGallery()),
        ),
      ));

      await tester.pumpAndSettle();

      final size = tester.getSize(find.byType(ThumbnailTile).first);
      final delta = (size.width - size.width.roundToDouble()).abs();
      expect(delta, lessThan(0.001));
    });

    testWidgets('stable keys and RepaintBoundary wrappers exist',
        (tester) async {
      final vendors = <Vendor>[
        const Vendor(id: 1, vendorName: 'Acme Co', vendorBrand: 'ACME'),
        const Vendor(id: 2, vendorName: 'Globex', vendorBrand: 'GLOB'),
      ];
      final projects = <DbProject>[
        const DbProject(
          id: 10,
          title: 'Project A',
          status: 'active',
          createdAt: 0,
          updatedAt: 0,
          canvasWidthPx: 100,
          canvasHeightPx: 80,
          canvasWidthValue: 100,
          canvasWidthUnit: 'px',
          canvasHeightValue: 80,
          canvasHeightUnit: 'px',
          gridCellWidthValue: 10,
          gridCellWidthUnit: 'px',
          gridCellHeightValue: 10,
          gridCellHeightUnit: 'px',
        ),
      ];

      await tester.pumpWidget(ProviderScope(
        overrides: [
          hg.vendorsStreamProvider.overrideWith((ref) => Stream.value(vendors)),
          projectsStreamProvider.overrideWith((ref) => Stream.value(projects)),
        ],
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(width: 1000, height: 800, child: hg.AssetGallery()),
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('vendor:1')), findsOneWidget);
      expect(find.byKey(const ValueKey('vendor:2')), findsOneWidget);
      expect(find.byKey(const ValueKey('project:10')), findsOneWidget);

      // RepaintBoundary exists for vendor (could be multiple ancestors in grid layout)
      final vendorFinder = find.byKey(const ValueKey('vendor:1'));
      expect(
          find.ancestor(
              of: vendorFinder, matching: find.byType(RepaintBoundary)),
          findsWidgets);

      // RepaintBoundary exists for project within KeyedSubtree
      final projectFinder = find.byKey(const ValueKey('project:10'));
      expect(
          find.descendant(
              of: projectFinder, matching: find.byType(RepaintBoundary)),
          findsWidgets);
    });
  });
}
