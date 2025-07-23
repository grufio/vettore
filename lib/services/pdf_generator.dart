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

        final content = pw.SizedBox(
          width: totalDrawingWidth,
          height: totalDrawingHeight,
          child: pw.Stack(
            children: [
              // Draw the colored squares and numbers
              ...() {
                final uniqueColors =
                    vectorObjects.map((o) => o.color).toSet().toList();
                return vectorObjects.map(
                  (obj) {
                    final colorIndex = uniqueColors.indexOf(obj.color);
                    return pw.Positioned(
                      left: obj.x * objectSizeInPoints,
                      top: obj.y * objectSizeInPoints,
                      child: pw.SizedBox(
                        width: objectSizeInPoints,
                        height: objectSizeInPoints,
                        child: pw.Stack(
                          alignment: pw.Alignment.center,
                          children: [
                            if (printCells)
                              pw.Container(
                                color: PdfColor.fromInt(obj.color.value),
                              ),
                            if (printBorders)
                              pw.Container(
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                    color: PdfColors.red,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                            if (printNumbers)
                              pw.Text(
                                '${colorIndex + 1}',
                                style: pw.TextStyle(
                                  color: PdfColors.red,
                                  fontSize: fontSize,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }(),
            ],
          ),
        );

        return pw.Center(child: content);
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
