import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'document_field.g.dart';

enum FieldType { signature, text, checkbox, date }

@JsonSerializable()
class DocumentField extends Equatable {
  final String id;
  final FieldType type;
  final double x;
  final double y;
  final double width;
  final double height;
  final String? value;
  final bool isRequired;

  const DocumentField({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.width = 150,
    this.height = 50,
    this.value,
    this.isRequired = true,
  });

  DocumentField copyWith({
    String? id,
    FieldType? type,
    double? x,
    double? y,
    double? width,
    double? height,
    String? value,
    bool? isRequired,
  }) {
    return DocumentField(
      id: id ?? this.id,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      value: value ?? this.value,
      isRequired: isRequired ?? this.isRequired,
    );
  }

  factory DocumentField.fromJson(Map<String, dynamic> json) =>
      _$DocumentFieldFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentFieldToJson(this);

  @override
  List<Object?> get props => [id, type, x, y, width, height, value, isRequired];
}
