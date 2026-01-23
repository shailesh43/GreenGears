import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

/// A custom file upload field specifically for Excel files (.xlsx, .xls).
///
/// Displays a clickable upload area that shows the selected file name
/// after a file is picked. Only allows Excel file formats.
class ExcelFileUploadField extends StatefulWidget {
  /// The label text displayed above the upload area
  final String label;

  /// Callback function triggered when a file is successfully selected
  final VoidCallback onFileSelected;

  const ExcelFileUploadField({
    super.key,
    required this.label,
    required this.onFileSelected,
  });

  @override
  State<ExcelFileUploadField> createState() => ExcelFileUploadFieldState();
}

/// State class for [ExcelFileUploadField]
class ExcelFileUploadFieldState extends State<ExcelFileUploadField> {
  String? _fileName;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
      });
      widget.onFileSelected();
    }
  }

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
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Column(
              children: [
                Icon(
                  _fileName == null ? Icons.cloud_upload_outlined : Icons.check_circle,
                  size: 32,
                  color: _fileName == null ? Colors.grey : const Color(0xFF59BF5C),
                ),
                const SizedBox(height: 8),
                Text(
                  _fileName ?? 'Click to upload Excel',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: _fileName == null ? Colors.grey : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}