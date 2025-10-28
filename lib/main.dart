import 'dart:async' show unawaited;
import 'dart:io' show Platform;

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:vettore/app_image_detail.dart';
import 'package:vettore/app_icon_detail.dart';
import 'package:vettore/app_overview.dart';
import 'package:vettore/app_project_detail.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/models/grufio_tab_data.dart';
import 'package:vettore/providers/application_providers.dart';
// Legacy VendorColorsOverviewPage removed with projects feature cleanup
import 'package:vettore/providers/navigation_providers.dart';
import 'package:vettore/services/init_service.dart';
import 'package:vettore/services/lego_colors_importer.dart';
import 'package:vettore/services/settings_service.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/widgets/app_header_bar.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure native window BEFORE first frame on macOS
  if (Platform.isMacOS) {
    await windowManager.ensureInitialized();
  }

  // Initialize database and settings service before building UI
  final db = AppDatabase();
  final settings = SettingsService(db);
  await settings.init();
  // Run one-time background tasks (import, cleanup) guarded by settings flags
  unawaited(InitService(db: db, settings: settings).run());

  runApp(ProviderScope(
    overrides: [
      settingsServiceProvider.overrideWithValue(settings),
      appDatabaseProvider.overrideWithValue(db),
    ],
    child: const MyApp(),
  ));

  // Only perform desktop window setup on macOS.
  if (Platform.isMacOS) {
    doWhenWindowReady(() {
      appWindow.minSize = const Size(400, 300);
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return const MacosApp(
        debugShowCheckedModeBanner: false,
        home: _AppShell(),
      );
    }

    // On non-macOS (e.g., iOS), use a minimal WidgetsApp to render content
    // without importing Material or Cupertino themes.
    return WidgetsApp(
      color: kWhite,
      builder: (context, _) => const _AppShell(),
    );
  }
}

