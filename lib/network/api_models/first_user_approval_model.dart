import 'package:flutter/material.dart';
import './car_request.dart';

class FirstUserApprovalModel {
  final String message;
  final CarRequest updatedRequest;

  FirstUserApprovalModel({
    required this.message,
    required this.updatedRequest,
  });

  factory FirstUserApprovalModel.fromJson(Map<String, dynamic> json) {
    return FirstUserApprovalModel(
      message: json['message'] ?? '',
      updatedRequest: CarRequest.fromJson(json['updatedRequest']),
    );
  }
}
