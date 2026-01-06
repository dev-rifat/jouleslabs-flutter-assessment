// ================= FIELD MODEL =================

import 'dart:typed_data';
import 'dart:ui';
import 'package:equatable/equatable.dart';
import '../../../../core/enums/file_type_pdf.dart';

// ================= FIELD MODEL =================

class PdfField extends Equatable {
  PdfField({
    required this.type,
    required this.position,
    this.text,
    this.checked = false,
    this.image,
  });

  PdfFieldType type;
  Offset position; // position inside pdf page (viewer space)
  String? text;
  bool checked;
  Uint8List? image;
  
  // Create a copyWith method to allow immutable updates
  PdfField copyWith({
    PdfFieldType? type,
    Offset? position,
    String? text,
    bool? checked,
    Uint8List? image,
  }) {
    return PdfField(
      type: type ?? this.type,
      position: position ?? this.position,
      text: text ?? this.text,
      checked: checked ?? this.checked,
      image: image ?? this.image,
    );
  }

  @override
  List<Object?> get props => [type, position, text, checked, image];
}