class _AppShell extends ConsumerStatefulWidget {
  const _AppShell();
  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell> {
  int _activeIndex = 0;
  final List<GrufioTabData> _tabs = [
    const GrufioTabData(iconId: 'home', width: 40),
  ];
  int? _currentProjectId;
  bool _adding = false;
  bool _legoImported = false;
  bool _vendorCleanupDone = false;

  void _handleSelect(int i) {
    setState(() {
      _activeIndex = i;
      // Sync current project when switching tabs
      if (i == 0) {
        _currentProjectId = null;
      } else if (i > 0) {
        final t = _tabs[i];
        if (t.projectId != null) {
          _currentProjectId = t.projectId;
          ref.read(currentProjectIdProvider.notifier).state = t.projectId;
          ref.read(currentPageProvider.notifier).state = PageId.project;
        }
      }
    });
  }

  void _handleClose(int i) {
    if (i <= 0 || i >= _tabs.length) return;
    setState(() {
      _tabs.removeAt(i);
      if (_activeIndex >= _tabs.length) _activeIndex = _tabs.length - 1;
      if (_activeIndex == 0) _currentProjectId = null;
    });
  }

  Future<void> _handleAddTab() async {
    if (_adding) return;
    setState(() => _adding = true);
    final repo = ref.read(projectRepositoryProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = await repo.insert(ProjectsCompanion.insert(
      title: 'Untitled',
      author: const Value(null),
      status: const Value('draft'),
      createdAt: now,
      updatedAt: now,
      imageId: const Value(null),
      canvasWidthPx: const Value(100),
      canvasHeightPx: const Value(100),
      canvasWidthValue: const Value(100.0),
      canvasWidthUnit: const Value('mm'),
      canvasHeightValue: const Value(100.0),
      canvasHeightUnit: const Value('mm'),
    ));
    setState(() {
      _currentProjectId = id;
      _tabs
          .add(const GrufioTabData(iconId: 'color-palette', label: 'Untitled'));
      _tabs[_tabs.length - 1] = const GrufioTabData(
        iconId: 'color-palette',
        label: 'Untitled',
      );
      _tabs[_tabs.length - 1] = GrufioTabData(
        iconId: 'color-palette',
        label: 'Untitled',
        projectId: id,
      );
      _activeIndex = _tabs.length - 1;
    });
    // Ensure detail shows Project page for the new tab
    ref.read(currentProjectIdProvider.notifier).state = id;
    ref.read(currentPageProvider.notifier).state = PageId.project;
    setState(() => _adding = false);
  }

  @override
  Widget build(BuildContext context) {
    // Kick off Lego colors import once after first frame
    if (!_legoImported) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          final db = ref.read(appDatabaseProvider);
          await LegoColorsImporter(db)
              .importFromAssetsCsv('assets/csv/lego_colors.csv');
        } catch (_) {
          // ignore import errors in UI
        } finally {
          if (mounted) setState(() => _legoImported = true);
        }
      });
    }
    if (!_vendorCleanupDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          final db = ref.read(appDatabaseProvider);
          // Delete empty LEGO vendors (no linked vendor_colors)
          await db.customStatement(
              "DELETE FROM vendors WHERE vendor_category='bricks' AND (vendor_brand LIKE 'Lego%' OR vendor_name LIKE 'Lego%') AND id NOT IN (SELECT DISTINCT vendor_id FROM vendor_colors WHERE vendor_id IS NOT NULL)");
        } catch (_) {
          // ignore cleanup errors in UI
        } finally {
          if (mounted) setState(() => _vendorCleanupDone = true);
        }
      });
    }
    return ColoredBox(
      color: kWhite,
      child: Column(
        children: [
          AppHeaderBar(
            tabs: _tabs,
            activeIndex: _activeIndex,
            onTabSelected: _handleSelect,
            onCloseTab: _handleClose,
            onAddTab: _handleAddTab,
          ),
          Expanded(
            child: (_activeIndex == 0)
                ? AppOverviewPage(
                    showHeader: false,
                    onAddProject: _handleAddTab,
                    onOpenProject: (projectId) async {
                      // If already open, select its tab; else create a new tab
                      final existingIndex = _tabs.indexWhere((t) =>
                          t.projectId != null && t.projectId == projectId);
                      if (existingIndex != -1) {
                        setState(() {
                          _activeIndex = existingIndex;
                          _currentProjectId = projectId;
                        });
                      } else {
                        // Fetch actual project title for the new tab label
                        final repo = ref.read(projectRepositoryProvider);
                        final DbProject p = await repo.getById(projectId);
                        final String tabLabel =
                            (p.title.isNotEmpty) ? p.title : 'Untitled';
                        setState(() {
                          _currentProjectId = projectId;
                          _tabs.add(GrufioTabData(
                            iconId: 'color-palette',
                            label: tabLabel,
                            projectId: projectId,
                          ));
                          _activeIndex = _tabs.length - 1;
                        });
                      }
                    },
                    onOpenVendor: (vendorId, vendorBrand) {
                      final existingIndex = _tabs.indexWhere(
                          (t) => t.vendorId != null && t.vendorId == vendorId);
                      if (existingIndex != -1) {
                        setState(() => _activeIndex = existingIndex);
                      } else {
                        setState(() {
                          _tabs.add(GrufioTabData(
                            iconId: 'color-palette',
                            label: vendorBrand,
                            vendorId: vendorId,
                          ));
                          _activeIndex = _tabs.length - 1;
                        });
                      }
                    },
                  )
                : Consumer(builder: (context, ref, _) {
                    final page = ref.watch(currentPageProvider);
                    switch (page) {
                      case PageId.project:
                        return AppProjectDetailPage(
                          initialActiveIndex: _activeIndex,
                          onNavigateTab: (i) {
                            if (i == 0) setState(() => _activeIndex = 0);
                          },
                          projectId: _currentProjectId,
                          onProjectTitleSaved: (newTitle) {
                            if (_activeIndex > 0 &&
                                _activeIndex < _tabs.length) {
                              final current = _tabs[_activeIndex];
                              _tabs[_activeIndex] = GrufioTabData(
                                iconId: current.iconId,
                                label: newTitle.isEmpty ? 'Untitled' : newTitle,
                                width: current.width,
                                projectId: current.projectId,
                              );
                              setState(() {});
                            }
                          },
                          onDeleteProject: (deletedId) {
                            final idx = _tabs.indexWhere((t) =>
                                t.projectId != null &&
                                t.projectId == deletedId);
                            if (idx != -1) {
                              setState(() {
                                _tabs.removeAt(idx);
                                _currentProjectId = null;
                                _activeIndex = 0;
                              });
                            } else {
                              setState(() {
                                _currentProjectId = null;
                                _activeIndex = 0;
                              });
                            }
                          },
                        );
                      case PageId.image:
                        return AppImageDetailPage(projectId: _currentProjectId);
                      case PageId.icon:
                        return AppIconDetailPage(projectId: _currentProjectId);
                      case PageId.conversion:
                      case PageId.grid:
                      case PageId.output:
                        return AppProjectDetailPage(
                          initialActiveIndex: _activeIndex,
                          onNavigateTab: (i) {
                            if (i == 0) setState(() => _activeIndex = 0);
                          },
                          projectId: _currentProjectId,
                        );
                    }
                  }),
          ),
        ],
      ),
    );
  }
}
