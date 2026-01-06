import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assessment/core/utils/app_color.dart';
import 'package:signature/signature.dart';
import '../../../domain/models/file_type_model.dart';
import '../../bloc/document_editor_bloc.dart';

/// Update path as needed

class SignatureSheet {
  /// Opens a bottom sheet for drawing signature
  static void open(BuildContext context, PdfField field) {
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
              color: AppColor.backgroundColor,

              child: Signature(
                controller: controller,
                backgroundColor: AppColor.disableColor,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: controller.clear,
                  child: const Text(
                    "Clear",
                    style: TextStyle(color: AppColor.normalTextColor),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final img = await controller.toPngBytes();
                    if (img != null) {
                      context.read<DocumentEditorBloc>().add(
                        UpdateFieldContentEvent(field, image: img),
                      );
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(color: AppColor.primaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
