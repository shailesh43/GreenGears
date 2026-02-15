import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ExcelFileUploadField extends StatefulWidget {
  final String label;
  final Function(PlatformFile?) onFileSelected;

  const ExcelFileUploadField({
    super.key,
    required this.label,
    required this.onFileSelected,
  });

  @override
  State<ExcelFileUploadField> createState() =>
      ExcelFileUploadFieldState();
}

class ExcelFileUploadFieldState
    extends State<ExcelFileUploadField> {
  String? _fileName;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    try {
      setState(() => _isLoading = true);

      FilePickerResult? result =
      await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true, // ✅ Required for bytes
      );

      if (result == null || result.files.isEmpty) {
        widget.onFileSelected(null);
        return;
      }

      final PlatformFile file = result.files.single;

      // ✅ File size validation (5MB limit)
      if (file.size == 0) {
        _showError("Selected file is empty.");
        widget.onFileSelected(null);
        return;
      }

      if (file.size > 5 * 1024 * 1024) {
        _showError("File size must be less than 5MB.");
        widget.onFileSelected(null);
        return;
      }

      // ✅ Byte validation
      if (file.bytes == null) {
        _showError("Unable to read file data. Please retry.");
        widget.onFileSelected(null);
        return;
      }

      setState(() {
        _fileName = file.name;
      });

      widget.onFileSelected(file);
    } catch (e) {
      _showError("Failed to pick file.");
      widget.onFileSelected(null);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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
          onTap: _isLoading ? null : _pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
              ),
            ),
            child: Column(
              children: [
                if (_isLoading)
                  const CircularProgressIndicator(
                    color: Color.fromRGBO(34, 197, 94, 1), // Your green color
                  )
                else
                  Icon(
                    _fileName == null
                        ? Icons.cloud_upload_outlined
                        : Icons.check_circle,
                    size: 32,
                    color: _fileName == null
                        ? Colors.grey
                        : const Color(0xFF59BF5C),
                  ),
                const SizedBox(height: 8),
                Text(
                  _fileName ?? 'Click to upload Excel',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: _fileName == null
                        ? Colors.grey
                        : Colors.black,
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
