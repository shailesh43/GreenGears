import './car_request.dart';

class InsuranceQuoteApprovalModel {
  final String message;
  final CarRequest updatedCarRequest;
  final UpdatedComments updatedComments;

  InsuranceQuoteApprovalModel({
    required this.message,
    required this.updatedCarRequest,
    required this.updatedComments,
  });

  factory InsuranceQuoteApprovalModel.fromJson(Map<String, dynamic> json) {
    return InsuranceQuoteApprovalModel(
      message: json['message'] ?? '',
      updatedCarRequest: CarRequest.fromJson(
        json['updatedCarRequest'] ?? {},
      ),
      updatedComments: UpdatedComments.fromJson(
        json['updatedComments'] ?? {},
      ),
    );
  }
}


class UpdatedComments {
  final String reqId;
  final String insuranceQuoteApprovalUser;

  UpdatedComments({
    required this.reqId,
    required this.insuranceQuoteApprovalUser,
  });

  factory UpdatedComments.fromJson(Map<String, dynamic> json) {
    return UpdatedComments(
      reqId: json['req_id'] ?? '',
      insuranceQuoteApprovalUser: json['insurance_quote_approval_user'] ?? '',
    );
  }
}
