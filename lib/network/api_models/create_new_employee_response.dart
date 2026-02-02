import 'package:flutter/material.dart';

class CreateNewEmployeeResponse {
  final String message;
  final Map<String, dynamic> data;

  CreateNewEmployeeResponse({
    required this.message,
    required this.data,
  });

  factory CreateNewEmployeeResponse.fromJson(Map<String, dynamic> json) {
    return CreateNewEmployeeResponse(
      message: json['message'],
      data: json['data'],
    );
  }
}
