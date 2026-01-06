import '../../../domain/models/document_model.dart';
import '/features/document/document_exports.dart';

class GeneratedFileScreen extends StatefulWidget {
  final File? file;
  final Uint8List? bytes;

  const GeneratedFileScreen({super.key, this.file, this.bytes});

  @override
  State<GeneratedFileScreen> createState() => _GeneratedFileScreenState();
}

class _GeneratedFileScreenState extends State<GeneratedFileScreen> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    // Auto-save if previewing bytes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.bytes != null && widget.file == null) _saveAndNavigate();
    });
  }



  @override
  Widget build(BuildContext context) {
    final isPreview = widget.file == null && widget.bytes != null;

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
        title: Text(isPreview ? "Saving Document..." : "View Document"),
        automaticallyImplyLeading: !isPreview,
      ),
      body: widget.file != null
          ? SfPdfViewer.file(widget.file!)
          : (widget.bytes != null
          ? SfPdfViewer.memory(widget.bytes!)
          : const Center(child: Text("No document"))),
    );
  }


  Future<void> _saveAndNavigate() async {
    if (_isSaved || widget.bytes == null) return;
    _isSaved = true;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.pdf';
      final savedFile = File('${dir.path}/$fileName');

      await savedFile.writeAsBytes(widget.bytes!);

      // Save metadata in Hive
      final box = Hive.box<DocumentModel>('documents');
      await box.add(DocumentModel(
        id: const Uuid().v4(),
        name: fileName,
        path: savedFile.path,
        createdAt: DateTime.now(),
      ));

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("File saved")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error saving PDF: $e")));
      }
    }
  }
}
