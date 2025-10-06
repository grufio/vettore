// lib/app_overview.dart

import 'package:flutter/cupertino.dart';
import 'dart:typed_data';
import 'dart:io' show Platform;

import 'package:vettore/models/grufio_tab_data.dart';
import 'package:vettore/widgets/grufio_tabs_app.dart' show GrufioTab;
import 'package:vettore/widgets/side_panel.dart';
import 'package:vettore/widgets/home_navigation.dart';
import 'package:vettore/widgets/content_toolbar.dart';
import 'package:vettore/widgets/button_app.dart';
import 'package:vettore/widgets/content_filter_bar.dart';
import 'package:vettore/widgets/app_header_bar.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/app_project_detail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/providers/image_providers.dart';
import 'package:vettore/providers/navigation_providers.dart';
import 'package:vettore/app_image_detail.dart';
import 'package:drift/drift.dart' as drift show Value;
import 'package:vettore/data/database.dart';
// import 'package:vettore/widgets/preview_gallery.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:vettore/widgets/thumbnail_tile.dart';
import 'package:vettore/widgets/context_menu.dart';

const double _kToolbarHeight = 40.0;

/// A lightweight wrapper that connects all tabs into a scrollable Row:
class GrufioTabsApp extends StatelessWidget {
  final List<GrufioTabData> tabs;
  final int activeIndex;
  final ValueChanged<int> onTabSelected;

  const GrufioTabsApp({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(tabs.length, (i) {
        final t = tabs[i];
        return GrufioTab(
          iconPath: t.iconPath,
          label: t.label,
          width: t.width,
          isActive: i == activeIndex,
          showLeftBorder: i == 0, // home: left border
          showRightBorder: true, // all tabs: right border (home has both)
          onTap: () => onTabSelected(i),
        );
      }),
    );
  }
}

class AppOverviewPage extends ConsumerStatefulWidget {
  final bool showHeader;
  final ValueChanged<int>? onOpenProject;
  final VoidCallback? onAddProject;
  final void Function(int vendorId, String vendorBrand)? onOpenVendor;
  const AppOverviewPage(
      {super.key,
      this.showHeader = true,
      this.onOpenProject,
      this.onAddProject,
      this.onOpenVendor});
  @override
  ConsumerState<AppOverviewPage> createState() => _AppOverviewPageState();
}

class _AppOverviewPageState extends ConsumerState<AppOverviewPage> {
  int _activeIndex = 0;
  bool _showDetail = false;
  String _activeFilterId = 'completed';
  double _sidePanelWidth = 260.0;
  // int? _newProjectIdForDetail; // removed
  // Persistent index now handled by provider
  final _tabs = <GrufioTabData>[
    const GrufioTabData(iconPath: 'assets/icons/32/home.svg', width: 40),
    const GrufioTabData(
        iconPath: 'assets/icons/32/color-palette.svg', label: 'Palette'),
    const GrufioTabData(
        iconPath: 'assets/icons/32/color-palette.svg', label: 'Example'),
  ];

  void _onTabSelected(int i) => setState(() {
        _activeIndex = i;
        _showDetail = i != 0;
      });

  @override
  void initState() {
    super.initState();
    // Force initial view to Home (gallery)
    _activeIndex = 0;
    _showDetail = false;
  }

  void _onCloseTab(int index) {
    if (index <= 0 || index >= _tabs.length) {
      return; // do not close home; guard bounds
    }
    setState(() {
      _tabs.removeAt(index);
      if (_activeIndex >= _tabs.length) {
        _activeIndex = _tabs.length - 1;
      }
    });
  }

