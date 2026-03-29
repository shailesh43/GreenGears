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
  /// Only validates if the extension is in the allowedExtensions list
  bool _validateFileMimeType(PlatformFile file) {
    final extension = file.extension?.toLowerCase();
    if (extension == null) return false;

    // Check if this extension is in our whitelist
    final allowedMimeTypes = _mimeTypeWhitelist[extension];
    if (allowedMimeTypes == null) {
      // Extension not in whitelist - reject
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
              'Expected ${allowedMimeTypes.join(" or ")}, got $detectedMimeType'
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
      // Need to check deeper for xlsx vs docx based on extension hint
      return _detectOfficeOpenXmlType(bytes, extension);
    }

    return null;
  }

  /// Distinguishes between xlsx and docx files
  /// Uses extension as a hint and validates internal structure
  String? _detectOfficeOpenXmlType(Uint8List bytes, String extension) {
    try {
      // Convert a portion of bytes to string to search for content type markers
      final searchLength = bytes.length > 2000 ? 2000 : bytes.length;
      final str = String.fromCharCodes(bytes.take(searchLength));

      // Check for Word document markers
      final hasWordMarkers = str.contains('word/') ||
          str.contains('word\\') ||
          str.contains('w:document');

      // Check for Excel markers
      final hasExcelMarkers = str.contains('xl/') ||
          str.contains('xl\\') ||
          str.contains('xl/worksheets');

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

      // If we couldn't determine, return null (validation will fail)
      debugPrint('Could not validate Office Open XML type for extension: $extension');
      return null;

    } catch (e) {
      debugPrint('Error detecting Office XML type: $e');
      return null;
    }
  }

  Future<void> _pickFile() async {
    // Use passed extensions OR default ones
    final extensions = widget.allowedExtensions ??
        ['xls', 'xlsx', 'docx', 'pdf', 'jpg', 'png'];

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      withData: true, // REQUIRED for MIME validation
    );

    if (result != null) {
      final pickedFile = result.files.single;

      // 🔒 MIME Type Validation
      if (!_validateFileMimeType(pickedFile)) {
        final extensionUpper = pickedFile.extension?.toUpperCase() ?? 'this type';
        _showErrorDialog(
          'Invalid File Type',
          'The file "${pickedFile.name}" does not appear to be a valid $extensionUpper file. '
              'The file content does not match its extension. Please upload a genuine file.',
        );
        return;
      }

      setState(() {
        _selectedFile = pickedFile;
        _fileName = pickedFile.name;
      });

      // Send file to parent
      widget.onFileSelected?.call(pickedFile);
    }
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
