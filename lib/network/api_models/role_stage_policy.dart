class RoleStagePolicy {
  static const Map<UserRole, List<Stage>> allowedStages = {
    UserRole.user: [
      Stage.requested,
      Stage.insuranceQuoteApproval,
      Stage.emiApproval,
      Stage.employeeFeedback,
      Stage.declarationAcceptance,
    ],
    UserRole.admin: [
      Stage.assignedToEsna,
    ],
    UserRole.esna: [
      Stage.esnaProcessing,
      Stage.emiCalculation,
      Stage.paymentDetails,
      Stage.rtoTaxReceipt,
    ],
    UserRole.insurance: [
      Stage.insuranceProcessing,
    ],
  };

  static bool canAccess(UserRole role, Stage stage) {
    return allowedStages[role]?.contains(stage) ?? false;
  }
}
