import 'package:flutter/material.dart';
import './car_request.dart';

class SubmitByEsnaReceiptModel {
  final String message;
  final CarRequest updatedRequest;

  SubmitByEsnaReceiptModel({
    required this.message,
    required this.updatedRequest,
  });

  factory SubmitByEsnaReceiptModel.fromJson(Map<String, dynamic> json) {
    return SubmitByEsnaReceiptModel(
      message: json['message'] ?? '',
      updatedRequest: CarRequest.fromJson(json['updatedRequest']),
    );
  }
}
