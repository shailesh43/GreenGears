import 'package:flutter/material.dart';

/// A custom form text field with label and optional required indicator.

/// This widget displays a labeled text field with consistent styling
/// and an optional red asterisk for required fields.

class FormTextField extends StatelessWidget {
  /// The label text displayed above the text field
  final String label;
  final String hint;

  /// Whether this field is required (shows red asterisk)
  final bool required;

  /// Optional controller for the text field
  final TextEditingController? controller;

  /// Maximum number of lines for the text field
  final int maxLines;

  const FormTextField({
    super.key,
    required this.label,
    this.hint = 'Enter Value',
    this.required = false,
    this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF757575),
                ),
              ),
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF757575),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF848484)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
