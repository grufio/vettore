import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/widgets/input_value_type/dropdown_item.dart';

const double kDropdownItemHeight = 24.0;
const double kDropdownPanelWidth = 120.0;

OverlayEntry createDropdownOverlay({
  required BuildContext context,
  required LayerLink layerLink,
  required GlobalKey targetKey,
  required List<String> items,
  required String? selectedValue,
  required bool isValueDropdownVariant,
  required ValueChanged<String> onItemSelected,
  required VoidCallback onDismiss,
  double panelWidth = kDropdownPanelWidth,
  ValueListenable<int?>? highlightedIndexListenable,
  ScrollController? listScrollController,
  VoidCallback? onHighlightNext,
  VoidCallback? onHighlightPrev,
  VoidCallback? onHighlightHome,
  VoidCallback? onHighlightEnd,
  VoidCallback? onConfirm,
  VoidCallback? onEscape,
  Offset? centerGlobal,
  FocusNode? focusNode,
}) {
  final Size screenSize = MediaQuery.of(context).size;
  double offsetY = 24;
  double offsetX = 0;
  const double itemHeight = kDropdownItemHeight;
  const int maxVisible = 8;
  final int visibleCount =
      items.length < maxVisible ? items.length : maxVisible;
  final double estimatedPanelHeight = 8 + (visibleCount * itemHeight) + 8;
  final RenderBox? targetBox =
      targetKey.currentContext?.findRenderObject() as RenderBox?;
  if (targetBox != null) {
    final Offset targetTopLeft = targetBox.localToGlobal(Offset.zero);
    if (centerGlobal != null) {
      // Center around click position, clamped to screen bounds
      double desiredLeft = centerGlobal.dx - (panelWidth / 2);
      double desiredTop = centerGlobal.dy - (estimatedPanelHeight / 2);
      desiredLeft = desiredLeft.clamp(0.0, screenSize.width - panelWidth);
      desiredTop =
          desiredTop.clamp(0.0, screenSize.height - estimatedPanelHeight);
      offsetX = desiredLeft - targetTopLeft.dx;
      offsetY = desiredTop - targetTopLeft.dy;
    } else {
      final double targetBottom = targetTopLeft.dy + targetBox.size.height;
      final double spaceBelow = screenSize.height - targetBottom;
      if (spaceBelow < estimatedPanelHeight + 8) {
        offsetY = -(estimatedPanelHeight + 4);
      }
      offsetX = 0;
    }
  }

  return OverlayEntry(
    builder: (context) {
      return Positioned.fill(
        child: Stack(
          children: [
            GestureDetector(onTap: onDismiss, behavior: HitTestBehavior.opaque),
            CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              offset: Offset(offsetX, offsetY),
              child: Semantics(
                container: true,
                label: 'Options',
                child: Focus(
                  focusNode: focusNode,
                  autofocus: true,
                  onKeyEvent: (node, event) {
                    // Handle both initial down and repeats
                    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
                      return KeyEventResult.ignored;
                    }
                    final key = event.logicalKey;
                    if (key == LogicalKeyboardKey.arrowDown) {
                      onHighlightNext?.call();
                      return KeyEventResult.handled;
                    }
                    if (key == LogicalKeyboardKey.arrowUp) {
                      onHighlightPrev?.call();
                      return KeyEventResult.handled;
                    }
                    if (key == LogicalKeyboardKey.home) {
                      onHighlightHome?.call();
                      return KeyEventResult.handled;
                    }
                    if (key == LogicalKeyboardKey.end) {
                      onHighlightEnd?.call();
                      return KeyEventResult.handled;
                    }
                    if (key == LogicalKeyboardKey.enter ||
                        key == LogicalKeyboardKey.numpadEnter) {
                      onConfirm?.call();
                      return KeyEventResult.handled;
                    }
                    if (key == LogicalKeyboardKey.escape) {
                      onEscape?.call();
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: SizedBox(
                    width: panelWidth,
                    child: Container(
                      constraints:
                          BoxConstraints(maxHeight: estimatedPanelHeight),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: kGrey100,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: highlightedIndexListenable == null
                          ? ListView.builder(
                              controller: listScrollController,
                              physics: const ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final value = items[index];
                                final bool isSelected = value == selectedValue;
                                return DropdownItem(
                                  label: value,
                                  isSelected: isSelected,
                                  highlighted: false,
                                  onHover: () {},
                                  onTap: () {
                                    onItemSelected(value);
                                    onDismiss();
                                  },
                                );
                              },
                            )
                          : ValueListenableBuilder<int?>(
                              valueListenable: highlightedIndexListenable,
                              builder: (context, hi, _) {
                                return ListView.builder(
                                  controller: listScrollController,
                                  physics: const ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    final value = items[index];
                                    final bool isSelected =
                                        value == selectedValue;
                                    final bool isHighlighted = hi == index;
                                    return DropdownItem(
                                      label: value,
                                      isSelected: isSelected,
                                      highlighted: isHighlighted,
                                      onHover: () {},
                                      onTap: () {
                                        onItemSelected(value);
                                        onDismiss();
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void removeDropdownOverlay(OverlayEntry? entry) {
  entry?.remove();
}
