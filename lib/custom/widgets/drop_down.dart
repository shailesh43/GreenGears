import 'package:flutter/material.dart';

class DropdownField extends StatefulWidget {
  final String label;
  final String hints;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool required;

  const DropdownField({
    super.key,
    required this.label,
    required this.hints,
    required this.items,
    required this.onChanged,
    required this.required,
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
        /// Label
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: widget.label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF757575),
                ),
              ),
              if (widget.required)
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

        /// Dropdown
        DropdownButtonFormField<String>(
          value: _selectedValue,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xF5323232),
          ),

          /// 👇 Limits dropdown window height
          menuMaxHeight: 400,

          decoration: InputDecoration(
            hintText: widget.hints,
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
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          hint: Text(widget.hints),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFFCECECE),
          ),
          items: widget.items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: SizedBox(
                height: 40, // 👈 tighter item height
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Color(0xFF757575),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedValue = newValue;
            });
            widget.onChanged(newValue);
          },
        ),
      ],
    );
  }
}
