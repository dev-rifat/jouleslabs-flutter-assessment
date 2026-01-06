import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' hide PdfField;
import '../../../../core/enums/file_type_pdf.dart';
import '../../../../core/utils/app_constants.dart';
import '../../domain/models/file_type_model.dart';
part 'document_editor_event.dart';
part 'document_editor_state.dart';



class DocumentEditorBloc extends Bloc<DocumentEditorEvent, DocumentEditorState> {
  DocumentEditorBloc() : super(const DocumentEditorState()) {
    on<PickPdfEvent>(_onPickPdf);
    on<LoadInitialPdfEvent>(_onLoadInitialPdf);
    on<AddFieldEvent>(_onAddField);
    on<UpdateFieldPositionEvent>(_onUpdateFieldPosition);
    on<UpdateFieldContentEvent>(_onUpdateFieldContent);
    on<GeneratePdfEvent>(_onGeneratePdf);
    on<ClearGeneratedPdfEvent>(_onClearGeneratedPdf);
  }

  Future<void> _onPickPdf(PickPdfEvent event, Emitter<DocumentEditorState> emit) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        emit(state.copyWith(
          originalPdf: File(result.files.single.path!),
          fields: [], // Clear fields when new PDF is picked
          status: DocumentEditorStatus.loaded,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
          status: DocumentEditorStatus.error, errorMessage: e.toString()));
    }
  }

  void _onLoadInitialPdf(
      LoadInitialPdfEvent event, Emitter<DocumentEditorState> emit) {
    emit(state.copyWith(
      originalPdf: event.file,
      status: DocumentEditorStatus.loaded,
    ));
  }

  void _onAddField(AddFieldEvent event, Emitter<DocumentEditorState> emit) {
    final newField = PdfField(
      type: event.type,
      position: const Offset(100, 200),
      text: event.type == PdfFieldType.datetime
          ? DateTime.now().toString().split(' ').first
          : (event.type == PdfFieldType.text ? "Type here" : null),
    );

    final updatedFields = List<PdfField>.from(state.fields)..add(newField);
    emit(state.copyWith(fields: updatedFields));
  }

  void _onUpdateFieldPosition(
      UpdateFieldPositionEvent event, Emitter<DocumentEditorState> emit) {
    final fields = List<PdfField>.from(state.fields);
    final index = fields.indexWhere((f) => f == event.field); // Use indexWhere with equality check if fields are unique enough, or rely on object identity if not recreated improperly.
    // However, since we are now creating new instances for updates (immutability), using reference equality (fields.indexOf(event.field)) might fail if the UI is holding an old reference.
    // But in this flow, the event comes from the UI which got it from the state, so it should be fine *unless* we already replaced it.
    
    // Better approach: Find by index if possible, or assume the UI passes the exact object from the current state.
    // Given we are mutating in previous implementation, let's switch to immutable updates using copyWith.
    
    if (index != -1) {
      fields[index] = fields[index].copyWith(position: event.newPosition);
      emit(state.copyWith(fields: fields));
    }
  }

  void _onUpdateFieldContent(
      UpdateFieldContentEvent event, Emitter<DocumentEditorState> emit) {
    final fields = List<PdfField>.from(state.fields);
    final index = fields.indexOf(event.field);
    if (index != -1) {
      // Create a new instance with updated values
      fields[index] = fields[index].copyWith(
        text: event.text,
        checked: event.checked,
        image: event.image,
      );
      
      emit(state.copyWith(fields: fields));
    }
  }

  Future<void> _onGeneratePdf(
      GeneratePdfEvent event, Emitter<DocumentEditorState> emit) async {
    if (state.originalPdf == null) return;

    emit(state.copyWith(status: DocumentEditorStatus.loading));

    try {
      final bytes = await state.originalPdf!.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      final page = document.pages[0];

      final renderSize = event.renderSize;
      final xScale = page.size.width / renderSize.width;
      final yScale = page.size.height / renderSize.height;
      final scale = (xScale + yScale) / 2;

      for (final field in state.fields) {
        final dx = field.position.dx * xScale;
        final dy = field.position.dy * yScale;

        switch (field.type) {
          case PdfFieldType.signature:
            if (field.image != null) {
              page.graphics.drawImage(PdfBitmap(field.image!),
                  Rect.fromLTWH(dx, dy, 120 * scale, 50 * scale));
            }
            break;

          case PdfFieldType.text:
          case PdfFieldType.datetime:
            if (field.text != null &&
                field.text!.trim().isNotEmpty &&
                field.text != "Type here") {
              final font = PdfStandardFont(
                  PdfFontFamily.helvetica, kPdfFontSize * scale);
              page.graphics.drawString(
                field.text!,
                font,
                brush: PdfBrushes.black,
                bounds: Rect.fromLTWH(dx, dy,
                    font.measureString(field.text!).width + 4, font.height + 4),
              );
            }
            break;

          case PdfFieldType.checkbox:
            final boxSize = kCheckBoxSize * scale;
            final boxRect = Rect.fromLTWH(dx, dy, boxSize, boxSize);

            page.graphics.drawRectangle(
                bounds: boxRect,
                pen: PdfPen(PdfColor(0, 0, 0), width: 1.2 * scale));

            if (field.checked) {
              final pen = PdfPen(PdfColor(0, 0, 0), width: 2 * scale);
              page.graphics.drawLine(
                  pen,
                  Offset(boxRect.left + boxSize * 0.2,
                      boxRect.top + boxSize * 0.55),
                  Offset(boxRect.left + boxSize * 0.45,
                      boxRect.top + boxSize * 0.8));
              page.graphics.drawLine(
                  pen,
                  Offset(boxRect.left + boxSize * 0.45,
                      boxRect.top + boxSize * 0.8),
                  Offset(boxRect.left + boxSize * 0.8,
                      boxRect.top + boxSize * 0.2));
            }

            if (field.text != null &&
                field.text!.trim().isNotEmpty &&
                field.text != "Type here") {
              final font = PdfStandardFont(
                  PdfFontFamily.helvetica, kPdfFontSize * scale);
              page.graphics.drawString(
                field.text!,
                font,
                bounds: Rect.fromLTWH(
                    dx + boxSize + kCheckBoxGap * scale,
                    dy + (boxSize - font.height) / 2,
                    200 * scale,
                    font.height),
              );
            }
            break;
        }
      }

      final savedBytes = await document.save();
      document.dispose();

      emit(state.copyWith(
        status: DocumentEditorStatus.success,
        generatedPdfBytes: Uint8List.fromList(savedBytes),
        fields: [], // Clear fields after generation as per original logic? Or keep them?
        // Original logic: setState(() => fields.clear());
      ));
    } catch (e) {
      emit(state.copyWith(
          status: DocumentEditorStatus.error, errorMessage: e.toString()));
    }
  }

  void _onClearGeneratedPdf(
      ClearGeneratedPdfEvent event, Emitter<DocumentEditorState> emit) {
    emit(state.copyWith(
      status: DocumentEditorStatus.loaded,
      generatedPdfBytes: null,
      fields: [], // If we want to clear fields
    ));
  }
}
