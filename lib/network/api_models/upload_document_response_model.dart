import 'package:flutter/material.dart';
import './uploaded_file_model.dart';

class UploadDocumentResponseModel {
  final String message;
  final List<UploadedFileModel> files;

  UploadDocumentResponseModel({
    required this.message,
    required this.files,
  });

  factory UploadDocumentResponseModel.fromJson(Map<String, dynamic> json) {
    return UploadDocumentResponseModel(
      message: json['message'],
      files: (json['files'] as List)
          .map((e) => UploadedFileModel.fromJson(e))
          .toList(),
    );
  }
}
