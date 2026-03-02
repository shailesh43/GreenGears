import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

class FileUploadField extends StatefulWidget {
  final String label;
  final List<String>? allowedExtensions;
  final Function(PlatformFile?)? onFileSelected;
  final String? initialFileName;
  final bool required;

  const FileUploadField({
    Key? key,
    required this.label,
    this.allowedExtensions,
    this.onFileSelected,
    this.initialFileName,
    this.required = false,
  }) : super(key: key);

  @override
  State<FileUploadField> createState() => _FileUploadFieldState();
}

class _FileUploadFieldState extends State<FileUploadField> {
  String? _fileName;
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    _fileName = widget.initialFileName;
  }

  Future<void> _pickFile() async {
    // ✅ Use passed extensions OR default ones
    final extensions = widget.allowedExtensions ??
        ['xls', 'xlsx', 'docx', 'pdf', 'jpg', 'png'];

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      withData: true, // REQUIRED
    );

    if (result != null) {
      final pickedFile = result.files.single;

      setState(() {
        _selectedFile = pickedFile;
        _fileName = pickedFile.name;
      });

      // Send file to parent
      if (widget.onFileSelected != null) {
        widget.onFileSelected!(pickedFile);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
            if (widget.required)
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
                  _fileName ?? 'Click to upload',
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