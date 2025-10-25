import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:vettore/icons/grufio_icons.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:vettore/theme/app_theme_typography.dart';

class ThumbnailTile extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: borderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image preview uses available space above; ratio for consistent height
            AspectRatio(
              aspectRatio: 4 / 3,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double logicalWidth = constraints.maxWidth;
                  final double logicalHeight = logicalWidth * 0.75;
                  final double dpr = MediaQuery.of(context).devicePixelRatio;
                  final int cacheW = (logicalWidth * dpr).round();
                  final int cacheH = (logicalHeight * dpr).round();

                  if (assetPath != null) {
                    return Image.asset(
                      assetPath!,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.none,
                      cacheWidth: cacheW,
                      cacheHeight: cacheH,
                    );
                  }
                  if (imageBytes != null && imageBytes!.isNotEmpty) {
                    return Image.memory(
                      imageBytes!,
                      fit: BoxFit.cover, // fill area (cover)
                      filterQuality: FilterQuality.none,
                      cacheWidth: cacheW,
                      cacheHeight: cacheH,
                    );
                  }
                  if (backgroundFill != null) {
                    return Container(color: backgroundFill);
                  }
                  return const ColoredBox(
                    color: kGrey20,
                    child: Center(
                      child: Icon(Grufio.noImage, size: 24, color: kGrey70),
                    ),
                  );
                },
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
  const _Footer({
    required this.height,
    required this.lines,
    required this.padding,
    required this.spacing,
    this.leading,
  });
  final double height;
  final List<String> lines;
  final double padding;
  final double spacing;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final List<String> normalizedLines = (lines.length >= 3)
        ? lines.sublist(0, 3)
        : [...lines, ...List.filled(3 - lines.length, '')];

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
                    const Icon(Grufio.image, size: 20, color: kGrey100),
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
