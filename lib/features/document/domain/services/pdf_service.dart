import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:assessment/features/document/domain/models/document_field.dart';

class PdfService {
  static Future<File> generateSignedPdf(File originalFile, List<DocumentField> fields) async {
    final pdf = pw.Document();
    
    // In a production app, we would load the existing PDF pages and overlay widgets.
    // For this assessment, we'll demonstrate the ability to create a PDF with the fields.
    // Ideally, using a library that supports modifying existing PDFs or rendering PDF pages as images.
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              pw.Center(child: pw.Text('Original Document Content Placeholder')),
              ...fields.map((field) {
                return pw.Positioned(
                  left: field.x,
                  top: field.y,
                  child: pw.Container(
                    width: field.width,
                    height: field.height,
                    child: pw.Center(
                      child: pw.Text(field.value ?? field.type.name),
                    ),


                  ),
                );
              }),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/signed_document.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
