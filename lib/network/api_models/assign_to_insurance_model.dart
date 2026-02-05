import 'package:flutter/material.dart';
import './car_request.dart';

class AssignToInsuranceModel {
  final String message;
  final CarRequest updatedRequest;

  AssignToInsuranceModel({
    required this.message,
    required this.updatedRequest,
  });

  factory AssignToInsuranceModel.fromJson(Map<String, dynamic> json) {
    return AssignToInsuranceModel(
      message: json['message'] ?? '',
      updatedRequest: CarRequest.fromJson(json['updatedRequest']),
    );
  }
}
