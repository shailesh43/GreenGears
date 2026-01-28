import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntegerRangeField extends StatelessWidget {
  final String label;
  final String hint;
  final double min;
  final double max;
  final TextEditingController controller;
  final ValueChanged<double>? onChanged;

  const IntegerRangeField({
    super.key,
    required this.label,
    required this.hint,
    required this.min,
    required this.max,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
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
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF848484)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }

            final number = double.tryParse(value);
            if (number == null) {
              return 'Invalid Decimal number';
            }

            if (number < min || number > max) {
              return 'Enter value between $min and $max';
            }

            return null;
          },
          onChanged: (value) {
            final parsed = double.tryParse(value);
            if (parsed != null) {
              onChanged?.call(parsed);
            }
          },
        ),
      ],
    );
  }
}
