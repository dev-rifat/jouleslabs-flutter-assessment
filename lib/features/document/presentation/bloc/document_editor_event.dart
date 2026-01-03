part of 'document_editor_bloc.dart';

abstract class DocumentEditorEvent extends Equatable {
  const DocumentEditorEvent();

  @override
  List<Object?> get props => [];
}

class AddField extends DocumentEditorEvent {
  final FieldType type;
  final Offset position;
  final String? value;

  const AddField(this.type, this.position, {this.value});

  @override
  List<Object?> get props => [type, position, value];
}

class UpdateFieldPosition extends DocumentEditorEvent {
  final String fieldId;
  final Offset newPosition;

  const UpdateFieldPosition(this.fieldId, this.newPosition);

  @override
  List<Object?> get props => [fieldId, newPosition];
}

class RemoveField extends DocumentEditorEvent {
  final String fieldId;

  const RemoveField(this.fieldId);

  @override
  List<Object?> get props => [fieldId];
}

class ExportFields extends DocumentEditorEvent {}

class ImportFields extends DocumentEditorEvent {
  final String jsonString;

  const ImportFields(this.jsonString);

  @override
  List<Object?> get props => [jsonString];
}

class PublishDocument extends DocumentEditorEvent {}

class UpdateFieldValue extends DocumentEditorEvent {
  final String fieldId;
  final String value;

  const UpdateFieldValue(this.fieldId, this.value);

  @override
  List<Object?> get props => [fieldId, value];
}
