import './enum.dart';

class RoleStagePolicy {
  static const Map<UserRole, List<Stage>> allowedStages = {
    UserRole.user: [
      Stage.insuranceQuoteApproval, // 23
      Stage.emiApproval, // 25
      Stage.employeeFeedback, // 28
      Stage.declarationAcceptance, // 28
    ],
    UserRole.admin: [
      Stage.requested, // 20
      Stage.assignedToEsna, // 21
      Stage.emiCalculation, // 24
      Stage.paymentDetails, // 26
      Stage.rtoTaxReceipt, // 27
      Stage.assignedToInsurance, // 22
    ],
    UserRole.esna: [
      Stage.assignedToEsna, // 21
      Stage.emiCalculation, // 24
      Stage.paymentDetails, // 26
      Stage.rtoTaxReceipt, // 27
    ],
    UserRole.insurance: [
      Stage.assignedToInsurance, // 22
    ],
  };

  static bool canAccess(UserRole role, Stage stage) {
    return allowedStages[role]?.contains(stage) ?? false;
  }
}
