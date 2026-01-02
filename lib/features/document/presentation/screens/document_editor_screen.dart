import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:assessment/features/document/presentation/bloc/document_editor_bloc.dart';
import 'package:assessment/features/document/domain/models/document_field.dart';
import 'package:assessment/features/document/presentation/widgets/draggable_field.dart';
import 'package:assessment/features/document/domain/services/pdf_service.dart';
import 'package:printing/printing.dart';
import 'package:signature/signature.dart';

class DocumentEditorScreen extends StatefulWidget {
  final File file;

  const DocumentEditorScreen({super.key, required this.file});

  @override
  State<DocumentEditorScreen> createState() => _DocumentEditorScreenState();
}

class _DocumentEditorScreenState extends State<DocumentEditorScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

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
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Document Editor'),
            actions: [
              _BuildAppBarActions(file: widget.file),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: BlocBuilder<DocumentEditorBloc, DocumentEditorState>(
                  builder: (context, state) {
                    return Stack(
                      children: [
                        SfPdfViewer.file(
                          widget.file,
                          key: _pdfViewerKey,
                        ),
                        ...state.fields.map((field) {
                          return DraggableField(
                            field: field,
                            isLocked: state.status != DocumentStatus.editing,
                            onPositionChanged: (offset) {
                              final RenderBox renderBox = context.findRenderObject() as RenderBox;
                              final localOffset = renderBox.globalToLocal(offset);
                              context.read<DocumentEditorBloc>().add(
                                    UpdateFieldPosition(field.id, localOffset),
                                  );
                            },
                            onTap: () {
                              if (state.status == DocumentStatus.published) {
                                _showFillDialog(context, field);
                              }
                            },
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
              BlocBuilder<DocumentEditorBloc, DocumentEditorState>(
                builder: (context, state) {
                  if (state.status == DocumentStatus.editing) {
                    return _buildEditorToolbar(context);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditorToolbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _toolbarItem(context, Icons.edit_note, FieldType.signature, 'Sign'),
              _toolbarItem(context, Icons.text_fields, FieldType.text, 'Text'),
              _toolbarItem(context, Icons.check_box, FieldType.checkbox, 'Check'),
              _toolbarItem(context, Icons.calendar_today, FieldType.date, 'Date'),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () => context.read<DocumentEditorBloc>().add(ExportFields()),
                icon: const Icon(Icons.download),
                label: const Text('Export JSON'),
              ),
              TextButton.icon(
                onPressed: () => _showImportDialog(context),
                icon: const Icon(Icons.upload),
                label: const Text('Import JSON'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toolbarItem(BuildContext context, IconData icon, FieldType type, String label) {
    return InkWell(
      onTap: () {
        context.read<DocumentEditorBloc>().add(
              AddField(type, const Offset(50, 100)),
            );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showFillDialog(BuildContext context, DocumentField field) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Fill ${field.type.name}'),
          content: _FillFieldWidget(
            field: field,
            onChanged: (val) {
              context.read<DocumentEditorBloc>().add(UpdateFieldValue(field.id, val));
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showImportDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Import Field JSON'),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(hintText: 'Paste JSON here...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<DocumentEditorBloc>().add(ImportFields(controller.text));
                Navigator.pop(dialogContext);
              },
              child: const Text('Import'),
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
        if (state.status == DocumentStatus.editing) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () => context.read<DocumentEditorBloc>().add(PublishDocument()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('Publish'),
            ),
          );
        } else {
          return IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final signedFile = await PdfService.generateSignedPdf(file, state.fields);
              if (context.mounted) {
                await Printing.layoutPdf(
                  onLayout: (format) => signedFile.readAsBytes(),
                );
              }
            },
          );
        }
      },
    );
  }
}

class _FillFieldWidget extends StatefulWidget {
  final DocumentField field;
  final ValueChanged<String> onChanged;

  const _FillFieldWidget({required this.field, required this.onChanged});

  @override
  State<_FillFieldWidget> createState() => _FillFieldWidgetState();
}

class _FillFieldWidgetState extends State<_FillFieldWidget> {
  late SignatureController _signatureController;

  @override
  void initState() {
    super.initState();
    if (widget.field.type == FieldType.signature) {
      _signatureController = SignatureController(
        penStrokeWidth: 3,
        penColor: Colors.black,
      );
    }
  }

  @override
  void dispose() {
    if (widget.field.type == FieldType.signature) {
      _signatureController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.field.type) {
      case FieldType.text:
        return TextField(
          onChanged: widget.onChanged,
          decoration: const InputDecoration(hintText: 'Type something...'),
        );
      case FieldType.checkbox:
        return Row(
          children: [
            const Text('Check this field: '),
            Checkbox(
              value: widget.field.value == 'true',
              onChanged: (val) => widget.onChanged(val.toString()),
            ),
          ],
        );
      case FieldType.date:
        return ElevatedButton(
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              widget.onChanged(date.toIso8601String().split('T')[0]);
            }
          },
          child: Text(widget.field.value ?? 'Pick Date'),
        );
      case FieldType.signature:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Signature(
              controller: _signatureController,
              height: 150,
              backgroundColor: Colors.grey[200]!,
            ),
            TextButton(
              onPressed: () async {
                final export = await _signatureController.toPngBytes();
                if (export != null) {
                  widget.onChanged('Signature Captured');
                }
              },
              child: const Text('Capture Signature'),
            ),
          ],
        );
    }
  }
}
