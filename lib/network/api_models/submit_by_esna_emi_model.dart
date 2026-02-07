import 'package:flutter/material.dart';
import './car_request.dart';

class SubmitByEsnaEmiModel {
  final String message;
  final CarRequest updatedRequest;

  SubmitByEsnaEmiModel({
    required this.message,
    required this.updatedRequest,
  });

  factory SubmitByEsnaEmiModel.fromJson(Map<String, dynamic> json) {
    return SubmitByEsnaEmiModel(
      message: json['message'] ?? '',
      updatedRequest: CarRequest.fromJson(json['updatedRequest']),
    );
  }
}
