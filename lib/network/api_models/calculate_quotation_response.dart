import 'package:flutter/material.dart';
import './vehicle_quotation_model.dart';

class CalculateQuotationResponse {
  final String message;
  final VehicleQuotationModel vehicleQuotation;

  CalculateQuotationResponse({
    required this.message,
    required this.vehicleQuotation,
  });

  factory CalculateQuotationResponse.fromJson(
      Map<String, dynamic> json) {
    return CalculateQuotationResponse(
      message: json['message'] as String,
      vehicleQuotation: VehicleQuotationModel.fromJson(
        json['vehicleQuotation'] as Map<String, dynamic>,
      ),
    );
  }
}