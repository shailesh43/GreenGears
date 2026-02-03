import 'package:flutter/material.dart';

class UploadedFileModel {
  final String docId;
  final String path;
  final String fileName;
  final String refName;
  final int processStage;

  UploadedFileModel({
    required this.docId,
    required this.path,
    required this.fileName,
    required this.refName,
    required this.processStage,
  });

  factory UploadedFileModel.fromJson(Map<String, dynamic> json) {
    return UploadedFileModel(
      docId: json['doc_id'],
      path: json['path'],
      fileName: json['file_name'],
      refName: json['ref_name'],
      processStage: json['process_stage'],
    );
  }
}
