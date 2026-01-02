import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:assessment/features/document/domain/models/document_field.dart';

part 'document_editor_event.dart';
part 'document_editor_state.dart';

class DocumentEditorBloc extends Bloc<DocumentEditorEvent, DocumentEditorState> {
  DocumentEditorBloc() : super(const DocumentEditorState()) {
    on<AddField>(_onAddField);
    on<UpdateFieldPosition>(_onUpdateFieldPosition);
    on<RemoveField>(_onRemoveField);
    on<ExportFields>(_onExportFields);
    on<ImportFields>(_onImportFields);
    on<PublishDocument>(_onPublishDocument);
    on<UpdateFieldValue>(_onUpdateFieldValue);
  }

  void _onAddField(AddField event, Emitter<DocumentEditorState> emit) {
    if (state.status != DocumentStatus.editing) return;

    final newField = DocumentField(
      id: const Uuid().v4(),
      type: event.type,
      x: event.position.dx,
      y: event.position.dy,
    );
    emit(state.copyWith(fields: List.from(state.fields)..add(newField)));
  }

  void _onUpdateFieldPosition(
      UpdateFieldPosition event, Emitter<DocumentEditorState> emit) {
    if (state.status != DocumentStatus.editing) return;

    final updatedFields = state.fields.map((field) {
      if (field.id == event.fieldId) {
        return field.copyWith(x: event.newPosition.dx, y: event.newPosition.dy);
      }
      return field;
    }).toList();
    emit(state.copyWith(fields: updatedFields));
  }

  void _onRemoveField(RemoveField event, Emitter<DocumentEditorState> emit) {
    if (state.status != DocumentStatus.editing) return;

    final updatedFields =
        state.fields.where((field) => field.id != event.fieldId).toList();
    emit(state.copyWith(fields: updatedFields));
  }

  void _onExportFields(ExportFields event, Emitter<DocumentEditorState> emit) {
    final jsonFields = state.fields.map((f) => f.toJson()).toList();
    final jsonString = jsonEncode({'fields': jsonFields});
    // In a real app, we might trigger a save file dialog or share
    print('Exported JSON: $jsonString');
  }

  void _onImportFields(ImportFields event, Emitter<DocumentEditorState> emit) {
    try {
      final Map<String, dynamic> data = jsonDecode(event.jsonString);
      final List<dynamic> fieldsJson = data['fields'];
      final importedFields =
          fieldsJson.map((j) => DocumentField.fromJson(j)).toList();
      emit(state.copyWith(fields: importedFields));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Invalid JSON format'));
    }
  }

  void _onPublishDocument(
      PublishDocument event, Emitter<DocumentEditorState> emit) {
    if (state.fields.isEmpty) {
      emit(state.copyWith(errorMessage: 'Add at least one field before publishing'));
      return;
    }
    emit(state.copyWith(status: DocumentStatus.published));
  }

  void _onUpdateFieldValue(
      UpdateFieldValue event, Emitter<DocumentEditorState> emit) {
    final updatedFields = state.fields.map((field) {
      if (field.id == event.fieldId) {
        return field.copyWith(value: event.value);
      }
      return field;
    }).toList();
    emit(state.copyWith(fields: updatedFields));
  }
}
