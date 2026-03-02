import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntegerRangeField extends StatelessWidget {
  final String label;
  final String hint;
  final double min;
  final double max;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool isInteger; // To distinguish int vs double
  final bool required; // To show asterisk

  const IntegerRangeField({
    super.key,
    required this.label,
    required this.hint,
    required this.min,
    required this.max,
    required this.controller,
    this.onChanged,
    this.errorText,
    this.isInteger = true, // Default to integer
    this.required = false, // Default to not required
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF757575),
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: !isInteger),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                isInteger ? RegExp(r'^\d*') : RegExp(r'^\d*\.?\d*')
            ),
          ],
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF757575),
            ),
            errorText: errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null
                    ? Theme.of(context).colorScheme.error
                    : const Color(0xFFE0E0E0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null
                    ? Theme.of(context).colorScheme.error
                    : const Color(0xFF848484),
              ),
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
              return isInteger ? 'Invalid number' : 'Invalid decimal number';
            }

            if (number < min || number > max) {
              return 'Enter value between ${min.toStringAsFixed(isInteger ? 0 : 2)} and ${max.toStringAsFixed(isInteger ? 0 : 2)}';
            }

            return null;
          },
          onChanged: (value) {
            onChanged?.call(value);
          },
        ),
      ],
    );
  }
}