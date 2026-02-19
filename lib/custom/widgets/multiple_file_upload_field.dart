import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class MultipleFileUploadField extends StatefulWidget {
  final String label;
  final List<String>? allowedExtensions;
  final Function(List<PlatformFile>)? onFilesChanged;
  final int? maxFiles;
  final bool required;

  const MultipleFileUploadField({
    Key? key,
    required this.label,
    this.allowedExtensions,
    this.onFilesChanged,
    this.maxFiles,
    this.required = false,
  }) : super(key: key);

  @override
  State<MultipleFileUploadField> createState() => _MultipleFileUploadFieldState();
}

class _MultipleFileUploadFieldState extends State<MultipleFileUploadField> {
  List<PlatformFile> _selectedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
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

        // Upload Button
        GestureDetector(
          onTap: _pickFiles,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _selectedFiles.isEmpty
                      ? Icons.cloud_upload_outlined
                      : Icons.add_circle_outline,
                  size: 24,
                  color: _selectedFiles.isEmpty
                      ? Colors.grey
                      : const Color(0xFF9A9A9A),
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedFiles.isEmpty
                      ? 'Click to upload files'
                      : 'Add more files',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: _selectedFiles.isEmpty
                        ? Colors.grey
                        : const Color(0xFF9A9A9A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.maxFiles != null && _selectedFiles.isNotEmpty)
                  Text(
                    ' (${_selectedFiles.length}/${widget.maxFiles})',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Display selected files
        if (_selectedFiles.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _selectedFiles.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final file = _selectedFiles[index];
                return _buildFileItem(file, index);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFileItem(PlatformFile file, int index) {
    final fileSizeInKB = (file.size / 1024).toStringAsFixed(2);
    final fileExtension = file.extension?.toUpperCase() ?? 'FILE';

    return ListTile(
      dense: true,
      // contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            fileExtension,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Color(0xFF505050),
            ),
          ),
        ),
      ),
      title: Text(
        file.name,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '$fileSizeInKB KB',
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          color: Colors.grey,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 20, color: Colors.grey),
        onPressed: () => _removeFile(index),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  Future<void> _pickFiles() async {
    // Check max files limit
    if (widget.maxFiles != null && _selectedFiles.length >= widget.maxFiles!) {
      _showMaxFilesError();
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions ?? ['pdf', 'xls', 'xlsx', 'docx', 'jpg', 'png'],
        allowMultiple: true,
        withData: true, // 🔴 REQUIRED for bytes
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          // Add new files, respecting max limit
          if (widget.maxFiles != null) {
            final remainingSlots = widget.maxFiles! - _selectedFiles.length;
            _selectedFiles.addAll(result.files.take(remainingSlots));
          } else {
            _selectedFiles.addAll(result.files);
          }
        });

        // Notify parent
        if (widget.onFilesChanged != null) {
          widget.onFilesChanged!(_selectedFiles);
        }
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });

    // Notify parent
    if (widget.onFilesChanged != null) {
      widget.onFilesChanged!(_selectedFiles);
    }
  }

  void _showMaxFilesError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Maximum ${widget.maxFiles} files allowed',
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFFFA6262),
          ),
        ),
        backgroundColor: const Color(0xFFFFE3E3),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Public method to get files (if needed)
  List<PlatformFile> getFiles() => _selectedFiles;

  // Public method to clear all files (if needed)
  void clearFiles() {
    setState(() {
      _selectedFiles.clear();
    });
    if (widget.onFilesChanged != null) {
      widget.onFilesChanged!(_selectedFiles);
    }
  }
}