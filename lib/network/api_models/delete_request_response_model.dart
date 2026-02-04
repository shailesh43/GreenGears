import 'package:flutter/material.dart';

class DeleteRequestResponseModel {
  final String message;
  final int updatedStatus;

  DeleteRequestResponseModel({
    required this.message,
    required this.updatedStatus,
  });

  factory DeleteRequestResponseModel.fromJson(Map<String, dynamic> json) {
    return DeleteRequestResponseModel(
      message: json['message'],
      updatedStatus: json['updatedStatus'],
    );
  }
}