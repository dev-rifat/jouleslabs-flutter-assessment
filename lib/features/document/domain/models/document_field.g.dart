// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentField _$DocumentFieldFromJson(Map<String, dynamic> json) =>
    DocumentField(
      id: json['id'] as String,
      type: $enumDecode(_$FieldTypeEnumMap, json['type']),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num?)?.toDouble() ?? 150,
      height: (json['height'] as num?)?.toDouble() ?? 50,
      value: json['value'] as String?,
      isRequired: json['isRequired'] as bool? ?? true,
    );

Map<String, dynamic> _$DocumentFieldToJson(DocumentField instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$FieldTypeEnumMap[instance.type]!,
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
      'value': instance.value,
      'isRequired': instance.isRequired,
    };

const _$FieldTypeEnumMap = {
  FieldType.signature: 'signature',
  FieldType.text: 'text',
  FieldType.checkbox: 'checkbox',
  FieldType.date: 'date',
};
