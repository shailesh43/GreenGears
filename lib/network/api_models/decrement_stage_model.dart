import 'package:flutter/material.dart';
class DecrementStageModel {

  final String message;
  final int updateStage;

  DecrementStageModel({
    required this.message,
    required this.updateStage,
  });

  factory DecrementStageModel.fromJson(Map<String, dynamic> json) {
    return DecrementStageModel(
      message: json['message'] ?? '',
      updateStage: json['updatedStage'] ?? '',
    );
  }
}
