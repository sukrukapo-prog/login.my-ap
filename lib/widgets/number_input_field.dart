import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? suffixText;
  final String? labelText;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const NumberInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.suffixText,
    this.labelText,
    this.autofocus = false,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      autofocus: autofocus,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        suffixText: suffixText,
        suffixStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withAlpha(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
      validator: validator,
    );
  }
}