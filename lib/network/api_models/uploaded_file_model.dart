import 'package:flutter/material.dart';

class UploadedFileModel {
  final int udId;
  final int docId;
  final String path;
  final String fileName;
  final String refName;
  final int processStage;
  final String downloadUrl;

  UploadedFileModel({
    required this.udId,
    required this.docId,
    required this.path,
    required this.fileName,
    required this.refName,
    required this.processStage,
    required this.downloadUrl,
  });

  factory UploadedFileModel.fromJson(Map<String, dynamic> json) {
    return UploadedFileModel(
      udId: json['ud_id'] as int,
      docId: json['doc_id'] as int,
      path: json['path'] as String,
      fileName: json['file_name'] as String,
      refName: json['ref_name'] as String,
      processStage: json['process_stage'] as int,
      downloadUrl: json['downloadUrl'] as String,
    );
  }
}