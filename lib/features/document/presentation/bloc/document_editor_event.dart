part of 'document_editor_bloc.dart';



abstract class DocumentEditorEvent extends Equatable {
  const DocumentEditorEvent();

  @override
  List<Object?> get props => [];
}

class PickPdfEvent extends DocumentEditorEvent {}

class LoadInitialPdfEvent extends DocumentEditorEvent {
  final File file;
  const LoadInitialPdfEvent(this.file);
  @override
  List<Object?> get props => [file];
}

class AddFieldEvent extends DocumentEditorEvent {
  final PdfFieldType type;
  const AddFieldEvent(this.type);
  @override
  List<Object?> get props => [type];
}

class UpdateFieldPositionEvent extends DocumentEditorEvent {
  final PdfField field;
  final Offset newPosition;
  const UpdateFieldPositionEvent(this.field, this.newPosition);
  @override
  List<Object?> get props => [field, newPosition];
}

class UpdateFieldContentEvent extends DocumentEditorEvent {
  final PdfField field;
  final String? text;
  final bool? checked;
  final Uint8List? image;

  const UpdateFieldContentEvent(this.field, {this.text, this.checked, this.image});
  @override
  List<Object?> get props => [field, text, checked, image];
}

class GeneratePdfEvent extends DocumentEditorEvent {
  final Size renderSize;
  const GeneratePdfEvent(this.renderSize);
  @override
  List<Object?> get props => [renderSize];
}

class ClearGeneratedPdfEvent extends DocumentEditorEvent {}
