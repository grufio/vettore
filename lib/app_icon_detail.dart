// This page mirrors AppImageDetailPage functionality and layout.
// It intentionally reuses the same services and widgets to remain identical.

import 'dart:async';
import 'dart:io' show File;
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'
    show debugPrint, kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/data/database.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/providers/canvas_preview_provider.dart';
import 'package:vettore/providers/image_providers.dart';
import 'package:vettore/providers/navigation_providers.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/services/image_actions.dart';
// import 'package:vettore/services/image_compute.dart' as ic; // not used for SVG
import 'package:vettore/services/image_detail_controller.dart';
import 'package:vettore/services/image_upload_service.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/widgets/artboard_view.dart';
import 'package:vettore/widgets/image_detail/image_detail_header_bar.dart';
import 'package:vettore/widgets/image_detail/image_detail_right_panel.dart';
import 'package:vettore/widgets/image_listeners.dart';
import 'package:vettore/widgets/image_preview.dart';
import 'package:vettore/widgets/image_upload_text.dart';
import 'package:vettore/widgets/input_value_type/dimension_compare_utils.dart';
import 'package:vettore/widgets/input_value_type/interpolation_map.dart';

class AppIconDetailPage extends ConsumerStatefulWidget {
  const AppIconDetailPage({super.key, this.projectId});
  final int? projectId;

  @override
  ConsumerState<AppIconDetailPage> createState() => _AppIconDetailPageState();
}

