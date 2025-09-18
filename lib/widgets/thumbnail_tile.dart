import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vettore/theme/app_theme_typography.dart';

class ThumbnailTile extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? assetPath; // optional asset image path
  final Color? backgroundFill; // when no image, fill with solid color
  final double footerHeight;
  final List<String> lines; // expect up to 3 lines
  final double textPadding; // padding inside text area
  final double lineSpacing;
  final BorderRadius borderRadius;
  final Widget? leading; // optional icon
  final double borderWidth;
  final Color borderColor;

  const ThumbnailTile({
    super.key,
    this.imageBytes,
    this.assetPath,
    this.backgroundFill,
    this.footerHeight = 72.0,
    this.lines = const ['', '', ''],
    this.textPadding = 12.0,
    this.lineSpacing = 12.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(6.0)),
    this.leading,
    this.borderWidth = 2.0,
    this.borderColor = kBordersColor,
  });

  @override
  Widget build(BuildContext context) {
    // Keep inner clip radius aligned to the inner edge of the stroke so
    // the thumbnail edge and the border edge visually match for any border width.
    final double outerRadius = borderRadius.topLeft.x;
    final double innerRadius =
        (outerRadius - borderWidth).clamp(0.0, outerRadius);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(innerRadius)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image preview uses available space above; ratio for consistent height
            AspectRatio(
              aspectRatio: 4 / 3,
              child: (assetPath != null)
                  ? Image.asset(
                      assetPath!,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.none,
                    )
                  : (imageBytes != null && imageBytes!.isNotEmpty)
                      ? Image.memory(
                          imageBytes!,
                          fit: BoxFit.cover, // fill area (cover)
                          filterQuality: FilterQuality.none,
                        )
                      : (backgroundFill != null)
                          ? Container(color: backgroundFill)
                          : Container(
                              color: kGrey20,
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/icons/32/no-image.svg',
                                  width: 24,
                                  height: 24,
                                  colorFilter: const ColorFilter.mode(
                                      kGrey70, BlendMode.srcIn),
                                ),
                              ),
                            ),
            ),
            _Footer(
              height: footerHeight,
              lines: lines,
              padding: textPadding,
              spacing: lineSpacing,
              leading: leading,
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final double height;
  final List<String> lines;
  final double padding;
  final double spacing;
  final Widget? leading;

  const _Footer({
    required this.height,
    required this.lines,
    required this.padding,
    required this.spacing,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> normalizedLines = (this.lines.length >= 3)
        ? this.lines.sublist(0, 3)
        : [...this.lines, ...List.filled(3 - this.lines.length, '')];

    return Container(
      height: height,
      color: kWhite,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon area takes full height
            SizedBox(
              width: 20.0,
              child: Center(
                child: leading ??
                    SvgPicture.asset(
                      'assets/icons/32/image.svg',
                      width: 20,
                      height: 20,
                      colorFilter:
                          const ColorFilter.mode(kGrey100, BlendMode.srcIn),
                    ),
              ),
            ),
            const SizedBox(width: 12.0),
            // Text area without inner padding; spacing and fixed line heights
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 18.0,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        normalizedLines[0],
                        style: appTextStyles.bodyM.copyWith(
                          color: kGrey100,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      height: 18.0,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        normalizedLines[1],
                        style: appTextStyles.bodyM.copyWith(color: kGrey100),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      height: 18.0,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        normalizedLines[2],
                        style: appTextStyles.bodyM.copyWith(color: kGrey100),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
