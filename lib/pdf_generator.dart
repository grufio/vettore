import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:vettore/models/vector_object_model.dart';

Future<void> generateVectorPdf({
  required List<VectorObject> vectorObjects,
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
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.red, width: 0.5),
                columnWidths: {
                  for (var i = 0; i < imageSize.width; i++)
                    i: pw.FixedColumnWidth(objectSizeInPoints),
                },
                children: List.generate(
                  imageSize.height.toInt(),
                  (y) => pw.TableRow(
                    children: List.generate(imageSize.width.toInt(), (x) {
                      final index = y * imageSize.width.toInt() + x;
                      if (index >= vectorObjects.length) return pw.Container();
                      final obj = vectorObjects[index];
                      return pw.Container(
                        height: objectSizeInPoints,
                        color: printBackground
                            ? PdfColor.fromInt(obj.color.value)
                            : null,
                        child: pw.Center(
                          child: pw.Text(
                            obj.colorIndex.toString(),
                            style: pw.TextStyle(
                              color: PdfColors.red,
                              fontSize: fontSize,
                            ),
                          ),
                        ),
                      );
                    }),
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
