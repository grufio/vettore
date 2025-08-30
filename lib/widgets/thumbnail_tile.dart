import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:vettore/theme/app_theme_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vettore/theme/app_theme_typography.dart';

class ThumbnailTile extends StatelessWidget {
  final Uint8List? imageBytes;
  final double footerHeight;
  final List<String> lines; // expect up to 3 lines
  final double textPadding; // padding inside text area
  final double lineSpacing;
  final BorderRadius borderRadius;
  final Widget? leading; // optional icon

  const ThumbnailTile({
    super.key,
    this.imageBytes,
    this.footerHeight = 72.0,
    this.lines = const ['', '', ''],
    this.textPadding = 12.0,
    this.lineSpacing = 12.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(6.0)),
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: kBordersColor, width: 1.0),
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image preview uses available space above; ratio for consistent height
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                color: kGrey20,
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
    final List<String> _lines = (lines.length >= 3)
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
                        _lines[0],
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
                        _lines[1],
                        style: appTextStyles.bodyM.copyWith(color: kGrey100),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      height: 18.0,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _lines[2],
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
