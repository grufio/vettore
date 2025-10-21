// lib/app_overview.dart

import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

import 'package:vettore/models/grufio_tab_data.dart';
import 'package:vettore/widgets/grufio_tabs_app.dart' show GrufioTab;
import 'package:vettore/widgets/side_panel.dart';
import 'package:vettore/widgets/home_navigation.dart';
import 'package:vettore/widgets/content_toolbar.dart';
import 'package:vettore/widgets/button_app.dart';
import 'package:vettore/widgets/content_filter_bar.dart';
// import 'package:vettore/widgets/app_header_bar.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/app_project_detail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/providers/application_providers.dart';
// import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/providers/navigation_providers.dart';
import 'package:vettore/app_image_detail.dart';
import 'package:drift/drift.dart' as drift show Value;
import 'package:vettore/data/database.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:vettore/widgets/overview/home_gallery.dart';
import 'package:vettore/widgets/overview/overview_header.dart';

const double _kToolbarHeight = 40.0;

// Vendors stream moved to widgets/overview/home_gallery.dart

/// A lightweight wrapper that connects all tabs into a scrollable Row:
class GrufioTabsApp extends StatelessWidget {
  const GrufioTabsApp({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onTabSelected,
  });
  final List<GrufioTabData> tabs;
  final int activeIndex;
  final ValueChanged<int> onTabSelected;

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
          onTap: () => onTabSelected(i),
        );
      }),
    );
  }
}

class AppOverviewPage extends ConsumerStatefulWidget {
  const AppOverviewPage(
      {super.key,
      this.showHeader = true,
      this.onOpenProject,
      this.onAddProject,
      this.onOpenVendor});
  final bool showHeader;
  final ValueChanged<int>? onOpenProject;
  final VoidCallback? onAddProject;
  final void Function(int vendorId, String vendorBrand)? onOpenVendor;
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
                          child: HomeGallery(
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
            OverviewHeader(
              tabs: _tabs,
              activeIndex: _activeIndex,
              onTabSelected: _onTabSelected,
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
                                        return HomeGallery(
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
    return ColoredBox(
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
