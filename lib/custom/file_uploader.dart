import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

class FileUploadField extends StatefulWidget {
  final String label;
  final List<String>? allowedExtensions;
  final Function(PlatformFile?)? onFileSelected;
  final String? initialFileName;

  const FileUploadField({
    Key? key,
    required this.label,
    this.allowedExtensions,
    this.onFileSelected,
    this.initialFileName,
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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: widget.allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: widget.allowedExtensions,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.single;
        _fileName = _selectedFile!.name;
      });

      // Callback to parent widget
      if (widget.onFileSelected != null) {
        widget.onFileSelected!(_selectedFile);
      }
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