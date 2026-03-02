import 'package:flutter/material.dart';

class VehicleQuotationModel {
  final int id;
  final String baseCost;
  final String sgstPercentage;
  final String cgstPercentage;
  final String cessPercentage;
  final String sgstAmount;
  final String cgstAmount;
  final String cessAmount;
  final String exShowroomPrice;
  final String tcs;
  final String registrationAmount;
  final String additionalAccessories;
  final String miscellaneous;
  final String finalQuotationAmount;
  final int? requestId;
  final String empId;
  final DateTime createdAt;

  VehicleQuotationModel({
    required this.id,
    required this.baseCost,
    required this.sgstPercentage,
    required this.cgstPercentage,
    required this.cessPercentage,
    required this.sgstAmount,
    required this.cgstAmount,
    required this.cessAmount,
    required this.exShowroomPrice,
    required this.tcs,
    required this.registrationAmount,
    required this.additionalAccessories,
    required this.miscellaneous,
    required this.finalQuotationAmount,
    required this.requestId,
    required this.empId,
    required this.createdAt,
  });

  factory VehicleQuotationModel.fromJson(Map<String, dynamic> json) {
    return VehicleQuotationModel(
      id: json['id'] as int,
      baseCost: json['base_cost'] as String,
      sgstPercentage: json['sgst_percentage'] as String,
      cgstPercentage: json['cgst_percentage'] as String,
      cessPercentage: json['cess_percentage'] as String,
      sgstAmount: json['sgst_amount'] as String,
      cgstAmount: json['cgst_amount'] as String,
      cessAmount: json['cess_amount'] as String,
      exShowroomPrice: json['ex_showroom_price'] as String,
      tcs: json['tcs'] as String,
      registrationAmount: json['registration_amount'] as String,
      additionalAccessories: json['additional_accessories'] as String,
      miscellaneous: json['miscellaneous'] as String,
      finalQuotationAmount: json['final_quotation_amount'] as String,
      requestId: json['request_id'] as int?,
      empId: json['emp_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}