// lib/widgets/overview/app_overview.dart

import 'dart:io' show Platform;
import 'dart:convert' show jsonDecode;
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// ignore_for_file: always_use_package_imports
import '../../models/grufio_tab_data.dart';
import '../../providers/application_providers.dart';
import '../../providers/tabs_providers.dart';
// import 'package:grufio/providers/project_provider.dart';
// import 'package:grufio/widgets/app_header_bar.dart';
import '../../theme/app_theme_colors.dart';
import '../button_app.dart';
import '../content_filter_bar.dart';
import '../content_toolbar.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'asset_gallery.dart';
import 'overview_header.dart';
import '../side_menu_navigation.dart';
import '../side_panel.dart';
import '../tabs_main.dart' show GrufioTab;

const double _kToolbarHeight = 40.0;

// Vendors stream moved to widgets/overview/asset_gallery.dart

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
          iconId: t.iconId,
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
  String _activeFilterId = 'completed';
  double _sidePanelWidth = 260.0;
  String _pageTitle = 'Projects';
  // int? _newProjectIdForDetail; // removed
  // Persistent index now handled by provider
  final _tabs = <GrufioTabData>[
    const GrufioTabData(iconId: 'home', width: 40),
    const GrufioTabData(iconId: 'color-palette', label: 'Palette'),
  ];

  void _onTabSelected(int i) => setState(() {
        _activeIndex = i;
      });

  @override
  void initState() {
    super.initState();
    // Force initial view to Home (gallery)
    _activeIndex = 0;
    _loadTitleFromJson();
  }

  Future<void> _loadTitleFromJson() async {
    try {
      final String jsonString =
          await rootBundle.loadString('data/app_overview.json');
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        final String? title = decoded['pageTitle']?.toString();
        if (title != null && title.isNotEmpty) {
          if (mounted) {
            setState(() {
              _pageTitle = title;
            });
          }
        }
      }
    } catch (_) {
      // Ignore errors and keep default title
    }
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
      final svc = ref.read(projectServiceProvider);
      int id;
      try {
        id = await svc.createDraft('Untitled');
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
              iconId: 'color-palette',
              label: 'Untitled',
            ),
          );
          _activeIndex = insertIndex;
        });
        // Navigate to project page via router
        if (mounted) {
          // Ensure header tab exists/selects
          ref.read(tabsServiceProvider).addOrSelectProjectTab(
                projectId: id,
                label: 'Untitled',
              );
          // ignore: use_build_context_synchronously
          context.push('/project/$id');
        }
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
                  return ProjectNavigation(
                    selectedIndex: navIndex,
                    onTap: (i) {
                      ref.read(homeNavSelectedIndexProvider.notifier).set(i);
                    },
                  );
                }),
              ),
              Expanded(
                child: Consumer(builder: (context, ref, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ContentToolbar(
                        title: _pageTitle,
                        trailing: [
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
                      const Expanded(child: AssetGallery()),
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
                          return ProjectNavigation(
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
                              title: _pageTitle,
                              trailing: [
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
                          const Expanded(child: AssetGallery()),
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
              child: Text('Content for Tab ${_activeIndex + 1}')
            ),
          ),
        ],
      ),
    );
  }
}



