import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfVectorObject {
  final int x, y;
  final Color color;
  PdfVectorObject({required this.x, required this.y, required this.color});
}

Future<void> generateVectorPdf({
  required List<PdfVectorObject> vectorObjects,
  required Size imageSize,
  required double objectOutputSize,
  required double fontSize,
  required bool printBackground,
  required Uint8List originalImageData,
  required PdfPageFormat pageFormat,
  required bool centerImage,
  required double outputBorders,
}) async {
  final pdf = pw.Document();
  final objectSizeInPoints = objectOutputSize * PdfPageFormat.mm;
  final margin = outputBorders * PdfPageFormat.mm;

  pdf.addPage(
    pw.Page(
      pageFormat: pageFormat,
      margin: pw.EdgeInsets.all(margin),
      build: (pw.Context context) {
        final totalDrawingWidth = imageSize.width * objectSizeInPoints;
        final totalDrawingHeight = imageSize.height * objectSizeInPoints;

        final content = pw.SizedBox(
          width: totalDrawingWidth,
          height: totalDrawingHeight,
          child: pw.Stack(
            children: [
              if (printBackground)
                pw.Image(
                  pw.MemoryImage(originalImageData),
                  fit: pw.BoxFit.fill,
                ),
              // Draw the colored squares
              ...vectorObjects.map(
                (obj) => pw.Positioned(
                  left: obj.x * objectSizeInPoints,
                  top: obj.y * objectSizeInPoints,
                  child: pw.Container(
                    width: objectSizeInPoints,
                    height: objectSizeInPoints,
                    color: PdfColor.fromInt(obj.color.value),
                  ),
                ),
              ),
              // Draw the grid on top
              pw.GridView(
                crossAxisCount: imageSize.width.toInt(),
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
                childAspectRatio: 1.0,
                children: List.generate(
                  (imageSize.width * imageSize.height).toInt(),
                  (index) => pw.Container(
                    width: objectSizeInPoints,
                    height: objectSizeInPoints,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        color: PdfColors.grey500,
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

        if (centerImage) {
          return pw.Center(child: content);
        }
        return content;
      },
    ),
  );
  try {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/vettore_output.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  } catch (e) {
    // Handle error
    debugPrint('Error generating or opening PDF: $e');
  }
}
