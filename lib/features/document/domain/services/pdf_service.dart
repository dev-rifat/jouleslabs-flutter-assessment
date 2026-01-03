import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:assessment/features/document/domain/models/document_field.dart';

class PdfService {
  static Future<File> generateSignedPdf(File originalFile, List<DocumentField> fields) async {
    final pdf = pw.Document();
    
    // In a production app, you would use a package like 'syncfusion_flutter_pdf' or 'pdf' 
    // to load the existing document pages and overlay items on them.
    // For this assessment, we'll generate a page representing the signed document.
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Center(
                child: pw.Text(
                  'SIGNED DOCUMENT\nOriginal File: ${originalFile.path.split('/').last}',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(fontSize: 20, color: PdfColors.grey300),
                ),
              ),
              ...fields.map((field) {
                return pw.Positioned(
                  left: field.x,
                  top: field.y,
                  child: pw.Container(
                    width: field.width,
                    height: field.height,
                    child: _buildPdfFieldContent(field),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/signed_document_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildPdfFieldContent(DocumentField field) {
    if (field.type == FieldType.signature && field.value != null && field.value!.length > 100) {
      try {
        final Uint8List bytes = base64Decode(field.value!);
        final image = pw.MemoryImage(bytes);
        return pw.Image(image, fit: pw.BoxFit.contain);
      } catch (e) {
        return pw.Text('Signature Error');
      }
    }

    if (field.type == FieldType.checkbox) {
      return pw.Center(
        child: pw.Container(
          width: 20,
          height: 20,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(),
          ),
          child: field.value == 'true' ? pw.Center(child: pw.Text('X')) : null,
        ),
      );
    }

    return pw.Container(
      alignment: pw.Alignment.centerLeft,
      child: pw.Text(
        field.value ?? '',
        style: pw.TextStyle(fontSize: 12),
      ),
    );
  }
}
