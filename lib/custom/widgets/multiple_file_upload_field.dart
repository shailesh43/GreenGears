import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  State<MultipleFileUploadField> createState() =>
      _MultipleFileUploadFieldState();
}

class _MultipleFileUploadFieldState extends State<MultipleFileUploadField> {
  List<PlatformFile> _selectedFiles = [];

  /// Complete MIME type whitelist for all supported file types
  static const Map<String, List<String>> _mimeTypeWhitelist = {
    'pdf': ['application/pdf'],
    'jpg': ['image/jpeg'],
    'jpeg': ['image/jpeg'],
    'png': ['image/png'],
    'xls': ['application/vnd.ms-excel'],
    'xlsx': [
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    ],
    'docx': [
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    ],
  };

  /// Validates file by checking MIME type against extension
  bool _validateFileMimeType(PlatformFile file) {
    final extension = file.extension?.toLowerCase();
    if (extension == null) return false;

    // Check if this extension is in our whitelist
    final allowedMimeTypes = _mimeTypeWhitelist[extension];
    if (allowedMimeTypes == null) {
      debugPrint('Extension "$extension" not in MIME whitelist');
      return false;
    }

    // Check if file has bytes data
    if (file.bytes == null) {
      debugPrint('File has no bytes data for MIME validation');
      return false;
    }

    // Get the actual MIME type by reading file signature (magic bytes)
    final detectedMimeType = _detectMimeType(file.bytes!, extension);

    if (detectedMimeType == null) {
      debugPrint('Could not detect MIME type for file: ${file.name}');
      return false;
    }

    final isValid = allowedMimeTypes.contains(detectedMimeType);

    if (!isValid) {
      debugPrint(
        'MIME validation failed for ${file.name}: '
            'Expected ${allowedMimeTypes.join(" or ")}, got $detectedMimeType',
      );
    }

    return isValid;
  }

  /// Detects MIME type from file signature (magic bytes)
  String? _detectMimeType(Uint8List bytes, String extension) {
    if (bytes.isEmpty) return null;

    // PDF signature: %PDF
    if (bytes.length >= 4 &&
        bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46) {
      return 'application/pdf';
    }

    // JPEG signature: FF D8 FF
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }

    // PNG signature: 89 50 4E 47 0D 0A 1A 0A
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return 'image/png';
    }

    // Excel (.xls) signature - old format: D0 CF 11 E0 A1 B1 1A E1
    if (bytes.length >= 8 &&
        bytes[0] == 0xD0 &&
        bytes[1] == 0xCF &&
        bytes[2] == 0x11 &&
        bytes[3] == 0xE0 &&
        bytes[4] == 0xA1 &&
        bytes[5] == 0xB1 &&
        bytes[6] == 0x1A &&
        bytes[7] == 0xE1) {
      return 'application/vnd.ms-excel';
    }

    // Office Open XML formats (.xlsx, .docx) - ZIP signature: 50 4B
    if (bytes.length >= 4 &&
        bytes[0] == 0x50 &&
        bytes[1] == 0x4B &&
        (bytes[2] == 0x03 || bytes[2] == 0x05 || bytes[2] == 0x07) &&
        (bytes[3] == 0x04 || bytes[3] == 0x06 || bytes[3] == 0x08)) {
      return _detectOfficeOpenXmlType(bytes, extension);
    }

    return null;
  }

  /// Distinguishes between xlsx and docx files
  String? _detectOfficeOpenXmlType(Uint8List bytes, String extension) {
    try {
      // Convert a portion of bytes to string to search for content type markers
      final searchLength = bytes.length > 2000 ? 2000 : bytes.length;
      final str = String.fromCharCodes(bytes.take(searchLength));

      // Check for Word document markers
      final hasWordMarkers =
          str.contains('word/') || str.contains('word\\') || str.contains('w:document');

      // Check for Excel markers
      final hasExcelMarkers =
          str.contains('xl/') || str.contains('xl\\') || str.contains('xl/worksheets');

      // Validate based on extension
      if (extension == 'docx') {
        if (hasWordMarkers && !hasExcelMarkers) {
          return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        }
      } else if (extension == 'xlsx') {
        if (hasExcelMarkers && !hasWordMarkers) {
          return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
        }
      }

      debugPrint('Could not validate Office Open XML type for extension: $extension');
      return null;
    } catch (e) {
      debugPrint('Error detecting Office XML type: $e');
      return null;
    }
  }

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
      // Use passed extensions OR default ones
      final extensions = (widget.allowedExtensions ??
          ['xls', 'xlsx', 'docx', 'pdf', 'jpg', 'png'])
          .map((e) => e.toLowerCase())
          .toList();

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
        allowMultiple: true,
        withData: true, // REQUIRED for MIME validation
      );

      if (result != null && result.files.isNotEmpty) {
        // 🔒 Validate MIME types for all selected files
        final validFiles = <PlatformFile>[];
        final invalidFiles = <String>[];

        for (final file in result.files) {
          if (_validateFileMimeType(file)) {
            validFiles.add(file);
          } else {
            invalidFiles.add(file.name);
          }
        }

        // Show error if any files failed validation
        if (invalidFiles.isNotEmpty) {
          _showInvalidFilesError(invalidFiles);
        }

        // Add valid files only
        if (validFiles.isNotEmpty) {
          setState(() {
            if (widget.maxFiles != null) {
              final remainingSlots = widget.maxFiles! - _selectedFiles.length;
              _selectedFiles.addAll(validFiles.take(remainingSlots));
            } else {
              _selectedFiles.addAll(validFiles);
            }
          });

          // Notify parent
          widget.onFilesChanged?.call(_selectedFiles);
        }
      }
    } catch (e) {
      debugPrint('Error picking files: $e');
      _showErrorDialog(
        'Upload Error',
        'An error occurred while uploading files. Please try again.',
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });

    // Notify parent
    widget.onFilesChanged?.call(_selectedFiles);
  }

  void _showMaxFilesError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Maximum ${widget.maxFiles} files allowed',
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFA6262),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showInvalidFilesError(List<String> invalidFiles) {
    final fileList = invalidFiles.length > 3
        ? '${invalidFiles.take(3).join(', ')} and ${invalidFiles.length - 3} more'
        : invalidFiles.join(', ');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Invalid File Type',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'The following file${invalidFiles.length > 1 ? 's do' : ' does'} not match '
              '${invalidFiles.length > 1 ? 'their' : 'its'} extension${invalidFiles.length > 1 ? 's' : ''}:\n\n'
              '$fileList\n\n'
              'Please upload genuine files with valid content.',
          style: const TextStyle(
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF59BF5C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF59BF5C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
    widget.onFilesChanged?.call(_selectedFiles);
  }
}