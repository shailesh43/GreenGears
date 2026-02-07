import 'package:flutter/material.dart';
import './car_request.dart';

class SubmitByEsnaEmi {
  final String message;
  final CarRequest updatedRequest;

  SubmitByEsnaEmi({
    required this.message,
    required this.updatedRequest,
  });

  factory SubmitByEsnaEmi.fromJson(Map<String, dynamic> json) {
    return SubmitByEsnaEmi(
      message: json['message'] ?? '',
      updatedRequest: CarRequest.fromJson(json['updatedRequest']),
    );
  }
}
