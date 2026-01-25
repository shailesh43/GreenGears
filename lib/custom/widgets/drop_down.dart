import 'package:flutter/material.dart';

class DropdownField extends StatefulWidget {
  final String label;
  final String hints;
  final List<String> items;

  DropdownField({
    super.key,
    required this.label,
    required this.hints,
    required this.items,
  });

  @override
  State<DropdownField> createState() => DropdownFieldState();
}

class DropdownFieldState extends State<DropdownField> {
  String? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6C6C6C),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          hint: Text(widget.hints),
          items: widget.items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedValue = newValue;
            });
          },
        ),
      ],
    );
  }
}