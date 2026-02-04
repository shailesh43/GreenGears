import 'package:flutter/material.dart';
import './car_request.dart';
import './employee_profile_data.dart';

class AssignEsnaSpocModel {
  final String message;
  final CarRequest updatedRequest;
  final EmployeeProfileData employeeDetails;

  AssignEsnaSpocModel({
    required this.message,
    required this.updatedRequest,
    required this.employeeDetails,
  });

  factory AssignEsnaSpocModel.fromJson(Map<String, dynamic> json) {
    return AssignEsnaSpocModel(
      message: json['message'] ?? '',
      updatedRequest: CarRequest.fromJson(json['updatedRequest']),
      employeeDetails: EmployeeProfileData.fromJson(json['employeeDetails']),
    );
  }
}
