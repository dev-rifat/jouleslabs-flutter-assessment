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
        color: _getFieldColor().withOpacity(0.3),
        border: Border.all(color: _getFieldColor(), width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getFieldIcon(), size: 20, color: _getFieldColor()),
            Text(
              field.type.name.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _getFieldColor(),
              ),
            ),
          ],
        ),
      ),
    );

    if (isLocked) {
      return Positioned(
        left: field.x,
        top: field.y,
        child: GestureDetector(
          onTap: onTap,
          child: content,
        ),
      );
    }

    return Positioned(
      left: field.x,
      top: field.y,
      child: GestureDetector(
        onTap: onTap,
        child: Draggable(
          feedback: Material(
            color: Colors.transparent,
            child: content,
          ),
          childWhenDragging: Opacity(opacity: 0.5, child: content),
          onDragEnd: (details) {
            // Adjust for local position if needed
            onPositionChanged(details.offset);
          },
          child: content,
        ),
      ),
    );
  }

  Color _getFieldColor() {
    switch (field.type) {
      case FieldType.signature:
        return Colors.blue;
      case FieldType.text:
        return Colors.green;
      case FieldType.checkbox:
        return Colors.orange;
      case FieldType.date:
        return Colors.purple;
    }
  }

  IconData _getFieldIcon() {
    switch (field.type) {
      case FieldType.signature:
        return Icons.edit_note;
      case FieldType.text:
        return Icons.text_fields;
      case FieldType.checkbox:
        return Icons.check_box;
      case FieldType.date:
        return Icons.calendar_today;
    }
  }
}
