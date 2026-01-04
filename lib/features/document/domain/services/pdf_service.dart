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
    
    // For this assessment, we generate a PDF page with the placed signatures/fields.
    // In a full implementation, you would use a library to overlay these on the original PDF bytes.
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              ...fields.map((field) {
                return pw.Positioned(
                  left: field.x,
                  top: field.y,
                  child: pw.SizedBox(
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
        return pw.Text('[Signature]');
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
