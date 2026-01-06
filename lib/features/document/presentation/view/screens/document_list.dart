import 'package:assessment/features/document/domain/models/document_model.dart';
import 'document_editor_screen.dart';
import 'generate_file_view.dart';
import '/features/document/document_exports.dart';


class DocumentsList extends StatefulWidget {
  const DocumentsList({super.key});

  @override
  State<DocumentsList> createState() => _DocumentsListState();
}

class _DocumentsListState extends State<DocumentsList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: _appbar,
      body: ValueListenableBuilder<Box<DocumentModel>>(
        valueListenable: Hive.box<DocumentModel>('documents').listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) return _emptyView();

          final documents = box.values.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return _documentsList(documents);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickDocument,
        backgroundColor: AppColor.backgroundColor,
        icon: const Icon(Icons.add, color: AppColor.normalTextColor),
        label: const Text(
          'Add Document',
          style: TextStyle(color: AppColor.normalTextColor),
        ),
      ),
    );
  }

  /// Pick a PDF file and open editor
  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    final path = result?.files.single.path;
    if (path == null || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentEditorScreen(initialFile: File(path)),
      ),
    );
  }

  /// Open a PDF file in viewer
  void _openFile(DocumentModel doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GeneratedFileScreen(file: File(doc.path)),
      ),
    );
  }

  /// Build list of documents
  Widget _documentsList(List<DocumentModel> docs) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final doc = docs[index];
        return Card(
          color: AppColor.disableColor.withAlpha(77), // 0.3 opacity
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          child: ListTile(
            leading: const Icon(
              Icons.file_present_outlined,
              color: AppColor.primaryColor,
            ),
            title: Text(doc.name),
            subtitle: Text(
              DateFormatHelper.formatDate(
                date: doc.createdAt.toLocal().toString(),
                format: "dd MMM yy  h:mm a",
              ),
            ),
            onTap: () => _openFile(doc),
            trailing: _deleteFileAction(doc),
          ),
        );
      },
    );
  }

  /// Empty view when no documents exist
  Widget _emptyView() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.description, size: 80, color: Colors.grey),
        SizedBox(height: 16),
        Text(
          'No documents yet',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ],
    ),
  );

  /// Delete menu button
  Widget _deleteFileAction(DocumentModel doc) => PopupMenuButton<String>(
    onSelected: (_) => _deleteFile(doc),
    color: AppColor.backgroundColor,
    itemBuilder: (_) => const [
      PopupMenuItem(value: 'delete', child: Text('Delete')),
    ],
  );

  /// Delete document after confirmation
  Future<void> _deleteFile(DocumentModel doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Document'),
        backgroundColor: AppColor.backgroundColor,
        content: const Text('Are you sure you want to delete this document?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColor.normalTextColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColor.errorColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final file = File(doc.path);
    if (await file.exists()) await file.delete();

    await doc.delete();
  }

  /// AppBar
  AppBar get _appbar => AppBar(
    backgroundColor: AppColor.backgroundColor,
    title: const Text('My Documents'),
    actions: [
      IconButton(
        icon: const Icon(Icons.logout),
        onPressed: () {
          context.read<AuthBloc>().add(LoggedOut());
          GetStorage().remove(AppString.ACCESS_TOKEN);
          context.goNamed(AppRoute.login);
        },
      ),
    ],
  );
}
