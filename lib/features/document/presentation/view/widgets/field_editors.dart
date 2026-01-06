import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assessment/core/utils/app_color.dart';
import '../../bloc/document_editor_bloc.dart';
import 'package:assessment/features/document/presentation/view/widgets/signature_sheet.dart';
import '../../../../../core/enums/file_type_pdf.dart';
import '../../../domain/models/file_type_model.dart';


class FieldEditors {
  /// Main method to call for editing any field
  static Future<void> editField(BuildContext context, PdfField field) async {
    switch (field.type) {
      case PdfFieldType.signature:
        _editSignature(context, field);
        break;
      case PdfFieldType.text:
        await _editText(context, field);
        break;
      case PdfFieldType.checkbox:
        _toggleCheckbox(context, field);
        break;
      case PdfFieldType.datetime:
        await _pickDate(context, field);
        break;
    }
  }

  /// PRIVATE METHODS
  ///
  static void _editSignature(BuildContext context, PdfField field) {
    SignatureSheet.open(context, field);
  }

  static Future<void> _editText(BuildContext context, PdfField field) async {
    final controller = TextEditingController(
      text: field.text == "Type here" ? "" : field.text,
    );

    final value = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enter Text"),
        backgroundColor: AppColor.backgroundColor,
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text("OK")),
        ],
      ),
    );

    if (value != null && value.trim().isNotEmpty) {
      context.read<DocumentEditorBloc>().add(UpdateFieldContentEvent(field, text: value));
    }
  }

  static void _toggleCheckbox(BuildContext context, PdfField field) {
    context.read<DocumentEditorBloc>().add(UpdateFieldContentEvent(field, checked: !field.checked));
  }

  static Future<void> _pickDate(BuildContext context, PdfField field) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      context.read<DocumentEditorBloc>().add(
          UpdateFieldContentEvent(field, text: date.toString().split(' ').first));
    }
  }
}
