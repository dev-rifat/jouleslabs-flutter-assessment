import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:assessment/features/document/domain/models/document_field.dart';
import 'package:printing/printing.dart';

class PdfService {
  static Future<File> generateSignedPdf(
    File originalFile, 
    List<DocumentField> fields, 
    ui.Size viewSize,
    ui.Offset scrollOffset,
    double zoomLevel,
  ) async {
    final pdf = pw.Document();
    final originalBytes = await originalFile.readAsBytes();

    // Load all pages
    final pages = await Printing.raster(originalBytes, dpi: 72).toList();
    
    double accumulatedHeight = 0;

    for (int i = 0; i < pages.length; i++) {
      final page = pages[i];
      final image = await page.toPng();
      final pdfImage = pw.MemoryImage(image);
      
      final pdfPageWidth = page.width.toDouble();
      final pdfPageHeight = page.height.toDouble();

      // Updated scale logic to account for zoom
      final double scale = (viewSize.width > 0 && zoomLevel > 0) 
          ? pdfPageWidth / (viewSize.width * zoomLevel) 
          : 1.0;

      final pageTop = accumulatedHeight;
      final pageBottom = accumulatedHeight + pdfPageHeight;

      // Permissive filtering with generous margin
      final pageFields = fields.where((field) {
        final fieldTop = (field.y + scrollOffset.dy) * scale;
        final fieldBottom = fieldTop + (field.height * scale);
        
        return fieldBottom > (pageTop - 100) && fieldTop < (pageBottom + 100);
      }).toList();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(pdfPageWidth, pdfPageHeight),
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                pw.Image(pdfImage, fit: pw.BoxFit.fill),
                ...pageFields.map((field) {
                  final fieldGlobalY = (field.y + scrollOffset.dy) * scale;
                  final localY = fieldGlobalY - accumulatedHeight;

                  return pw.Positioned(
                    left: (field.x + scrollOffset.dx) * scale,
                    top: localY,
                    child: pw.SizedBox(
                      width: field.width * scale,
                      height: field.height * scale,
                      child: _buildPdfFieldContent(field),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      );
      
      accumulatedHeight += pdfPageHeight;
    }

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/signed_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildPdfFieldContent(DocumentField field) {
    if (field.type == FieldType.signature && field.value != null) {
      try {
        final Uint8List bytes = base64Decode(field.value!);
        return pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain);
      } catch (e) {
        // Fallback text to debug if signature image fails to render
        return pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.red, width: 2),
          ),
          child: pw.Center(child: pw.Text('Signature Error', style: const pw.TextStyle(color: PdfColors.red))),
        );
      }
    }

    return pw.Container(
      alignment: pw.Alignment.centerLeft,
      child: pw.Text(
        field.value ?? '',
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
    );
  }
}
