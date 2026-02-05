import 'package:flutter/material.dart';
import './car_request.dart';

class InsuranceQuoteApprovalModel {
  final String message;
  final CarRequest updatedRequest;

  InsuranceQuoteApprovalModel({
    required this.message,
    required this.updatedRequest,
  });

  factory InsuranceQuoteApprovalModel.fromJson(Map<String, dynamic> json) {
    return InsuranceQuoteApprovalModel(
      message: json['message'] ?? '',
      updatedRequest: CarRequest.fromJson(json['updatedRequest']),
    );
  }
}
