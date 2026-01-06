import 'dart:io';
import 'dart:typed_data';
import 'package:assessment/core/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';


class GeneratedPdfScreen extends StatefulWidget {
  final File? file;
  final Uint8List? bytes;

  const GeneratedPdfScreen({super.key, this.file, this.bytes});

  @override
  State<GeneratedPdfScreen> createState() => _GeneratedPdfScreenState();
}

class _GeneratedPdfScreenState extends State<GeneratedPdfScreen> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();

    // Auto save when screen loads (only preview case)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.bytes != null && widget.file == null) {
        _saveAndNavigate();
      }
    });
  }

  Future<void> _saveAndNavigate() async {
    if (_isSaved || widget.bytes == null) return;
    _isSaved = true;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'signed_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final savedFile = File('${dir.path}/$fileName');

      await savedFile.writeAsBytes(widget.bytes!);

      if (mounted) {
        // Go back to the first route (Home Screen)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving PDF: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPreview = widget.file == null && widget.bytes != null;

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,

        title: Text(isPreview ? "Saving PDF..." : "View Document"),
        automaticallyImplyLeading: !isPreview,
      ),
      body: widget.file != null
          ? SfPdfViewer.file(widget.file!,)
          : (widget.bytes != null
          ? SfPdfViewer.memory(widget.bytes!)
          : const Center(child: Text("No PDF data"))),
    );
  }
}
