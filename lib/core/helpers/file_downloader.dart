import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// A utility class providing reusable file download functionality.
///
/// This helper handles downloading files from presigned URLs (typically S3)
/// and opening them with the system's default viewer, bypassing browser
/// MIME-type issues that can occur on iOS Safari.
class FileDownloader {
  /// Strips the leading timestamp prefix (e.g. "1748941631668_") by dropping
  /// everything up to and including the first '_'.
  static String displayFileName(String raw) {
    final idx = raw.indexOf('_');
    if (idx != -1 && idx < raw.length - 1) {
      return raw.substring(idx + 1);
    }
    return raw;
  }

  /// Returns a short label for the file type based on extension.
  static String fileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return 'PDF';
      case 'xlsx':
      case 'xls':
        return 'XLS';
      default:
        return 'DOC';
    }
  }

  /// Returns a color for the file type based on extension.
  static Color fileColor(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return const Color(0xFFE53935);
      case 'xlsx':
      case 'xls':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF1565C0);
    }
  }

  /// Downloads a presigned S3 URL using Dio so we control the filename
  /// ourselves — bypassing iOS Safari's broken MIME sniffing from the
  /// `response-content-type` presigned param (which can wrongly report
  /// `.xlsx` for a `.pdf`, or vice-versa, causing Safari to rename the file).
  ///
  /// Steps:
  ///  1. Extract the true filename from the S3 path segment (before `?`).
  ///  2. Download raw bytes via Dio (no browser involved).
  ///  3. Save to the app's temp directory with the correct filename.
  ///  4. Open with open_filex so the OS picks the right viewer.
  ///
  /// Parameters:
  ///  - [context]: BuildContext for showing snackbars
  ///  - [presignedUrl]: The full presigned URL from S3
  ///  - [rawFileName]: The original filename (with timestamp prefix)
  ///  - [showProgress]: Whether to show download progress snackbar (default: true)
  static Future<void> downloadAndOpenFile({
    required BuildContext context,
    required String presignedUrl,
    required String rawFileName,
    bool showProgress = true,
  }) async {
    // 1️⃣  Derive the correct filename from the S3 path, not from the
    //     presigned content-type param which may be wrong.
    final trueFileName = displayFileName(rawFileName);

    // Show a progress snackbar
    if (showProgress && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Downloading $trueFileName…',
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          duration: const Duration(seconds: 30),
        ),
      );
    }

    try {
      // 2️⃣  Download bytes via Dio — this hits S3 directly with all the
      //     presigned auth params intact, no browser/WebView in the loop.
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/$trueFileName';

      await Dio().download(
        presignedUrl,
        savePath,
        options: Options(
          // Tell Dio to treat the response as binary regardless of
          // what content-type S3 sends back.
          responseType: ResponseType.bytes,
        ),
      );

      // 3️⃣  Open the saved file with the OS default viewer.
      if (!context.mounted) return;
      if (showProgress) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      final result = await OpenFilex.open(savePath);

      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open file: ${result.message}',
              style: const TextStyle(fontFamily: 'Inter'),
            ),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      if (showProgress) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Download failed: $e',
            style: const TextStyle(fontFamily: 'Inter'),
          ),
        ),
      );
      debugPrint('Download error: $e');
    }
  }
}