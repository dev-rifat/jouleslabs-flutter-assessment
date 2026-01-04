import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:assessment/features/document/presentation/bloc/document_editor_bloc.dart';
import 'package:assessment/features/document/domain/models/document_field.dart';
import 'package:assessment/features/document/presentation/widgets/draggable_field.dart';
import 'package:assessment/features/document/domain/services/pdf_service.dart';
import 'package:assessment/features/document/presentation/screens/my_signatures_screen.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class DocumentEditorScreen extends StatefulWidget {
  final File file;

  const DocumentEditorScreen({super.key, required this.file});

  @override
  State<DocumentEditorScreen> createState() => _DocumentEditorScreenState();
}

class _DocumentEditorScreenState extends State<DocumentEditorScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final GlobalKey _stackKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DocumentEditorBloc(),
      child: BlocListener<DocumentEditorBloc, DocumentEditorState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        child: Builder(
          builder: (context) {
            return Scaffold(
              backgroundColor: const Color(0xFFF5F5F5),
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0.5,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  widget.file.path.split('/').last,
                  style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                actions: [
                  _BuildAppBarActions(file: widget.file),
                ],
              ),
              body: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.white,
                    child: const Row(
                      children: [
                        Text('1 / 1 Pages', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Spacer(),
                        Icon(Icons.more_vert, color: Colors.grey, size: 20),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<DocumentEditorBloc, DocumentEditorState>(
                      builder: (context, state) {
                        return Stack(
                          key: _stackKey,
                          children: [
                            SfPdfViewer.file(
                              widget.file,
                              key: _pdfViewerKey,
                            ),
                            ...state.fields.map((field) {
                              return DraggableField(
                                field: field,
                                isLocked: state.status != DocumentStatus.editing,
                                onPositionChanged: (newPosition) {
                                  context.read<DocumentEditorBloc>().add(
                                        UpdateFieldPosition(field.id, newPosition),
                                      );
                                },
                                onTap: () async {
                                  if (state.status == DocumentStatus.editing) {
                                    if (field.type == FieldType.signature && field.value == null) {
                                      _pickSignatureForField(context, field.id);
                                    } else if (field.type == FieldType.text && field.value == 'Enter Text') {
                                       _showTextPrompt(context, fieldId: field.id);
                                    } else {
                                      _showEditDeleteDialog(context, field);
                                    }
                                  }
                                },
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),
                  _buildModernToolbar(context),
                ],
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildModernToolbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _modernToolbarItem(context, Icons.edit_outlined, 'Signature', () {
            context.read<DocumentEditorBloc>().add(
              const AddField(FieldType.signature, Offset(150, 400), value: null),
            );
          }),
          _modernToolbarItem(context, Icons.info_outline, 'Initial', () {
             context.read<DocumentEditorBloc>().add(
              const AddField(FieldType.signature, Offset(100, 400), value: null),
            );
          }),
          _modernToolbarItem(context, Icons.text_fields_outlined, 'Text Box', () {
             context.read<DocumentEditorBloc>().add(
              const AddField(FieldType.text, Offset(100, 300), value: 'Enter Text'),
            );
          }),
          _modernToolbarItem(context, Icons.radio_button_checked, 'Radio', () {
            context.read<DocumentEditorBloc>().add(
              const AddField(FieldType.checkbox, Offset(150, 300), value: 'false'),
            );
          }),
          _modernToolbarItem(context, Icons.calendar_today_outlined, 'Date', () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null && context.mounted) {
              context.read<DocumentEditorBloc>().add(
                AddField(FieldType.date, const Offset(150, 200), value: date.toIso8601String().split('T')[0]),
              );
            }
          }),
          _modernToolbarItem(context, Icons.menu, 'Stamp', () {}),
        ],
      ),
    );
  }

  Widget _modernToolbarItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF1E4D92), size: 24),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Future<void> _pickSignatureForField(BuildContext context, String fieldId) async {
    final signatureData = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const MySignaturesScreen()),
    );
    if (signatureData != null && context.mounted) {
      context.read<DocumentEditorBloc>().add(UpdateFieldValue(fieldId, signatureData));
    }
  }

  void _showTextPrompt(BuildContext context, {String? fieldId}) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(fieldId == null ? 'Add Text Box' : 'Edit Text'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter text...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                if (fieldId != null) {
                  context.read<DocumentEditorBloc>().add(UpdateFieldValue(fieldId, controller.text));
                } else {
                  context.read<DocumentEditorBloc>().add(
                    AddField(FieldType.text, const Offset(100, 350), value: controller.text),
                  );
                }
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEditDeleteDialog(BuildContext context, DocumentField field) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final textController = TextEditingController(text: field.value);
        return AlertDialog(
          title: Text('Edit ${field.type.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (field.type == FieldType.text)
                TextField(controller: textController, autofocus: true),
              if (field.type == FieldType.checkbox)
                const Text('Toggle checkbox?'),
              if (field.type == FieldType.signature)
                const Text('Choose a new signature or delete this one.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<DocumentEditorBloc>().add(RemoveField(field.id));
                Navigator.pop(dialogContext);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            const Spacer(),
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (field.type == FieldType.signature) {
                  _pickSignatureForField(context, field.id);
                } else if (field.type == FieldType.checkbox) {
                   final newVal = field.value == 'true' ? 'false' : 'true';
                   context.read<DocumentEditorBloc>().add(UpdateFieldValue(field.id, newVal));
                } else {
                  context.read<DocumentEditorBloc>().add(UpdateFieldValue(field.id, textController.text));
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}

class _BuildAppBarActions extends StatelessWidget {
  final File file;
  const _BuildAppBarActions({required this.file});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentEditorBloc, DocumentEditorState>(
      builder: (context, state) {
        return TextButton(
          onPressed: () async {
            if (state.status == DocumentStatus.editing) {
              final signedFile = await PdfService.generateSignedPdf(file, state.fields);
              final directory = await getApplicationDocumentsDirectory();
              final fileName = 'final_doc_${DateTime.now().millisecondsSinceEpoch}.pdf';
              final savedFile = await signedFile.copy('${directory.path}/$fileName');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Saved: ${savedFile.path}'),
                    action: SnackBarAction(label: 'Open', onPressed: () => Printing.layoutPdf(onLayout: (_) => savedFile.readAsBytes())),
                  ),
                );
              }
            }
          },
          child: const Text(
            'Continue',
            style: TextStyle(color: Color(0xFF1E4D92), fontWeight: FontWeight.bold, fontSize: 16),
          ),
        );
      },
    );
  }
}
