import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../../core/enums/file_type_pdf.dart';
import '../../../../../core/utils/app_color.dart';
import '../../../../../core/utils/app_constants.dart';
import '../../../domain/models/file_type_model.dart';
import '../../bloc/document_editor_bloc.dart';
import '../screens/generate_file_view.dart';
import 'field_editors.dart';

class DocumentEditorView extends StatefulWidget {
  const DocumentEditorView({super.key});

  @override
  State<DocumentEditorView> createState() => _DocumentEditorViewState();
}

class _DocumentEditorViewState extends State<DocumentEditorView> {
  final GlobalKey _pdfKey = GlobalKey();
  final PdfViewerController _pdfController = PdfViewerController();

  ///UI
  @override
  Widget build(BuildContext context) {
    return BlocListener<DocumentEditorBloc, DocumentEditorState>(
      listener: (context, state) {
        if (state.status == DocumentEditorStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? "Unknown error")),
          );
        } else if (state.status == DocumentEditorStatus.success &&
            state.generatedPdfBytes != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  GeneratedFileScreen(bytes: state.generatedPdfBytes!),
            ),
          );
          context.read<DocumentEditorBloc>().add(ClearGeneratedPdfEvent());
        }
      },
      child: Scaffold(
        backgroundColor: AppColor.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColor.backgroundColor,

          title: const Text("Document Editor"),
          actions: [
            TextButton(
              onPressed: () {
                final renderBox =
                    _pdfKey.currentContext?.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  context.read<DocumentEditorBloc>().add(
                    GeneratePdfEvent(renderBox.size),
                  );
                }
              },
              child: const Text("Generate",style: TextStyle(color: AppColor.primaryColor),),
            ),
          ],
        ),
        body: BlocBuilder<DocumentEditorBloc, DocumentEditorState>(
          builder: (context, state) {
            if (state.status == DocumentEditorStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.originalPdf == null) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<DocumentEditorBloc>().add(PickPdfEvent());
                  },
                  child: const Text("+ Add PDF"),
                ),
              );
            }

            return Column(
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    _addBtn(context, "Sign", PdfFieldType.signature),
                    _addBtn(context, "Text", PdfFieldType.text),
                    _addBtn(context, "Checkbox", PdfFieldType.checkbox),
                    _addBtn(context, "Date", PdfFieldType.datetime),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: Stack(
                    children: [
                      SfPdfViewer.file(
                        state.originalPdf!,
                        key: _pdfKey,
                        controller: _pdfController,
                      ),
                      ...state.fields.map(
                        (f) => Positioned(
                          left: f.position.dx,
                          top: f.position.dy,
                          child: _fieldWidget(context, f),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _addBtn(BuildContext context, String title, PdfFieldType type) {
    return TextButton(
      onPressed: () {
        context.read<DocumentEditorBloc>().add(AddFieldEvent(type));
      },
      child: Text(title,style: TextStyle(color: AppColor.normalTextColor),),
    );
  }

  Widget _fieldWidget(BuildContext context, PdfField field) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FieldEditors.editField(context, field),
      onPanUpdate: (d) {
        context.read<DocumentEditorBloc>().add(
          UpdateFieldPositionEvent(field, field.position + d.delta),
        );
      },
      child:
          field.type == PdfFieldType.text || field.type == PdfFieldType.datetime
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: _fieldContent(field),
            )
          : _fieldContent(field),
    );
  }

  Widget _fieldContent(PdfField field) {
    switch (field.type) {
      case PdfFieldType.signature:
        return field.image == null
            ? const Text("Tap to Sign")
            : Image.memory(field.image!, width: 120, height: 50);

      case PdfFieldType.text:
      case PdfFieldType.datetime:
        return Text(
          field.text ?? "Type here",
          style: const TextStyle(fontSize: 14),
        );

      case PdfFieldType.checkbox:
        return SizedBox(
          height: kCheckBoxSize,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: kCheckBoxSize,
                height: kCheckBoxSize,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: field.checked ? Colors.blue : Colors.white,
                ),
                alignment: Alignment.center,
                child: field.checked
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              if (field.text != null && field.text!.trim().isNotEmpty) ...[
                const SizedBox(width: kCheckBoxGap),
                Text(field.text!, style: const TextStyle(fontSize: 14)),
              ],
            ],
          ),
        );
    }
  }
}
