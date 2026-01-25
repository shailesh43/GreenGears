import 'package:flutter/material.dart';

/// A custom row widget that displays a label-value pair.
/// The label appears on the left (40% width) and the value
/// appears on the right (60% width) with right-aligned text.

class DetailRow extends StatelessWidget {
  /// The label text displayed on the left
  final String label;

  /// The value text displayed on the right
  final String value;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Color(0xFF757575),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}