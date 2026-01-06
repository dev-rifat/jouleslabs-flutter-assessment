// ================= FIELD MODEL =================

import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'dart:ui';
import '../../../../core/enums/file_type_pdf.dart';

// ================= FIELD MODEL =================

class PdfField {
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
}
