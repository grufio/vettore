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
import 'package:drift/drift.dart' show Value;
import 'package:vettore/data/database.dart';
// import 'package:vettore/widgets/preview_gallery.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:vettore/widgets/thumbnail_tile.dart';

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

class AppOverviewPage extends StatefulWidget {
  final bool showHeader;
  final ValueChanged<int>? onOpenProject;
  const AppOverviewPage(
      {super.key, this.showHeader = true, this.onOpenProject});
  @override
  State<AppOverviewPage> createState() => _AppOverviewPageState();
}

class _AppOverviewPageState extends State<AppOverviewPage> {
  int _activeIndex = 0;
  bool _showDetail = false;
  String _activeFilterId = 'completed';
  double _sidePanelWidth = 260.0;
  int? _newProjectIdForDetail;
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
    if (index <= 0 || index >= _tabs.length)
      return; // do not close home; guard bounds
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
      final container = ProviderScope.containerOf(context);
      final repo = container.read(projectRepositoryProvider);
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = await repo.insert(ProjectsCompanion.insert(
        title: 'Untitled',
        author: const Value(null),
        status: const Value('draft'),
        createdAt: now,
        updatedAt: now,
        imageId: const Value(null),
      ));
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
          _newProjectIdForDetail = id;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      if (_showDetail && widget.showHeader) {
        return AppProjectDetailPage(
          initialActiveIndex: _activeIndex,
          onNavigateTab: (i) {
            if (i == 0) {
              // Navigate back to Home overview
              setState(() {
                _activeIndex = 0;
                _showDetail = false;
              });
            }
          },
          projectId: _newProjectIdForDetail,
        );
      }
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
                minWidth: 100.0,
                maxWidth: 300.0,
                onResizeDelta: (dx) => setState(() {
                  _sidePanelWidth = (_sidePanelWidth + dx).clamp(100.0, 300.0);
                }),
                onResetWidth: () => setState(() {
                  _sidePanelWidth = 280.0;
                }),
                child: HomeNavigation(
                  rowHeight: 24.0,
                  onTap: (_) {},
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ContentToolbar(
                      children: [
                        AddProjectButton(onTap: () {}),
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
                            onOpenProject: widget.onOpenProject)),
                  ],
                ),
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
                        minWidth: 100.0,
                        maxWidth: 300.0,
                        onResizeDelta: (dx) => setState(() {
                          _sidePanelWidth =
                              (_sidePanelWidth + dx).clamp(100.0, 300.0);
                        }),
                        onResetWidth: () => setState(() {
                          _sidePanelWidth = 280.0;
                        }),
                        child: HomeNavigation(
                          rowHeight: 24.0,
                          onTap: (_) {},
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_activeIndex == 0)
                            ContentToolbar(
                              children: [
                                AddProjectButton(onTap: () {}),
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
                                ? const AppProjectDetailPage()
                                : (_activeIndex == 0
                                    ? _HomeGalleryContainer(
                                        onOpenProject: widget.onOpenProject)
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
  const _HomeGalleryContainer({this.onOpenProject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(projectRepositoryProvider);
    return StreamBuilder<List<DbProject>>(
      stream: repo.watchAll(),
      builder: (context, snapshot) {
        final projects = snapshot.data ?? const <DbProject>[];
        return LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final int columns =
                width.isFinite ? (width / 280.0).floor().clamp(1, 12) : 3;
            return MasonryGridView.count(
              crossAxisCount: columns,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final p = projects[index];
                return GestureDetector(
                  onDoubleTap: () => onOpenProject?.call(p.id),
                  child: ThumbnailTile(
                    imageBytes: Uint8List(0),
                    footerHeight: 72.0,
                    lines: [p.title, '324x240px', '30.12.2005, 12:24'],
                    textPadding: 12.0,
                    lineSpacing: 12.0,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
