import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../../core/enums/file_type_pdf.dart';
import 'generate_file_view.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? originalPdf;
  File? generatedPdf;

  final List<PdfField> fields = [];

  final GlobalKey _pdfKey = GlobalKey();
  final PdfViewerController _pdfController = PdfViewerController();

  // ================= PICK PDF =================
  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        originalPdf = File(result.files.single.path!);
        generatedPdf = null;
        fields.clear();
      });
    }
  }

  // ================= SIGNATURE =================
  void openSignatureSheet(PdfField field) {
    final controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Draw Signature",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              height: 200,
              color: Colors.grey.shade200,
              child: Signature(controller: controller),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: controller.clear,
                  child: const Text("Clear"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final img = await controller.toPngBytes();
                    if (img != null) {
                      setState(() => field.image = img);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= EDIT FIELD =================
  Future<void> editField(PdfField field) async {
    if (field.type == PdfFieldType.signature) {
      openSignatureSheet(field);
      return;
    }

    if (field.type == PdfFieldType.text) {
      final controller = TextEditingController(text: field.text);
      final value = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Enter Text"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text("OK")),
          ],
        ),
      );
      if (value != null) setState(() => field.text = value);
    }

    if (field.type == PdfFieldType.checkbox) {
      setState(() => field.checked = !field.checked);
    }


    if (field.type == PdfFieldType.datetime) {
      final date = await showDatePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        initialDate: DateTime.now(),
      );
      if (date != null) {
        setState(() {
          field.text = date.toString().split(' ').first;
        });
      }
    }
  }

  // ================= GENERATE PDF =================
  // ================= GENERATE PDF =================
  Future<void> generatePdf() async {
    if (originalPdf == null) return;

    final bytes = await originalPdf!.readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    final page = document.pages[0];

    final pdfWidth = page.size.width;
    final pdfHeight = page.size.height;

    // Get the Stack render box to know screen size
    final renderBox = _pdfKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final viewWidth = renderBox.size.width;
    final viewHeight = renderBox.size.height;

    // Scale factors to map Stack (screen) coordinates to PDF coordinates
    final xScale = pdfWidth / viewWidth;
    final yScale = pdfHeight / viewHeight;

    for (final field in fields) {
      // Map screen coordinates to PDF coordinates
      final dx = field.position.dx * xScale;
      final dy = field.position.dy * yScale;

      switch (field.type) {
        case PdfFieldType.signature:
          if (field.image != null) {
            // Draw signature with proportional size
            page.graphics.drawImage(
              PdfBitmap(field.image!),
              Rect.fromLTWH(dx, dy, 120 * xScale, 50 * yScale),
            );
          }
          break;

        case PdfFieldType.text:
        case PdfFieldType.datetime:
          page.graphics.drawString(
            field.text ?? "",
            PdfStandardFont(PdfFontFamily.helvetica, 12 * ((xScale + yScale) / 2)),
            brush: PdfBrushes.black,
            bounds: Rect.fromLTWH(dx, dy, 200 * xScale, 30 * yScale),
          );
          break;

        case PdfFieldType.checkbox:
        // Adjust box size proportional to PDF
          final boxSize = 25.0 * ((xScale + yScale) / 2);

          final rect = Rect.fromLTWH(dx, dy, boxSize, boxSize);

          // Draw Box
          page.graphics.drawRectangle(
            bounds: rect,
            pen: PdfPen(PdfColor(0, 0, 0)),
          );

          if (field.checked) {
            // Draw Checkmark
            final pen = PdfPen(PdfColor(0, 0, 0), width: 2 * ((xScale + yScale) / 2));
            final p1 = Offset(rect.left + 0.2 * boxSize, rect.top + 0.5 * boxSize);
            final p2 = Offset(rect.left + 0.45 * boxSize, rect.top + 0.8 * boxSize);
            final p3 = Offset(rect.left + 0.8 * boxSize, rect.top + 0.2 * boxSize);

            page.graphics.drawLine(pen, p1, p2);
            page.graphics.drawLine(pen, p2, p3);
          }
          break;
      }
    }


    // Save PDF
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/signed_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await document.save());
    document.dispose();

// 👉 Navigate to generated pdf page
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GeneratedPdfScreen(pdfFile: file),
      ),
    );

// Clear editor
    setState(() {
      fields.clear();
    });

  }


  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Editor"),
        actions: [
          TextButton(onPressed: pickPdf, child: const Text("Add PDF")),
          TextButton(onPressed: generatePdf, child: const Text("Generate")),
        ],
      ),
      body: originalPdf == null
          ? Center(
        child: ElevatedButton(
          onPressed: pickPdf,
          child: const Text("Pick PDF"),
        ),
      )
          : Column(
        children: [
          Wrap(
            spacing: 8,
            children: [
              _addBtn("Sign", PdfFieldType.signature),
              _addBtn("Text", PdfFieldType.text),
              _addBtn("Checkbox", PdfFieldType.checkbox),
              _addBtn("Date", PdfFieldType.datetime),
            ],
          ),
          const Divider(),
          Expanded(
            child: Stack(
              children: [
                SfPdfViewer.file(
                  generatedPdf ?? originalPdf!,
                  key: _pdfKey,
                  controller: _pdfController,
                ),
                ...fields.map(
                      (field) => Positioned(
                    left: field.position.dx,
                    top: field.position.dy,
                    child: _fieldWidget(field),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================
  Widget _addBtn(String title, PdfFieldType type) {
    return TextButton(
      onPressed: () {
        setState(() {
          fields.add(
            PdfField(
              type: type,
              position: const Offset(100, 200),
              text: type == PdfFieldType.datetime
                  ? DateTime.now().toString().split(' ').first
                  : "",
            ),
          );
        });
      },
      child: Text(title),
    );
  }

  Widget _fieldWidget(PdfField field) {
    double width = 180;
    double height = 60;

    if (field.type == PdfFieldType.checkbox) {
      width = 40;
      height = 40;
    }

    return GestureDetector(
      onTap: () => editField(field),
      onPanUpdate: (d) {
        setState(() {
          field.position += d.delta;
        });
      },
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          color: Colors.white.withOpacity(0.85),
        ),
        child: _fieldContent(field),
      ),
    );
  }

  Widget _fieldContent(PdfField field) {
    switch (field.type) {
      case PdfFieldType.signature:
        return field.image == null
            ? const Text("Tap to Sign")
            : Image.memory(field.image!, fit: BoxFit.contain);
      case PdfFieldType.text:
      case PdfFieldType.datetime:
        return Text(field.text ?? "");
      case PdfFieldType.checkbox:
        return Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: field.checked ? Colors.blue : Colors.white,
          ),
          child: field.checked
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : null,
        );
    }
  }
}

// ================= FIELD MODEL =================

class PdfField {
  PdfField({
    required this.type,
    required this.position,
    this.text,
    this.checked = false,
    this.image,
  });

  PdfFieldType type;
  Offset position; // position inside pdf page (viewer space)
  String? text;
  bool checked;
  Uint8List? image;
}
