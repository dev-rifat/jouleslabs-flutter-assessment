import 'dart:io';
import 'package:assessment/core/utils/app_color.dart';
import 'package:assessment/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'ducument_editors.dart';
import 'generate_file_view.dart';

class DocumentsList extends StatefulWidget {
  const DocumentsList({super.key});

  @override
  State<DocumentsList> createState() => _DocumentsListState();
}

class _DocumentsListState extends State<DocumentsList> {
  final List<File> _files = [];

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  /// Load all PDF files
  Future<void> _loadFiles() async {
    final dir = await getApplicationDocumentsDirectory();

    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.pdf'))
        .toList()
      ..sort(
            (a, b) =>
            b.statSync().modified.compareTo(a.statSync().modified),
      );

    if (!mounted) return;
    setState(() {
      _files
        ..clear()
        ..addAll(files);
    });
  }

  /// Pick & edit document
  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'docx'],
    );

    final path = result?.files.single.path;
    if (path == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentEditorScreen(
          initialFile: File(path),
        ),
      ),
    );

    _loadFiles();
  }

  void _openFile(File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GeneratedPdfScreen(file: file),
      ),
    );
  }

  Future<void> _deleteFile(File file) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Document'),
        backgroundColor: AppColor.backgroundColor,
        content: const Text('Are you sure you want to delete this document?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:  Text('Cancel',style: TextStyle(color: AppColor.normalTextColor),),
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

    if (confirm != true) return;

    await file.delete();
    _loadFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundColor,
        title: const Text('My Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(LoggedOut()),
          ),
        ],
      ),
      body: _files.isEmpty ? _emptyView() : _documentsList(),
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

  Widget _documentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _files.length,
      itemBuilder: (_, index) {
        final file = _files[index];
        final stat = file.statSync();

        return Card(
          color: AppColor.disableColor.withValues(alpha: 0.3),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          child: ListTile(


            leading: const Icon(
              Icons.file_present_outlined,
              color: AppColor.primaryColor,
            ),
            title: Text(file.path.split('/').last),
            subtitle: Text(
              DateFormat('dd MMM yy  h:mm a')
                  .format(stat.modified.toLocal()),
            ),

            onTap: () => _openFile(file),
            trailing: PopupMenuButton<String>(
              onSelected: (_) => _deleteFile(file),
              color: AppColor.backgroundColor,
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'delete',
                  child:Text('Delete'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyView() {
    return const Center(
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
  }
}
