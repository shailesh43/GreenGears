import 'package:collection/collection.dart';

/// --------------------
/// USER ROLES
/// --------------------
enum UserRole {
  user(1, 'User'),
  centralAdmin(2, 'Central Admin'),
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

/// --------------------
/// REQUEST STATUS (LIFECYCLE)
/// --------------------
enum RequestStatus {
  active(1, 'Active'),
  inProcess(31, 'In Process'),
  terminatedByAdmin(82, 'Terminated by Admin'),
  deletedByUser(110, 'Deleted by User'),
  inactive(120, 'Inactive');

  final int code;
  final String label;

  const RequestStatus(this.code, this.label);

  static RequestStatus? fromCode(int code) {
    return RequestStatus.values.firstWhereOrNull(
          (e) => e.code == code,
    );
  }

  /// Convenience helpers
  bool get isActive =>
      this == RequestStatus.active || this == RequestStatus.inProcess;

  bool get isInactive =>
      this == RequestStatus.terminatedByAdmin ||
          this == RequestStatus.deletedByUser ||
          this == RequestStatus.inactive;
}

/// --------------------
/// PROCESS STAGES (WORKFLOW)
/// --------------------
enum Stage {
  requested(20, 'Requested'),
  assignedToEsna(21, 'Assigned to ES&A'),
  assignedToInsurance(22, 'Assigned to Insurance'),
  insuranceQuoteApproval(23, 'Insurance Quote Approval'),
  emiCalculation(24, 'EMI Calculation'),
  emiApproval(25, 'EMI Approval (User)'),
  paymentDetails(26, 'Payment Details (ES&A)'),
  rtoTaxReceipt(27, 'RTO Tax Receipt (ES&A)'),
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
