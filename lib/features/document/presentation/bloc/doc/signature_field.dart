import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Signature field model
class SignatureField {
  Offset position;
  Uint8List? image;

  SignatureField({required this.position, this.image});
}
