import 'package:flutter/material.dart';

class CreateVehicleResponseModel {
  final String message;
  final String requestId;
  final Map<String, dynamic> data;

  CreateVehicleResponseModel({
    required this.message,
    required this.requestId,
    required this.data,
  });

  factory CreateVehicleResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateVehicleResponseModel(
      message: json['message'],
      requestId: json['request_id'],
      data: json['data'],
    );
  }
}
