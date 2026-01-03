import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:assessment/features/document/domain/models/document_field.dart';

class DraggableField extends StatelessWidget {
  final DocumentField field;
  final bool isLocked;
  final Function(Offset) onPositionChanged;
  final VoidCallback onTap;

  const DraggableField({
    super.key,
    required this.field,
    required this.isLocked,
    required this.onPositionChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: field.width,
      height: field.height,
      decoration: BoxDecoration(
        color: _getFieldColor().withOpacity(0.1),
        border: Border.all(
          color: isLocked ? Colors.transparent : _getFieldColor().withOpacity(0.5),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: _buildFieldContent(),
      ),
    );

    return Positioned(
      left: field.x,
      top: field.y,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: isLocked ? null : (details) {
          onPositionChanged(Offset(field.x + details.delta.dx, field.y + details.delta.dy));
        },
        onTap: onTap,
        child: content,
      ),
    );
  }

  Widget _buildFieldContent() {
    if (field.type == FieldType.signature && field.value != null && field.value!.length > 100) {
      try {
        return Image.memory(
          base64Decode(field.value!),
          fit: BoxFit.contain,
          key: ValueKey('sig_${field.id}_${field.value.hashCode}'),
        );
      } catch (e) {
        return const Icon(Icons.error);
      }
    }

    if (field.type == FieldType.checkbox) {
      return Icon(
        field.value == 'true' ? Icons.check_box : Icons.check_box_outline_blank,
        color: _getFieldColor(),
        size: 32,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        field.value ?? field.type.name.toUpperCase(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: _getFieldColor(),
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }

  Color _getFieldColor() {
    switch (field.type) {
      case FieldType.signature: return Colors.blue;
      case FieldType.text: return Colors.black;
      case FieldType.checkbox: return Colors.blue.shade800;
      case FieldType.date: return Colors.purple;
    }
  }
}
