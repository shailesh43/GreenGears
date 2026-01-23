import 'package:collection/collection.dart';

enum UserRole {
  user(1, 'User'),
  esna(3, 'ES&A'),
  insurance(4, 'Insurance'),
  admin(5, 'Admin');

  final int id;
  final String label;

  const UserRole(this.id, this.label);

  static UserRole? fromId(int id) {
    return UserRole.values.firstWhereOrNull((e) => e.id == id);
  }
}


enum Stage {
  requested(20, 'Requested'),
  assignedToEsna(21, 'Assigned to ES&A'),
  esnaProcessing(21, 'ES&A Processing'),
  insuranceProcessing(22, 'Insurance Processing'),
  insuranceQuoteApproval(23, 'Insurance Quote Approval'),
  emiCalculation(24, 'EMI Calculation'),
  emiApproval(25, 'EMI Approval Letter'),
  paymentDetails(26, 'Payment Details'),
  rtoTaxReceipt(27, 'RTO Tax Receipt'),
  employeeFeedback(28, 'Employee Feedback'),
  declarationAcceptance(29, 'Declaration Acceptance'),
  deletedByUser(110, 'Deleted by User'),
  inactive(120, 'Inactive');

  final int stageNo;
  final String label;

  const Stage(this.stageNo, this.label);

  static Stage? fromStageNo(int stageNo) {
    return Stage.values.firstWhereOrNull(
          (e) => e.stageNo == stageNo,
    );
  }
}
