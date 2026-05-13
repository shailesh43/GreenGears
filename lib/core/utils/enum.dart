import 'package:collection/collection.dart';

// USER ROLES
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

// PROCESS STAGES (request-flow)
enum Stage {
  requested(20, 'Requested'),
  assignedToEsna(21, 'Assigned to ES&A'),
  assignedToInsurance(22, 'Assigned to Insurance'),
  insuranceQuoteApproval(23, 'Insurance Quote Approval'),
  emiCalculation(24, 'EMI Calculation'),
  emiApproval(25, 'EMI Approval User'),
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

// Document Upload (stages)
enum Document {
  initialQuotationDoc(1, 'Initial quotation Document'),
  esnaUploadDoc(2, 'ES&A Upload Document'),
  insuranceSupportDoc(3, 'GIT(Insurance Support Document)'),
  insuranceQuoteApprovalDoc(4, 'Insurance Quote Approval Document'),
  emiCalculationDoc(5, 'EMI Calculation Document'),
  emiApprovalDoc(6, 'EMI Approval (User) Document'),
  paymentDetailsDoc(7, 'Payment Details (ES&A) Document'),
  rtoTaxReceiptDoc(8, 'RTO Tax Receipt (ES&A) Document'),
  otherDoc(9, 'Other Document');

  final int docId;
  final String docLabel;

  const Document(this.docId, this.docLabel);

  static Document? fromDocId(int docId) {
    return Document.values.firstWhereOrNull(
          (e) => e.docId == docId,
    );
  }
}