  void _onAddTab() {
    // Create an Untitled project, then insert a tab labeled with its title
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repo = ref.read(projectRepositoryProvider);
      final now = DateTime.now().millisecondsSinceEpoch;
      int id;
      try {
        id = await repo.insert(ProjectsCompanion.insert(
          title: 'Untitled',
          author: const drift.Value(null),
          status: const drift.Value('draft'),
          createdAt: now,
          updatedAt: now,
          imageId: const drift.Value(null),
          canvasWidthPx: const drift.Value(100),
          canvasHeightPx: const drift.Value(100),
          canvasWidthValue: const drift.Value(100.0),
          canvasWidthUnit: const drift.Value('mm'),
          canvasHeightValue: const drift.Value(100.0),
          canvasHeightUnit: const drift.Value('mm'),
        ));
      } catch (e) {
        // ignore: avoid_print
        print('[overview] project insert failed: $e');
        rethrow;
      }
      // Insert new tab labeled with project title and navigate to detail
      if (mounted) {
        setState(() {
          final int paletteIndex =
              _tabs.indexWhere((t) => t.label == 'Palette');
          final int insertIndex =
              paletteIndex >= 0 ? paletteIndex + 1 : _tabs.length;
          _tabs.insert(
            insertIndex,
            const GrufioTabData(
              iconPath: 'assets/icons/32/color-palette.svg',
              label: 'Untitled',
            ),
          );
          _activeIndex = insertIndex;
          _showDetail = true;
        });
        // Set providers for new project and default page
        ref.read(currentProjectIdProvider.notifier).state = id;
        ref.read(currentPageProvider.notifier).state = PageId.project;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      if (!widget.showHeader) {
        // Render only the content area for Home (gallery)
        return ColoredBox(
          color: kWhite,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SidePanel(
                side: SidePanelSide.left,
                width: _sidePanelWidth,
                topPadding: 8.0,
                horizontalPadding: 16.0,
                resizable: true,
                minWidth: 200.0,
                maxWidth: 400.0,
                onResizeDelta: (dx) => setState(() {
                  _sidePanelWidth = (_sidePanelWidth + dx).clamp(200.0, 400.0);
                }),
                onResetWidth: () => setState(() {
                  _sidePanelWidth = 280.0;
                }),
                child: Consumer(builder: (context, ref, _) {
                  final navIndex = ref.watch(homeNavSelectedIndexProvider);
                  return HomeNavigation(
                    rowHeight: 24.0,
                    selectedIndex: navIndex,
                    onTap: (i) {
                      ref.read(homeNavSelectedIndexProvider.notifier).set(i);
                    },
                  );
                }),
              ),
              Expanded(
                child: Consumer(builder: (context, ref, _) {
                  final navIndex = ref.watch(homeNavSelectedIndexProvider);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ContentToolbar(
                        children: [
                          AddProjectButton(
                              onTap: widget.onAddProject ?? _onAddTab),
                        ],
                      ),
                      ContentFilterBar(
                        items: const [
                          FilterItem(id: 'completed', label: 'Completed'),
                          FilterItem(id: 'all', label: 'All'),
                        ],
                        activeId: _activeFilterId,
                        onChanged: (id) => setState(() => _activeFilterId = id),
                      ),
                      Expanded(
                          child: _HomeGalleryContainer(
                        onOpenProject: widget.onOpenProject,
                        onOpenVendor: widget.onOpenVendor,
                        showProjects: (navIndex >= 0 && navIndex <= 7)
                            ? true
                            : (navIndex == 1),
                        showVendors: (navIndex >= 8 && navIndex <= 11)
                            ? true
                            : (navIndex == 9),
                      )),
                    ],
                  );
                }),
              ),
            ],
          ),
        );
      }
      return ColoredBox(
        color: kWhite,
        child: Column(
          children: [
            // ─────────── Titlebar region (custom frame) ───────────
            AppHeaderBar(
              tabs: _tabs,
              activeIndex: _activeIndex,
              onTabSelected: _onTabSelected,
              height: _kToolbarHeight,
              leftPaddingWhenWindowed: 72,
              onCloseTab: _onCloseTab,
              onAddTab: _onAddTab,
            ),

            // ─────────── Content region ───────────
            Expanded(
              child: ColoredBox(
                color: kWhite,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_activeIndex == 0)
                      SidePanel(
                        side: SidePanelSide.left,
                        width: _sidePanelWidth,
                        topPadding: 8.0,
                        horizontalPadding: 16.0,
                        resizable: true,
                        minWidth: 200.0,
                        maxWidth: 400.0,
                        onResizeDelta: (dx) => setState(() {
                          _sidePanelWidth =
                              (_sidePanelWidth + dx).clamp(200.0, 400.0);
                        }),
                        onResetWidth: () => setState(() {
                          _sidePanelWidth = 280.0;
                        }),
                        child: Consumer(builder: (context, ref, _) {
                          final navIndex =
                              ref.watch(homeNavSelectedIndexProvider);
                          return HomeNavigation(
                            rowHeight: 24.0,
                            selectedIndex: navIndex,
                            onTap: (i) {
                              ref
                                  .read(homeNavSelectedIndexProvider.notifier)
                                  .set(i);
                            },
                          );
                        }),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_activeIndex == 0)
                            ContentToolbar(
                              children: [
                                AddProjectButton(
                                    onTap: widget.onAddProject ?? _onAddTab),
                              ],
                            ),
                          if (_activeIndex == 0)
                            ContentFilterBar(
                              items: const [
                                FilterItem(id: 'completed', label: 'Completed'),
                                FilterItem(id: 'all', label: 'All'),
                              ],
                              activeId: _activeFilterId,
                              onChanged: (id) =>
                                  setState(() => _activeFilterId = id),
                            ),
                          Expanded(
                            child: _showDetail
                                ? Consumer(builder: (context, ref, _) {
                                    final page = ref.watch(currentPageProvider);
                                    switch (page) {
                                      case PageId.project:
                                        return const AppProjectDetailPage();
                                      case PageId.image:
                                        return const AppImageDetailPage();
                                      case PageId.conversion:
                                      case PageId.grid:
                                      case PageId.output:
                                        return const AppProjectDetailPage();
                                    }
                                  })
                                : (_activeIndex == 0
                                    ? Consumer(builder: (context, ref2, _) {
                                        final navIndex = ref2.watch(
                                            homeNavSelectedIndexProvider);
                                        return _HomeGalleryContainer(
                                          onOpenProject: widget.onOpenProject ??
                                              (projId) {
                                                ref
                                                    .read(
                                                        currentProjectIdProvider
                                                            .notifier)
                                                    .state = projId;
                                                ref
                                                    .read(currentPageProvider
                                                        .notifier)
                                                    .state = PageId.project;
                                                setState(() {
                                                  _showDetail = true;
                                                });
                                              },
                                          onOpenVendor: widget.onOpenVendor,
                                          showProjects:
                                              (navIndex >= 0 && navIndex <= 7)
                                                  ? true
                                                  : (navIndex == 1),
                                          showVendors:
                                              (navIndex >= 8 && navIndex <= 11)
                                                  ? true
                                                  : (navIndex == 9),
                                        );
                                      })
                                    : Center(
                                        child: Text(
                                            'Content for Tab ${_activeIndex + 1}'),
                                      )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // iOS and other non-macOS platforms: render without macOS-specific widgets.
    return Container(
      color: kWhite,
      child: Column(
        children: [
          // Simple header area with tabs
          Container(
            height: _kToolbarHeight,
            color: const Color(0xFFF0F0F0),
            alignment: Alignment.centerRight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: GrufioTabsApp(
                tabs: _tabs,
                activeIndex: _activeIndex,
                onTabSelected: _onTabSelected,
              ),
            ),
          ),
          // Content
          Expanded(
            child: Center(
              child: Text('Content for Tab ${_activeIndex + 1}'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeGalleryContainer extends ConsumerWidget {
  final ValueChanged<int>? onOpenProject;
  final void Function(int vendorId, String vendorBrand)? onOpenVendor;
  final bool showProjects;
  final bool showVendors;
  const _HomeGalleryContainer({
    this.onOpenProject,
    this.onOpenVendor,
    this.showProjects = true,
    this.showVendors = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsStreamProvider);
    final projects = projectsAsync.asData?.value ?? const <DbProject>[];
    final db = ref.watch(appDatabaseProvider);
    return StreamBuilder<List<Vendor>>(
      stream: db.select(db.vendors).watch(),
      builder: (context, vendorSnap) {
        final vendors = vendorSnap.data ?? const <Vendor>[];
        return LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final int columns =
                width.isFinite ? (width / 280.0).floor().clamp(1, 12) : 3;
            final items = <Widget>[];
            if (showVendors) {
              for (final v in vendors) {
                final now = DateTime.now();
                String two(int n) => n.toString().padLeft(2, '0');
                final formatted =
                    '${two(now.day)}.${two(now.month)}.${now.year}, ${two(now.hour)}:${two(now.minute)}';
                items.add(GestureDetector(
                  onTap: () => onOpenVendor?.call(v.id, v.vendorBrand),
                  onDoubleTap: () => onOpenVendor?.call(v.id, v.vendorBrand),
                  child: ThumbnailTile(
                    assetPath: null,
                    imageBytes: null,
                    footerHeight: 72.0,
                    lines: [v.vendorName, v.vendorBrand, formatted],
                    textPadding: 12.0,
                    lineSpacing: 12.0,
                  ),
                ));
              }
            }
            if (showProjects) {
              for (final p in projects) {
                items.add(Consumer(builder: (context, ref, _) {
                  final bytesAsync = (p.imageId != null)
                      ? ref.watch(imageBytesProvider(p.imageId!))
                      : const AsyncValue<Uint8List?>.data(null);
                  final bytes = bytesAsync.asData?.value;
                  // Image dimensions: converted if present else original
                  final dimsAsync = (p.imageId != null)
                      ? ref.watch(imageDimensionsProvider(p.imageId!))
                      : const AsyncValue<(int?, int?)>.data((null, null));
                  final dims = dimsAsync.asData?.value;
                  final int? w = dims?.$1;
                  final int? h = dims?.$2;
                  String baseSize = '';
                  if (w != null && h != null) {
                    baseSize = '${w}px x ${h}px';
                  }
                  String two(int n) => n.toString().padLeft(2, '0');
                  final dt = DateTime.fromMillisecondsSinceEpoch(p.createdAt);
                  final line3 =
                      '${two(dt.day)}.${two(dt.month)}.${dt.year}, ${two(dt.hour)}:${two(dt.minute)}';

                  // Read DPI from image (per spec: DPI belongs to image)
                  final dpiAsync = (p.imageId != null)
                      ? ref.watch(imageDpiProvider(p.imageId!))
                      : const AsyncValue<int?>.data(null);
                  final int? dpi = dpiAsync.asData?.value;
                  final String line2 = (dpi == null || dpi == 0)
                      ? baseSize
                      : (baseSize.isEmpty ? '$dpi dpi' : '$baseSize, $dpi dpi');
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
                }));
              }
            }
            return MasonryGridView.count(
              crossAxisCount: columns,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
              itemCount: items.length,
              itemBuilder: (context, index) => items[index],
            );
          },
        );
      },
    );
  }
}

class _ProjectThumbnail extends StatefulWidget {
  final Uint8List? bytes;
  final String title;
  final List<String>? lines;
  final VoidCallback onOpen;
  final Future<void> Function() onDelete;
  const _ProjectThumbnail({
    required this.bytes,
    required this.title,
    required this.onOpen,
    required this.onDelete,
    this.lines,
  });
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
      onDoubleTap: widget.onOpen,
      onSecondaryTapDown: (d) => _showMenu(d.globalPosition),
      onTapDown: (_) => setState(() => _focused = false),
      child: ThumbnailTile(
        imageBytes: widget.bytes,
        footerHeight: 72.0,
        lines: widget.lines ?? [widget.title, '', ''],
        textPadding: 12.0,
        lineSpacing: 12.0,
        borderWidth: 2.0,
        borderColor: _focused ? kInputFocus : kBordersColor,
      ),
    );
  }
}
