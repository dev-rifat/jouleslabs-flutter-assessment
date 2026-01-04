import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// =====================
/// COMMON INPUT FIELD
/// =====================
class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double radius;
  final bool hideLabel;
  final Color? cursorColor;
  final TextInputType keyboardType;
  final Color? borderColor;
  final Color? errorBorderColor;
  final TextStyle? hintStyle;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CustomInputField({
    super.key,
    required this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.radius = 6,
    this.hideLabel = false,
    this.cursorColor,
    this.keyboardType = TextInputType.text,
    this.borderColor,
    this.errorBorderColor,
    this.hintStyle,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      cursorColor: cursorColor ?? const Color(0xFF3B3B3B),
      validator: validator,
      onChanged: onChanged,
      decoration: buildInputDecoration(
        hintText: hintText,
        hideLabel: hideLabel,
        hintStyle: hintStyle,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        radius: radius,
        borderColor: borderColor,
        errorBorderColor: errorBorderColor,
      ),
    );
  }
}

class PasswordInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final Widget? prefixIcon;
  final IconData? visibleIcon;
  final IconData? hiddenIcon;
  final double radius;
  final Color? borderColor;
  final Color? cursorColor;
  final TextStyle? hintStyle;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PasswordInputField({
    super.key,
    required this.controller,
    this.hintText,
    this.prefixIcon,
    this.visibleIcon,
    this.hiddenIcon,
    this.radius = 6,
    this.borderColor,
    this.cursorColor,
    this.hintStyle,
    this.validator,
    this.onChanged,
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      cursorColor: widget.cursorColor ?? const Color(0xFF3B3B3B),
      validator: widget.validator,
      onChanged: widget.onChanged,
      decoration: buildInputDecoration(
        hintText: widget.hintText,
        hintStyle: widget.hintStyle,
        prefixIcon: widget.prefixIcon,
        radius: widget.radius,
        borderColor: widget.borderColor,
        suffixIcon: IconButton(
          icon: Icon(
            _obscure
                ? widget.hiddenIcon ?? CupertinoIcons.eye_slash
                : widget.visibleIcon ?? CupertinoIcons.eye,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}


InputDecoration buildInputDecoration({
  String? hintText,
  bool hideLabel = false,
  TextStyle? hintStyle,
  Widget? prefixIcon,
  Widget? suffixIcon,
  double radius = 6,
  Color? borderColor,
  Color? errorBorderColor,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(radius),
    borderSide: BorderSide(color: borderColor ?? Colors.grey),
  );

  return InputDecoration(
    labelText: hideLabel ? null : hintText,
    hintText: hideLabel ? hintText : null,
    hintStyle: hintStyle ?? const TextStyle(color: Colors.grey),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    border: border,
    enabledBorder: border,
    focusedBorder: border,
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide:
      BorderSide(color: errorBorderColor ?? Colors.transparent),
    ),
    errorStyle: const TextStyle(
      color: Colors.red,
      fontStyle: FontStyle.italic,
    ),
  );
}
