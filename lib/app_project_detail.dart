import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'dart:typed_data';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/widgets/side_panel.dart';
import 'package:vettore/widgets/content_filter_bar.dart';
import 'package:vettore/widgets/input_value_type.dart';
import 'package:vettore/widgets/section_sidebar.dart';
import 'package:vettore/widgets/section_input.dart';
import 'package:vettore/widgets/button_app.dart';
// import 'package:vettore/widgets/image_upload_text.dart';
import 'package:vettore/widgets/image_upload_area.dart';
import 'package:vettore/widgets/input_row_full.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/data/database.dart';
import 'package:image/image.dart' as img;
import 'dart:async';

class AppProjectDetailPage extends ConsumerStatefulWidget {
  final int initialActiveIndex;
  final ValueChanged<int>? onNavigateTab;
  final int? projectId; // optional for now; when null we load/create first
  final ValueChanged<String>? onProjectTitleSaved;
  final ValueChanged<int>? onDeleteProject;
  const AppProjectDetailPage({
    super.key,
    this.initialActiveIndex = 1,
    this.onNavigateTab,
    this.projectId,
    this.onProjectTitleSaved,
    this.onDeleteProject,
  });

  @override
  ConsumerState<AppProjectDetailPage> createState() =>
      _AppProjectDetailPageState();
}

class _AppProjectDetailPageState extends ConsumerState<AppProjectDetailPage> {
  // Header handled by shell; these are no longer needed
  String _detailFilterId = 'image';
  // Photo viewer removed for empty state; controllers retained for later usage
  late final TextEditingController _inputValueController;
  late final TextEditingController _inputValueController2;
  late final TextEditingController _singleInputController;
  late final TextEditingController _projectController;
  int? _currentProjectId;
  double _rightPanelWidth = 320.0;
  bool _hasImage = false;
  late final FocusNode _projectTitleFocusNode;
  StreamSubscription<DbProject?>? _projectSub;

  void _setHasImage(bool value) {
    if (!mounted) return;
    setState(() => _hasImage = value);
  }

