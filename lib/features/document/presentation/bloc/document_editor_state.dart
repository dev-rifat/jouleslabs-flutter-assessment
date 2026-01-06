part of 'document_editor_bloc.dart';

enum DocumentEditorStatus { initial, loading, loaded, success, error }

class DocumentEditorState extends Equatable {
  final DocumentEditorStatus status;
  final File? originalPdf;
  final List<PdfField> fields;
  final Uint8List? generatedPdfBytes;
  final String? errorMessage;

  const DocumentEditorState({
    this.status = DocumentEditorStatus.initial,
    this.originalPdf,
    this.fields = const [],
    this.generatedPdfBytes,
    this.errorMessage,
  });

  DocumentEditorState copyWith({
    DocumentEditorStatus? status,
    File? originalPdf,
    List<PdfField>? fields,
    Uint8List? generatedPdfBytes,
    String? errorMessage,
  }) {
    return DocumentEditorState(
      status: status ?? this.status,
      originalPdf: originalPdf ?? this.originalPdf,
      fields: fields ?? this.fields,
      generatedPdfBytes: generatedPdfBytes ?? this.generatedPdfBytes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, originalPdf, fields, generatedPdfBytes, errorMessage];
}
