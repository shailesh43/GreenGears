import 'package:flutter/material.dart';
import './car_request.dart';

class UserFeedbackModel {
  final String message;
  final CarRequest updatedRequest;

  UserFeedbackModel({
    required this.message,
    required this.updatedRequest,
  });

  factory UserFeedbackModel.fromJson(Map<String, dynamic> json) {
    return UserFeedbackModel(
      message: json['message'] ?? '',
      updatedRequest: CarRequest.fromJson(json['updatedRequest']),
    );
  }
}
