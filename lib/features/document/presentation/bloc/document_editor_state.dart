part of 'document_editor_bloc.dart';

enum DocumentStatus { editing, published, signing, completed }

class DocumentEditorState extends Equatable {
  final List<DocumentField> fields;
  final DocumentStatus status;
  final String? errorMessage;

  const DocumentEditorState({
    this.fields = const [],
    this.status = DocumentStatus.editing,
    this.errorMessage,
  });

  DocumentEditorState copyWith({
    List<DocumentField>? fields,
    DocumentStatus? status,
    String? errorMessage,
  }) {
    return DocumentEditorState(
      fields: fields ?? this.fields,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [fields, status, errorMessage];
}
