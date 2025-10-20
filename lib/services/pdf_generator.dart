import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfVectorObject {
  PdfVectorObject({required this.x, required this.y, required this.color});
  final int x, y;
  final Color color;
}

Future<Uint8List> generateVectorPdf({
  required List<PdfVectorObject> vectorObjects,
  required Size imageSize,
  required double objectOutputSize,
  required double fontSize,
  required bool printCells,
  required bool printBorders,
  required bool printNumbers,
  required Uint8List originalImageData,
  required PdfPageFormat pageFormat,
}) async {
  final pdf = pw.Document();
  final objectSizeInPoints = objectOutputSize * PdfPageFormat.mm;

  pdf.addPage(
    pw.Page(
      pageFormat: pageFormat,
      build: (pw.Context context) {
        final totalDrawingWidth = imageSize.width * objectSizeInPoints;
        final totalDrawingHeight = imageSize.height * objectSizeInPoints;
        final font = PdfFont.helvetica(context.document);
        final uniqueColors = vectorObjects.map((o) => o.color).toSet().toList();

        final content = pw.CustomPaint(
          size: PdfPoint(totalDrawingWidth, totalDrawingHeight),
          painter: (canvas, size) {
            // Layer 1: Draw all cells first to prevent gaps
            if (printCells) {
              for (final obj in vectorObjects) {
                final left = obj.x * objectSizeInPoints;
                final top = (imageSize.height - 1 - obj.y) * objectSizeInPoints;
                final rect =
                    PdfRect(left, top, objectSizeInPoints, objectSizeInPoints);
                final color = PdfColor.fromInt(obj.color.value);

                canvas
                  ..setFillColor(color)
                  ..setStrokeColor(color)
                  ..setLineWidth(0.1) // Hairline stroke
                  ..drawRect(rect.x, rect.y, rect.width, rect.height)
                  ..fillAndStrokePath();
              }
            }

            // Layer 2: Draw all borders on top of the cells
            if (printBorders) {
              for (final obj in vectorObjects) {
                final left = obj.x * objectSizeInPoints;
                final top = (imageSize.height - 1 - obj.y) * objectSizeInPoints;
                final rect =
                    PdfRect(left, top, objectSizeInPoints, objectSizeInPoints);
                canvas
                  ..setStrokeColor(PdfColors.red)
                  ..setLineWidth(0.5)
                  ..drawRect(rect.x, rect.y, rect.width, rect.height)
                  ..strokePath();
              }
            }

            // Layer 3: Draw all numbers on top of everything
            if (printNumbers) {
              for (final obj in vectorObjects) {
                final left = obj.x * objectSizeInPoints;
                final top = (imageSize.height - 1 - obj.y) * objectSizeInPoints;
                final colorIndex = uniqueColors.indexOf(obj.color);
                final text = '${colorIndex + 1}';

                final metrics = font.stringMetrics(text) * fontSize;
                final x = left + (objectSizeInPoints - metrics.width) / 2;
                final y = top + (objectSizeInPoints - metrics.height) / 2;

                canvas
                  ..setFillColor(PdfColors.red)
                  ..drawString(font, fontSize, text, x, y);
              }
            }
          },
        );
        return pw.Center(child: pw.FittedBox(child: content));
      },
    ),
  );

  return pdf.save();
}
