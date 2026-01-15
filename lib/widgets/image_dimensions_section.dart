import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grufio/providers/application_providers.dart';
import 'package:grufio/providers/image_providers.dart';
import 'package:grufio/providers/image_spec_providers.dart';
import 'package:grufio/providers/project_image_providers.dart';
import 'package:grufio/services/image_detail_controller.dart';
import 'package:grufio/widgets/image_dimension_panel.dart';

class ImageDimensionsSection extends ConsumerWidget {
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
  final int projectId;
  final TextEditingController widthTextController;
  final TextEditingController heightTextController;
  final ImageDetailController imgCtrl;
  final bool linkWH;
  final ValueChanged<bool> onLinkChanged;
  final String interpolation;
  final ValueChanged<String> onInterpolationChanged;
  final VoidCallback onResizeTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? imageId = ref.watch(projectImageIdProvider(projectId)).value;
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
        // Keep existing phys values, only update dpi
        final (double?, double?) phys =
            await ref.read(imagePhysPixelsProvider(imageId).future);
        await ref
            .read(imageRepositoryPgProvider)
            .setDpiAndPhys(imageId, newDpi, phys.$1, phys.$2);
        imgCtrl.setUiDpi(newDpi);
        ref.invalidate(imageDpiProvider(imageId));
      },
      interpolation: interpolation,
      onInterpolationChanged: onInterpolationChanged,
      onResizeTap: onResizeTap,
    );
  }
}
