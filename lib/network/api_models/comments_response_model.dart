import 'package:flutter/material.dart';

class CommentsResponseModel {
  final String message;
  final CommentsData data;

  CommentsResponseModel({
    required this.message,
    required this.data,
  });

  factory CommentsResponseModel.fromJson(Map<String, dynamic> json) {
    return CommentsResponseModel(
      message: json['message'] ?? '',
      data: CommentsData.fromJson(json['data'] ?? {}),
    );
  }
}

class CommentsData {
  final String? commentsAssignedToEsna;
  final String? commentsByUser;
  final String? insuranceQuoteApprovalUser;
  final String? commentsAssignedToGit;
  final String? commentsEmiCalculationEsna;
  final String? commentsEmiUserApproval;
  final String? commentsRtoTaxReceiptOtherDocsEsna;
  final String? commentsPaymentDetailsEsna;

  CommentsData({
    this.commentsAssignedToEsna,
    this.commentsByUser,
    this.insuranceQuoteApprovalUser,
    this.commentsAssignedToGit,
    this.commentsEmiCalculationEsna,
    this.commentsEmiUserApproval,
    this.commentsRtoTaxReceiptOtherDocsEsna,
    this.commentsPaymentDetailsEsna,
  });

  factory CommentsData.fromJson(Map<String, dynamic> json) {
    return CommentsData(
      commentsAssignedToEsna: json['comments_assigned_to_esna'],
      commentsByUser: json['comments_by_user'],
      insuranceQuoteApprovalUser: json['insurance_quote_approval_user'],
      commentsAssignedToGit: json['comments_assigned_to_git'],
      commentsEmiCalculationEsna: json['comments_emi_calculation_esna'],
      commentsEmiUserApproval: json['comments_emi_user_approval'],
      commentsRtoTaxReceiptOtherDocsEsna: json['comments_rto_tax_receipt_other_docs_esna'],
      commentsPaymentDetailsEsna: json['comments_payment_details_esna'],
    );
  }
}