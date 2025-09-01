import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:vettore/models/grufio_tab_data.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/widgets/app_header_bar.dart';
import 'package:vettore/widgets/side_panel.dart';
import 'package:vettore/widgets/content_filter_bar.dart';
import 'package:vettore/widgets/input_value_type.dart';
import 'package:vettore/widgets/section_sidebar.dart';
import 'package:vettore/widgets/section_input.dart';
import 'package:vettore/widgets/button_app.dart';
import 'package:vettore/widgets/image_upload_text.dart';
import 'package:vettore/widgets/input_row_full.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/data/database.dart';

class AppProjectDetailPage extends ConsumerStatefulWidget {
  final int initialActiveIndex;
  final ValueChanged<int>? onNavigateTab;
  final int? projectId; // optional for now; when null we load/create first
  const AppProjectDetailPage({
    super.key,
    this.initialActiveIndex = 1,
    this.onNavigateTab,
    this.projectId,
  });

  @override
  ConsumerState<AppProjectDetailPage> createState() =>
      _AppProjectDetailPageState();
}

class _AppProjectDetailPageState extends ConsumerState<AppProjectDetailPage> {
  static const double _kToolbarHeight = 40.0;

  late int _activeIndex;
  String _detailFilterId = 'image';
  // Photo viewer removed for empty state; controllers retained for later usage
  late final TextEditingController _inputValueController;
  late final TextEditingController _inputValueController2;
  late final TextEditingController _singleInputController;
  late final TextEditingController _projectController;
  int? _currentProjectId;
  double _rightPanelWidth = 260.0;
  List<GrufioTabData> get _tabs {
    // Base tabs: Home, Palette, Example
    final base = <GrufioTabData>[
      const GrufioTabData(iconPath: 'assets/icons/32/home.svg', width: 40),
      const GrufioTabData(
          iconPath: 'assets/icons/32/color-palette.svg', label: 'Palette'),
      const GrufioTabData(
          iconPath: 'assets/icons/32/color-palette.svg', label: 'Example'),
    ];
    if (_currentProjectId != null) {
      final projectLabel = (_projectController.text.isNotEmpty)
          ? _projectController.text
          : 'Untitled';
      // Insert the project tab right after 'Palette' to match overview insertion
      base.insert(
        2,
        GrufioTabData(
          iconPath: 'assets/icons/32/color-palette.svg',
          label: projectLabel,
        ),
      );
    }
    return base;
  }

  void _onTabSelected(int i) {
    setState(() => _activeIndex = i);
    widget.onNavigateTab?.call(i);
  }

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.initialActiveIndex;
    _inputValueController = TextEditingController(text: '1024');
    _inputValueController2 = TextEditingController();
    _singleInputController = TextEditingController();
    _projectController = TextEditingController();
    _initProject();
  }

  @override
  void dispose() {
    _inputValueController.dispose();
    _inputValueController2.dispose();
    _singleInputController.dispose();
    _projectController.dispose();
    super.dispose();
  }

  // Image viewer actions will be re-enabled once an image is present.

  @override
  Widget build(BuildContext context) {
    if (!Platform.isMacOS) {
      return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text('Project Detail')),
        child: Center(child: Text('Project Detail')),
      );
    }

    return ColoredBox(
      color: kWhite,
      child: Column(
        children: [
          AppHeaderBar(
            tabs: _tabs,
            activeIndex: _activeIndex,
            onTabSelected: _onTabSelected,
            height: _kToolbarHeight,
            leftPaddingWhenWindowed: 72,
          ),
          // Detail filter bar with bottom border
          Container(
            decoration: const BoxDecoration(
              color: kWhite,
              border: Border(
                bottom: BorderSide(color: kBordersColor, width: 1.0),
              ),
            ),
            child: ContentFilterBar(
              items: const [
                FilterItem(id: 'image', label: 'Image'),
                FilterItem(id: 'conversion', label: 'Conversion'),
                FilterItem(id: 'grid', label: 'Grid'),
                FilterItem(id: 'output', label: 'Output'),
              ],
              activeId: _detailFilterId,
              onChanged: (id) => setState(() => _detailFilterId = id),
              height: 40.0,
              horizontalPadding: 24.0,
              gap: 4.0,
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: kWhite,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main detail area placeholder
                  Expanded(
                    child: _buildDetailBody(),
                  ),
                  // Right side panel (empty for now)
                  SidePanel(
                    side: SidePanelSide.right,
                    width: _rightPanelWidth,
                    topPadding: 8.0,
                    horizontalPadding: 16.0,
                    resizable: true,
                    minWidth: 200.0,
                    maxWidth: 400.0,
                    onResizeDelta: (delta) {
                      setState(() {
                        _rightPanelWidth =
                            (_rightPanelWidth + delta).clamp(200.0, 400.0);
                      });
                    },
                    onResetWidth: () {
                      setState(() {
                        _rightPanelWidth = 280.0;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SectionSidebar(
                          title: 'Projekt',
                          children: [
                            InputRowFull(
                              controller: _projectController,
                              focusNode: FocusNode()..requestFocus(),
                              placeholder: null,
                              suffixText: null,
                              onActionTap: _saveProjectTitle,
                            ),
                          ],
                        ),
                        SectionSidebar(
                          title: 'Title',
                          children: [
                            SectionInput(
                              left: InputValueType(
                                controller: _inputValueController,
                                placeholder: null,
                                suffixText: 'px',
                              ),
                              right: InputValueType(
                                controller: _inputValueController2,
                                placeholder: null,
                                suffixText: 'px',
                              ),
                              actionIconAsset: null,
                            ),
                            SectionInput(
                              left: InputValueType(
                                controller: _singleInputController,
                                placeholder: null,
                                suffixText: 'px',
                              ),
                              right: null,
                              actionIconAsset: null,
                            ),
                            SectionInput(
                              full: AddProjectButton(onTap: () {}),
                              actionIconAsset: null,
                            ),
                          ],
                        ),
                        const Expanded(child: SizedBox.shrink()),
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
}

extension on _AppProjectDetailPageState {
  Future<void> _initProject() async {
    // Determine project to load: prefer explicit id, else load first project if any
    final repo = ref.read(projectRepositoryProvider);
    try {
      if (widget.projectId != null) {
        _currentProjectId = widget.projectId;
        final p = await repo.getById(widget.projectId!);
        _projectController.text = p.title;
        return;
      }
      final all = await repo.getAll();
      if (all.isNotEmpty) {
        final p = all.first;
        _currentProjectId = p.id;
        _projectController.text = p.title;
      }
    } catch (_) {
      // Ignore load errors for now; keep empty controller
    }
  }

  Future<void> _saveProjectTitle() async {
    if (_currentProjectId == null) return;
    final repo = ref.read(projectRepositoryProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    final companion = ProjectsCompanion(
      id: Value(_currentProjectId!),
      title: Value(_projectController.text),
      updatedAt: Value(now),
    );
    await repo.update(companion);
  }

  Widget _buildDetailBody() {
    return const ColoredBox(
      color: kGrey10,
      child: Center(
        child: ImageUploadText(),
      ),
    );
  }
}