class _AppIconDetailPageState extends ConsumerState<AppIconDetailPage>
    with AutomaticKeepAliveClientMixin {
  static final Map<int, Matrix4> _savedTransforms = <int, Matrix4>{};
  bool _transformAppliedForProject = false;
  String _detailFilterId = 'project';
  late final TextEditingController _inputValueController;
  late final TextEditingController _inputValueController2;
  late final TextEditingController _projectController;
  String _interp = 'nearest';
  int? _currentProjectId;
  double _rightPanelWidth = 320.0;
  StreamSubscription<DbProject?>? _projectSub;
  bool _linkWH = false;
  int? _requestedDimsForImageId;
  int? _lastProjectId;
  final TransformationController _ivController = TransformationController();
  final GlobalKey _viewportKey = GlobalKey();
  ImageDetailController? _imgCtrl;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _inputValueController = TextEditingController();
    _inputValueController2 = TextEditingController();
    _projectController = TextEditingController();
    _initProject();
    _imgCtrl = ImageDetailController();
  }

  @override
  void dispose() {
    if (_currentProjectId != null) {
      _savedTransforms[_currentProjectId!] = _ivController.value.clone();
    }
    _inputValueController.dispose();
    _inputValueController2.dispose();
    _projectController.dispose();
    _projectSub?.cancel();
    _ivController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isMac = !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
    if (!isMac) {
      return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text('Icon Detail')),
        child: Center(child: Text('Icon Detail')),
      );
    }

    final projectIdFromProvider = ref.watch(currentProjectIdProvider);
    if (projectIdFromProvider != null &&
        projectIdFromProvider != _currentProjectId) {
      _currentProjectId = projectIdFromProvider;
      _transformAppliedForProject = false;
    }

    if (_currentProjectId != null && _currentProjectId != _lastProjectId) {
      _lastProjectId = _currentProjectId;
    }

    ref.watch(imageIdStableProvider(_currentProjectId ?? -1));

    if (!_transformAppliedForProject && _currentProjectId != null) {
      final Matrix4? saved = _savedTransforms[_currentProjectId!];
      if (saved != null) {
        _ivController.value = saved.clone();
      }
      _transformAppliedForProject = true;
    }

    return ColoredBox(
      color: kGrey10,
      child: Column(
        children: [
          if (_currentProjectId != null && _imgCtrl != null)
            ImageListeners(
              projectId: _currentProjectId!,
              controller: _imgCtrl!,
            ),
          ImageDetailHeaderBar(
            activeId: (() {
              final page = ref.watch(currentPageProvider);
              if (page == PageId.image) return 'image';
              if (page == PageId.project) return 'project';
              if (page == PageId.icon) return 'icon';
              return _detailFilterId;
            })(),
            onChanged: (id) {
              setState(() => _detailFilterId = id);
              if (id == 'project') {
                ref.read(currentPageProvider.notifier).state = PageId.project;
              } else if (id == 'image') {
                ref.read(currentPageProvider.notifier).state = PageId.image;
              } else if (id == 'icon') {
                ref.read(currentPageProvider.notifier).state = PageId.icon;
              }
            },
          ),
          Expanded(
            child: ColoredBox(
              color: kGrey10,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildDetailBody()),
                  ImageDetailRightPanel(
                    width: _rightPanelWidth,
                    onResize: (delta) {
                      setState(() {
                        _rightPanelWidth =
                            (_rightPanelWidth + delta).clamp(200.0, 400.0);
                      });
                    },
                    onReset: () {
                      setState(() {
                        _rightPanelWidth = 320.0;
                      });
                    },
                    child: ImageDetailDimensions(
                      projectId: _currentProjectId!,
                      widthController: _inputValueController,
                      heightController: _inputValueController2,
                      controller: _imgCtrl!,
                      linkWH: _linkWH,
                      onLinkChanged: (v) => setState(() => _linkWH = v),
                      interpolation: _interp,
                      onInterpolationChanged: (v) => setState(() {
                        _interp = v;
                      }),
                      onResizeTap: () async {
                        if (_currentProjectId == null) return;
                        final String wText =
                            trimTrailingDot(_inputValueController.text);
                        final String hText =
                            trimTrailingDot(_inputValueController2.text);
                        final double? wVal = double.tryParse(wText);
                        final double? hVal = double.tryParse(hText);
                        final int? imgId =
                            ref.read(imageIdStableProvider(_currentProjectId!));
                        if (imgId == null) return;
                        final int dpi =
                            (await ref.read(imageDpiProvider(imgId).future)) ??
                                96;
                        final String wUnit = _imgCtrl?.widthVC.unit ?? 'px';
                        final String hUnit = _imgCtrl?.heightVC.unit ?? 'px';
                        final (double?, double?) phys = await ref
                            .read(imagePhysPixelsProvider(imgId).future);
                        final double curPhysW = phys.$1 ?? 0.0;
                        final double curPhysH = phys.$2 ?? 0.0;
                        await ref.read(imageActionsProvider).resizeCommit(
                          ref,
                          projectId: _currentProjectId!,
                          imageId: imgId,
                          interpName:
                              kInterpolationToCvName[_interp] ?? 'linear',
                          curPhysW: curPhysW,
                          curPhysH: curPhysH,
                          typedW: wVal,
                          wUnit: wUnit,
                          typedH: hVal,
                          hUnit: hUnit,
                          dpi: dpi,
                          onPhysCommitted: (wPx, hPx) {
                            if (mounted) {
                              _imgCtrl?.applyRemotePx(
                                  widthPx: wPx, heightPx: hPx);
                            }
                          },
                        );
                      },
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

  Future<void> _pickViaDialog() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['svg', 'SVG'],
    );
    final file = result?.files.first;
    if (file?.path != null) {
      final bytes = await File(file!.path!).readAsBytes();
      // Reject non-SVG files defensively
      if (!_looksLikeSvg(bytes)) {
        debugPrint('[IconDetail] rejected non-SVG file selection');
        return;
      }
      await _handleImageBytes(bytes);
    }
  }

  Future<void> _initProject() async {
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
    } catch (_) {}
  }

  Widget _buildDetailBody() {
    final int? pid = widget.projectId ??
        _currentProjectId ??
        ref.watch(currentProjectIdProvider);
    final int? imageId =
        (pid != null) ? ref.watch(imageIdStableProvider(pid)) : null;
    final Uint8List? bytes = (imageId != null)
        ? ref.watch(
            imageBytesProvider(imageId).select((a) => a.asData?.value),
          )
        : null;

    assert(() {
      debugPrint(
          '[IconDetail] build pid=$pid imageId=$imageId bytes=${bytes?.length ?? 0}');
      return true;
    }());

    final bool showUpload = (imageId == null);

    if (imageId != null &&
        (_inputValueController.text.isEmpty ||
            _inputValueController2.text.isEmpty) &&
        _requestedDimsForImageId != imageId) {
      _requestedDimsForImageId = imageId;
      ref.read(imagePhysPixelsProvider(imageId).future).then((dims) {
        if (!mounted) return;
        _imgCtrl?.applyRemotePx(widthPx: dims.$1, heightPx: dims.$2);
      });
    }

    if (pid == null) {
      const double placeholderW = 100.0;
      const double placeholderH = 100.0;
      return Center(
        child: SizedBox(
          width: placeholderW,
          height: placeholderH,
          child: Stack(
            children: [
              const DecoratedBox(decoration: BoxDecoration(color: kWhite)),
              CustomPaint(painter: HairlineCanvasBorderPainter()),
            ],
          ),
        ),
      );
    }
    final Size canvasPx = ref.watch(canvasPreviewPxProvider(pid));
    if (canvasPx.width <= 0 || canvasPx.height <= 0) {
      const double placeholderW = 100.0;
      const double placeholderH = 100.0;
      return Center(
        child: SizedBox(
          width: placeholderW,
          height: placeholderH,
          child: Stack(
            children: [
              const DecoratedBox(decoration: BoxDecoration(color: kWhite)),
              CustomPaint(painter: HairlineCanvasBorderPainter()),
            ],
          ),
        ),
      );
    }

    final double canvasW = canvasPx.width;
    final double canvasH = canvasPx.height;
    final double imgW = canvasW;
    final double imgH = canvasH;
    final double maxContentW = imgW > canvasW ? imgW : canvasW;
    final double maxContentH = imgH > canvasH ? imgH : canvasH;
    final double margin = (0.1 * (maxContentW)).clamp(120.0, 480.0);
    final double boardW = maxContentW + margin;
    final double boardH = maxContentH + margin;

    if (showUpload) {
      return Center(
        child: ImageUploadText(
          onImageDropped: (b) async {
            if (!_looksLikeSvg(b)) {
              debugPrint('[IconDetail] drop rejected: not SVG');
              return;
            }
            final r = await ref
                .read(imageUploadServiceProvider)
                .insertImageAndMetadata(ref, b);
            await ref.read(projectServiceProvider).batchUpdate(
                  ref,
                  _currentProjectId!,
                  imageId: r.imageId,
                );
            _imgCtrl?.applyRemotePx(
                widthPx: r.width?.toDouble(), heightPx: r.height?.toDouble());
          },
          onUploadTap: _pickViaDialog,
          uploadLabel: 'Upload SVG',
          formatsText: 'Allowed format is .svg',
        ),
      );
    }

    final bool isSvg = bytes != null && _looksLikeSvg(bytes);
    return ColoredBox(
      color: kGrey70,
      child: ImagePreview(
        controller: _ivController,
        boardW: boardW,
        boardH: boardH,
        canvasW: canvasW,
        canvasH: canvasH,
        bytes: isSvg ? null : bytes,
        viewportKey: _viewportKey,
      ),
    );
  }
}

extension on _AppIconDetailPageState {
  bool _looksLikeSvg(Uint8List bytes) {
    final int len = bytes.length < 1024 ? bytes.length : 1024;
    final String head = String.fromCharCodes(bytes.sublist(0, len));
    return head.contains('<svg');
  }

  Future<void> _handleImageBytes(Uint8List bytes) async {
    if (_currentProjectId == null) return;
    assert(() {
      debugPrint(
          '[IconDetail] _handleImageBytes len=${bytes.length} pid=$_currentProjectId');
      return true;
    }());
    final (_SvgSize?, String) parsed = _parseSvgSize(bytes);
    final _SvgSize? svg = parsed.$1;
    final int? width = svg?.width?.round();
    final int? height = svg?.height?.round();
    final imagesDao = ref.read(appDatabaseProvider);
    final String mime = 'image/svg+xml';
    final imageId = await imagesDao.into(imagesDao.images).insert(
          ImagesCompanion.insert(
            origSrc: Value(bytes),
            origBytes: Value(bytes.length),
            origWidth: width != null ? Value(width) : const Value.absent(),
            origHeight: height != null ? Value(height) : const Value.absent(),
            mimeType: Value(mime),
          ),
        );
    final int resolvedDpi = 96;
    await imagesDao.customStatement(
      'UPDATE images SET orig_dpi = ?, dpi = ? WHERE id = ?',
      [resolvedDpi, resolvedDpi, imageId],
    );
    final projectService = ref.read(projectServiceProvider);
    await projectService.batchUpdate(
      ref,
      _currentProjectId!,
      imageId: imageId,
    );
    debugPrint('[IconDetail] image stored id=$imageId; updating controllers');
    await imagesDao.customStatement(
      'UPDATE images SET phys_width_px4 = ?, phys_height_px4 = ? WHERE id = ?',
      [width?.toDouble(), height?.toDouble(), imageId],
    );
    ref.invalidate(imagePhysPixelsProvider(imageId));
    _imgCtrl?.applyRemotePx(
        widthPx: width?.toDouble(), heightPx: height?.toDouble());
  }

  (_SvgSize?, String) _parseSvgSize(Uint8List bytes) {
    try {
      final int len = bytes.length < 4096 ? bytes.length : 4096;
      final String head = String.fromCharCodes(bytes.sublist(0, len));
      final RegExp wRe = RegExp(
          r'\bwidth\s*=\s*"([0-9]+(?:\.[0-9]+)?)([a-z%]*)"',
          caseSensitive: false);
      final RegExp hRe = RegExp(
          r'\bheight\s*=\s*"([0-9]+(?:\.[0-9]+)?)([a-z%]*)"',
          caseSensitive: false);
      final RegExp vbRe = RegExp(
          r'\bviewBox\s*=\s*"\s*[-0-9.]+\s+[-0-9.]+\s+([0-9.]+)\s+([0-9.]+)\s*"',
          caseSensitive: false);
      double? w;
      double? h;
      final wM = wRe.firstMatch(head);
      final hM = hRe.firstMatch(head);
      if (wM != null && hM != null) {
        w = double.tryParse(wM.group(1)!);
        h = double.tryParse(hM.group(1)!);
      } else {
        final vb = vbRe.firstMatch(head);
        if (vb != null) {
          w = double.tryParse(vb.group(1)!);
          h = double.tryParse(vb.group(2)!);
        }
      }
      return (_SvgSize(width: w, height: h), head);
    } catch (e) {
      return (null, '');
    }
  }
}

class _SvgSize {
  final double? width;
  final double? height;
  const _SvgSize({this.width, this.height});
}