  @override
  void initState() {
    super.initState();
    _inputValueController = TextEditingController();
    _inputValueController2 = TextEditingController();
    _singleInputController = TextEditingController();
    _projectController = TextEditingController();
    _projectTitleFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _projectTitleFocusNode.requestFocus();
      }
    });
    _initProject();
  }

  @override
  void dispose() {
    _inputValueController.dispose();
    _inputValueController2.dispose();
    _singleInputController.dispose();
    _projectController.dispose();
    _projectTitleFocusNode.dispose();
    _projectSub?.cancel();
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

    // Image presence is determined via DB stream in the body below

    return ColoredBox(
      color: kWhite,
      child: Column(
        children: [
          // Header handled by shared shell; keep content only when embedded
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
                    topPadding: 0.0,
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
                        _rightPanelWidth = 320.0;
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
                              focusNode: _projectTitleFocusNode,
                              placeholder: null,
                              suffixText: null,
                              onActionTap: _saveProjectTitle,
                            ),
                          ],
                        ),
                        StreamBuilder<DbProject?>(
                          stream: (_currentProjectId != null)
                              ? ref
                                  .watch(projectRepositoryProvider)
                                  .watchById(_currentProjectId!)
                              : const Stream.empty(),
                          builder: (context, snapshot) {
                            final int? imageId = snapshot.data?.imageId;
                            final bool hasImage = imageId != null;
                            if (hasImage) {
                              final dimsAsync =
                                  ref.watch(imageDimensionsProvider(imageId));
                              final dims = dimsAsync.asData?.value;
                              if (dims != null) {
                                final String w = (dims.$1 ?? '').toString();
                                final String h = (dims.$2 ?? '').toString();
                                if (w.isNotEmpty &&
                                    _inputValueController.text != w) {
                                  _inputValueController.text = w;
                                }
                                if (h.isNotEmpty &&
                                    _inputValueController2.text != h) {
                                  _inputValueController2.text = h;
                                }
                              }
                            } else {
                              if (_inputValueController.text.isNotEmpty) {
                                _inputValueController.text = '';
                              }
                              if (_inputValueController2.text.isNotEmpty) {
                                _inputValueController2.text = '';
                              }
                            }
                            return SectionSidebar(
                              title: 'Title',
                              children: [
                                SectionInput(
                                  left: InputValueType(
                                    key: const ValueKey('width'),
                                    controller: _inputValueController,
                                    placeholder: hasImage ? null : 'Width',
                                    suffixText: 'px',
                                    readOnly: !hasImage,
                                  ),
                                  right: InputValueType(
                                    key: const ValueKey('height'),
                                    controller: _inputValueController2,
                                    placeholder: hasImage ? null : 'Height',
                                    suffixText: 'px',
                                    readOnly: !hasImage,
                                  ),
                                  actionIconAsset: null,
                                ),
                                SectionInput(
                                  left: InputValueType(
                                    controller: _singleInputController,
                                    placeholder: null,
                                    suffixText: 'px',
                                    dropdownItems: const [
                                      'px',
                                      'mm',
                                      'cm',
                                      'in'
                                    ],
                                    selectedItem: 'px',
                                    variant: InputVariant.selector,
                                    onItemSelected: (v) {
                                      // keep text; only unit changes implied
                                    },
                                  ),
                                  right: null,
                                  actionIconAsset: null,
                                ),
                                SectionInput(
                                  full: OutlinedActionButton(
                                    label: 'Delete Project',
                                    onTap: () async {
                                      if (_currentProjectId == null) return;
                                      final id = _currentProjectId!;
                                      await ref
                                          .read(projectRepositoryProvider)
                                          .delete(id);
                                      if (!mounted) return;
                                      widget.onDeleteProject?.call(id);
                                    },
                                  ),
                                  actionIconAsset: null,
                                ),
                              ],
                            );
                          },
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
  Future<void> _handleImageBytes(Uint8List bytes) async {
    if (_currentProjectId == null) return;
    // Decode to get dimensions
    final decoded = img.decodeImage(bytes);
    final int? width = decoded?.width;
    final int? height = decoded?.height;
    final imagesDao = ref.read(appDatabaseProvider);
    // Insert image row
    final imageId = await imagesDao.into(imagesDao.images).insert(
          ImagesCompanion.insert(
            origSrc: Value(bytes),
            origBytes: Value(bytes.length),
            origWidth: width != null ? Value(width) : const Value.absent(),
            origHeight: height != null ? Value(height) : const Value.absent(),
            // unique colors unknown here
            thumbnail: const Value.absent(),
            mimeType: const Value('image'),
            convSrc: const Value.absent(),
            convBytes: const Value.absent(),
            convWidth: const Value.absent(),
            convHeight: const Value.absent(),
            convUniqueColors: const Value.absent(),
            origUniqueColors: const Value.absent(),
          ),
        );
    // Point project to this image
    final repo = ref.read(projectRepositoryProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    await repo.update(
      ProjectsCompanion(
        id: Value(_currentProjectId!),
        imageId: Value(imageId),
        updatedAt: Value(now),
      ),
    );
    // Update local UI controllers with dimensions
    if (width != null) _inputValueController.text = width.toString();
    if (height != null) _inputValueController2.text = height.toString();
    _setHasImage(true);
  }

  // Dialog upload handled inside ImageUploadArea

  Future<void> _initProject() async {
    // Determine project to load: prefer explicit id, else load first project if any
    final repo = ref.read(projectRepositoryProvider);
    try {
      if (widget.projectId != null) {
        _currentProjectId = widget.projectId;
        final p = await repo.getById(widget.projectId!);
        _projectController.text = p.title;
        _hasImage = p.imageId != null;
        if (p.imageId != null) {
          await _loadImageDimensions(p.imageId!);
        } else {
          _inputValueController.text = '';
          _inputValueController2.text = '';
        }
        _subscribeToProject(_currentProjectId!);
        return;
      }
      final all = await repo.getAll();
      if (all.isNotEmpty) {
        final p = all.first;
        _currentProjectId = p.id;
        _projectController.text = p.title;
        _hasImage = p.imageId != null;
        if (p.imageId != null) {
          await _loadImageDimensions(p.imageId!);
        } else {
          _inputValueController.text = '';
          _inputValueController2.text = '';
        }
        _subscribeToProject(_currentProjectId!);
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
    // Notify shell to update tab label
    widget.onProjectTitleSaved?.call(_projectController.text);
  }

  void _subscribeToProject(int projectId) {
    _projectSub?.cancel();
    _projectSub =
        ref.read(projectRepositoryProvider).watchById(projectId).listen((p) {
      if (!mounted) return;
      if (p == null) {
        _inputValueController.text = '';
        _inputValueController2.text = '';
        _setHasImage(false);
        return;
      }
      final nextHasImage = p.imageId != null;
      if (p.imageId != null) {
        _loadImageDimensions(p.imageId!);
      } else {
        _inputValueController.text = '';
        _inputValueController2.text = '';
      }
      if (nextHasImage != _hasImage) _setHasImage(nextHasImage);
    });
  }

  Widget _buildDetailBody() {
    // Build consumes project/image streams to provide initial bytes to viewer
    return StreamBuilder<DbProject?>(
      stream: (_currentProjectId != null)
          ? ref.read(projectRepositoryProvider).watchById(_currentProjectId!)
          : const Stream.empty(),
      builder: (context, snap) {
        final project = snap.data;
        final imageId = project?.imageId;
        final bytesAsync = (imageId != null)
            ? ref.watch(imageBytesProvider(imageId))
            : const AsyncValue<Uint8List?>.data(null);
        final bytes = bytesAsync.asData?.value;
        return ColoredBox(
          color: kGrey10,
          child: Center(
            child: ImageUploadArea(
              initialBytes: bytes,
              onBytesSelected: (b) => _handleImageBytes(b),
            ),
          ),
        );
      },
    );
  }
}

extension _ImageDimensions on _AppProjectDetailPageState {
  Future<void> _loadImageDimensions(int imageId) async {
    final db = ref.read(appDatabaseProvider);
    try {
      final row = await (db.select(db.images)
            ..where((t) => t.id.equals(imageId)))
          .getSingleOrNull();
      final int? width = row?.origWidth;
      final int? height = row?.origHeight;
      if (width != null) _inputValueController.text = width.toString();
      if (height != null) _inputValueController2.text = height.toString();
    } catch (_) {
      // ignore read errors
    }
  }
}
