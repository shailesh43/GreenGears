import 'package:flutter/material.dart';
import './car_request.dart';

class SubmitByEsnaPaymentModel {
  final String message;
  final CarRequest updatedRequest;

  SubmitByEsnaPaymentModel({
    required this.message,
    required this.updatedRequest,
  });

  factory SubmitByEsnaPaymentModel.fromJson(Map<String, dynamic> json) {
    return SubmitByEsnaPaymentModel(
      message: json['message'] ?? '',
      updatedRequest: CarRequest.fromJson(json['updatedRequest']),
    );
  }
}
