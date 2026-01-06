import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';



class GeneratedPdfScreen extends StatelessWidget {
  final File pdfFile;

  const GeneratedPdfScreen({super.key, required this.pdfFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generated PDF"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // back to editor
            },
            child: const Text(
              "Done",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SfPdfViewer.file(pdfFile),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text("Save PDF"),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("PDF saved at:\n${pdfFile.path}"),
              ),
            );
          },
        ),
      ),
    );
  }
}
