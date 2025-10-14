import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vettore/providers/image_providers.dart';
import 'package:vettore/providers/image_spec_providers.dart';
import 'package:vettore/providers/project_provider.dart';
import 'package:vettore/providers/application_providers.dart';
import 'package:vettore/services/image_detail_controller.dart';
import 'package:vettore/widgets/image_dimension_panel.dart';

class ImageDimensionsSection extends ConsumerWidget {
  final int projectId;
  final TextEditingController widthTextController;
  final TextEditingController heightTextController;
  final ImageDetailController imgCtrl;
  final bool linkWH;
  final ValueChanged<bool> onLinkChanged;
  final String interpolation;
  final ValueChanged<String> onInterpolationChanged;
  final VoidCallback onResizeTap;

  const ImageDimensionsSection({
    super.key,
    required this.projectId,
    required this.widthTextController,
    required this.heightTextController,
    required this.imgCtrl,
    required this.linkWH,
    required this.onLinkChanged,
    required this.interpolation,
    required this.onInterpolationChanged,
    required this.onResizeTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? imageId = ref.watch(imageIdStableProvider(projectId));
    final bool hasImage = imageId != null;

    // Ensure unit controllers reflect persisted selection (per project)
    final String wPref = ref.watch(imageWidthUnitProvider(projectId));
    final String hPref = ref.watch(imageHeightUnitProvider(projectId));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      imgCtrl.setUnits(widthUnit: wPref, heightUnit: hPref);
      imgCtrl.onWidthUnitChanged = (u) {
        ref.read(imageWidthUnitProvider(projectId).notifier).state = u;
      };
      imgCtrl.onHeightUnitChanged = (u) {
        ref.read(imageHeightUnitProvider(projectId).notifier).state = u;
      };
    });

    final int? dpiVal = (imageId != null)
        ? ref.watch(imageDpiProvider(imageId).select((a) => a.asData?.value))
        : null;
    final int currentDpi = dpiVal ?? 96;

    return ImageDimensionPanel(
      widthTextController: widthTextController,
      heightTextController: heightTextController,
      widthValueController: imgCtrl.widthVC,
      heightValueController: imgCtrl.heightVC,
      enabled: hasImage,
      initialLinked: linkWH,
      onLinkChanged: onLinkChanged,
      initialWidthUnit: wPref,
      initialHeightUnit: hPref,
      onWidthUnitChanged: (u) => imgCtrl.handleWidthUnitChange(u),
      onHeightUnitChanged: (u) => imgCtrl.handleHeightUnitChange(u),
      currentDpi: currentDpi,
      onDpiChanged: (newDpi) async {
        if (imageId == null) return;
        final db = ref.read(appDatabaseProvider);
        await db.customStatement(
          'UPDATE images SET dpi = ? WHERE id = ?',
          [newDpi, imageId],
        );
        // Update controllers immediately to keep conversions consistent
        imgCtrl.setUiDpi(newDpi);
        ref.invalidate(imageDpiProvider(imageId));
      },
      interpolation: interpolation,
      onInterpolationChanged: onInterpolationChanged,
      onResizeTap: onResizeTap,
    );
  }
}
