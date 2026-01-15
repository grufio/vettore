import 'package:flutter/widgets.dart';
import 'package:grufio/services/image_detail_controller.dart';
import 'package:grufio/widgets/image_dimensions_section.dart';
import 'package:grufio/widgets/side_panel.dart';

class ImageDetailRightPanel extends StatelessWidget {
  const ImageDetailRightPanel({
    super.key,
    required this.width,
    required this.onResize,
    required this.onReset,
    required this.child,
  });

  final double width;
  final ValueChanged<double> onResize;
  final VoidCallback onReset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SidePanel(
      side: SidePanelSide.right,
      width: width,
      topPadding: 0.0,
      resizable: true,
      minWidth: 200.0,
      onResizeDelta: onResize,
      onResetWidth: onReset,
      child: child,
    );
  }
}

class ImageDetailDimensions extends StatelessWidget {
  const ImageDetailDimensions({
    super.key,
    required this.projectId,
    required this.widthController,
    required this.heightController,
    required this.controller,
    required this.linkWH,
    required this.onLinkChanged,
    required this.interpolation,
    required this.onInterpolationChanged,
    required this.onResizeTap,
  });

  final int projectId;
  final TextEditingController widthController;
  final TextEditingController heightController;
  final ImageDetailController controller;
  final bool linkWH;
  final ValueChanged<bool> onLinkChanged;
  final String interpolation;
  final ValueChanged<String> onInterpolationChanged;
  final Future<void> Function() onResizeTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ImageDimensionsSection(
          projectId: projectId,
          widthTextController: widthController,
          heightTextController: heightController,
          imgCtrl: controller,
          linkWH: linkWH,
          onLinkChanged: onLinkChanged,
          interpolation: interpolation,
          onInterpolationChanged: onInterpolationChanged,
          onResizeTap: onResizeTap,
        ),
        const Expanded(child: SizedBox.shrink()),
      ],
    );
  }
}
