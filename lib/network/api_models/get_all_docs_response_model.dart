import 'package:flutter/material.dart';
import './uploaded_file_model.dart';

class GetAllDocsResponseModel {
  final String message;
  final List<UploadedFileModel> data;

  GetAllDocsResponseModel({
    required this.message,
    required this.data,
  });

  factory GetAllDocsResponseModel.fromJson(Map<String, dynamic> json) {
    return GetAllDocsResponseModel(
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => UploadedFileModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class UploadedDocData {
  final int? udId;
  final int? docId;
  final String? path;
  final String? fileName;
  final String? refName;
  final int? processStage;
  final String? error;

  UploadedDocData({
    this.udId,
    this.docId,
    this.path,
    this.fileName,
    this.refName,
    this.processStage,
    this.error,
  });

  factory UploadedDocData.fromJson(Map<String, dynamic> json) {
    return UploadedDocData(
      udId: json['ud_id'],
      docId: json['doc_id'],
      path: json['path'],
      fileName: json['file_name'],
      refName: json['ref_name'],
      processStage: json['process_stage'],
      error: json['error'],
    );
  }
}
