import 'package:flutter/material.dart';
import './car_request.dart';

class SecondUserApprovalModel {
  final String message;
  final CarRequest updatedRequest;

  SecondUserApprovalModel({
    required this.message,
    required this.updatedRequest,
  });

  factory SecondUserApprovalModel.fromJson(Map<String, dynamic> json) {
    return SecondUserApprovalModel(
      message: json['message'] ?? '',
      updatedRequest: CarRequest.fromJson(json['updatedRequest']),
    );
  }
}
