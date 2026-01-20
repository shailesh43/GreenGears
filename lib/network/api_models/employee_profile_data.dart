class EmployeeProfileData {
  // =========================
  // Core Employee Info
  // =========================
  String? sapEmpNo;
  String? sapEmpSalutation;
  String? sapEmpSalutationDesc;
  String? sapLastName;
  String? sapFirstName;
  String? sapMiddleName;
  String? sapShortName;
  String? sapShortNameModify;
  String? sapDispName;

  String? sapGender;
  String? sapGenderDesc;
  String? sapReligion;
  String? sapReligionDesc;

  DateTime? sapDob;

  // =========================
  // Dates of Joining
  // =========================
  DateTime? sapDojTemp;
  DateTime? sapDojTrainee;
  DateTime? sapDojWc;
  DateTime? sapDojTf;
  DateTime? sapDojPerm;
  DateTime? sapDojTpgr;
  DateTime? sapDojTatagr;

  // =========================
  // Org / Business
  // =========================
  String? sapBusinessArea;
  String? sapBusinessAreaDesc;
  String? sapOrgUnit;
  String? sapOrgUnitDesc;
  String? sapPersSubArea;
  String? sapPersSubAreaDesc;
  String? sapPersArea;
  String? sapPersAreaDesc;
  String? sapCostCenter;
  String? sapCostCenterDesc;
  String? sapCompany;
  String? sapCompanyDesc;

  String? sapEmpCategory;
  String? sapEmpCategoryDesc;
  String? sapCurrGrade;
  String? sapCurrGradeDesc;
  String? sapCurrPosition;
  String? sapCurrPositionDesc;
  String? sapCurrJob;
  String? sapCurrJobDesc;

  // =========================
  // Payroll / Finance
  // =========================
  String? sapControllingArea;
  String? sapControllingAreaDesc;
  double? sapBasic;
  String? sapPayrollArea;

  // =========================
  // Contact
  // =========================
  String? sapEmail;
  String? sapMobileNo;
  String? sapIsdCode;
  String? pcell;
  String? exten;

  // =========================
  // Separation
  // =========================
  DateTime? sapSeperationDate;
  String? sapSeperationReason;
  DateTime? sapRetirementDate;

  // =========================
  // Manager / HR
  // =========================
  String? sapEmpMgr;
  String? sapEmpMgrEmailid;
  String? sapEmpFunMgr;
  String? sapFunMgrEmailid;
  String? sapFunMgrName;

  // =========================
  // Status / Actions
  // =========================
  String? sapActionType;
  String? sapActionTypeText;
  String? sapActionReason;
  String? sapActionReasonText;
  String? sapEmployeeStatusCode;
  String? sapEmployeeStatusText;

  // =========================
  // Division / Section
  // =========================
  String? sapDivisionCode;
  String? sapDivisionText;
  String? sapSectionCode;
  String? sapSectionText;
  String? sapFunctionArea;
  String? sapFunctionAreaText;

  // =========================
  // Location
  // =========================
  String? workLocationCode;
  String? workLocationDescription;
  String? workLongTxt;

  // =========================
  // HR / Misc
  // =========================
  String? sapChangedBy;
  DateTime? sapChangedOn;
  String? sapSedEmpNo;
  String? sapData;
  String? sapPrevEmpNo;

  String? hrisGstStateCode;
  String? hrisFatherHusband;
  String? hrisMaritalstatus;
  String? hrisMaritalstatusDesc;
  DateTime? hrisDateofmarriage;

  String? hrclCode;
  String? hrclText;
  String? omclCode;
  String? omclText;
  String? sbuCode;
  String? sbuText;

  String? divHrId;
  String? divHrName;
  String? divHeadHrId;
  String? divHeadHrName;
  String? cluHeadHrId;
  String? cluHeadHrName;

  // =========================
  // Constructor
  // =========================
  EmployeeProfileData();

  // =========================
  // Safe Parsers
  // =========================
  static String? _str(dynamic v) {
    if (v == null) return null;
    return v.toString();
  }

  static DateTime? _date(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  static double? _double(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  // =========================
  // fromJson
  // =========================
  EmployeeProfileData.fromJson(Map<String, dynamic> json) {
    sapEmpNo = _str(json['sap_emp_no']);
    sapEmpSalutation = _str(json['sap_emp_salutation']);
    sapEmpSalutationDesc = _str(json['sap_emp_salutation_desc']);
    sapLastName = _str(json['sap_last_name']);
    sapFirstName = _str(json['sap_first_name']);
    sapMiddleName = _str(json['sap_middle_name']);
    sapShortName = _str(json['sap_short_name']);
    sapShortNameModify = _str(json['sap_short_name_modify']);
    sapDispName = _str(json['sap_disp_name']);

    sapGender = _str(json['sap_gender']);
    sapGenderDesc = _str(json['sap_gender_desc']);
    sapReligion = _str(json['sap_religion']);
    sapReligionDesc = _str(json['sap_religion_desc']);

    sapDob = _date(json['sap_dob']);

    sapDojTemp = _date(json['sap_doj_temp']);
    sapDojTrainee = _date(json['sap_doj_trainee']);
    sapDojWc = _date(json['sap_doj_wc']);
    sapDojTf = _date(json['sap_doj_tf']);
    sapDojPerm = _date(json['sap_doj_perm']);
    sapDojTpgr = _date(json['sap_doj_tpgr']);
    sapDojTatagr = _date(json['sap_doj_tatagr']);

    sapBusinessArea = _str(json['sap_business_area']);
    sapBusinessAreaDesc = _str(json['sap_business_area_desc']);
    sapOrgUnit = _str(json['sap_org_unit']);
    sapOrgUnitDesc = _str(json['sap_org_unit_desc']);
    sapPersSubArea = _str(json['sap_pers_sub_area']);
    sapPersSubAreaDesc = _str(json['sap_pers_sub_area_desc']);
    sapPersArea = _str(json['sap_pers_area']);
    sapPersAreaDesc = _str(json['sap_pers_area_desc']);
    sapCostCenter = _str(json['sap_cost_center']);
    sapCostCenterDesc = _str(json['sap_cost_center_desc']);
    sapCompany = _str(json['sap_company']);
    sapCompanyDesc = _str(json['sap_company_desc']);

    sapEmpCategory = _str(json['sap_emp_category']);
    sapEmpCategoryDesc = _str(json['sap_emp_category_desc']);
    sapCurrGrade = _str(json['sap_curr_grade']);
    sapCurrGradeDesc = _str(json['sap_curr_grade_desc']);
    sapCurrPosition = _str(json['sap_curr_position']);
    sapCurrPositionDesc = _str(json['sap_curr_position_desc']);
    sapCurrJob = _str(json['sap_curr_job']);
    sapCurrJobDesc = _str(json['sap_curr_job_desc']);

    sapControllingArea = _str(json['sap_controlling_area']);
    sapControllingAreaDesc = _str(json['sap_controlling_area_desc']);
    sapBasic = _double(json['sap_basic']);
    sapPayrollArea = _str(json['sap_payroll_area']);

    sapEmail = _str(json['sap_email']);
    sapMobileNo = _str(json['sap_mobile_no']);
    sapIsdCode = _str(json['sap_isd_code']);
    pcell = _str(json['pcell']);
    exten = _str(json['exten']);

    sapSeperationDate = _date(json['sap_seperation_date']);
    sapSeperationReason = _str(json['sap_seperation_reason']);
    sapRetirementDate = _date(json['sap_retirement_date']);

    sapEmpMgr = _str(json['sap_emp_mgr']);
    sapEmpMgrEmailid = _str(json['sap_emp_mgr_emailid']);
    sapEmpFunMgr = _str(json['sap_emp_fun_mgr']);
    sapFunMgrEmailid = _str(json['sap_fun_mgr_emailid']);
    sapFunMgrName = _str(json['sap_fun_mgr_name']);

    sapActionType = _str(json['sap_action_type']);
    sapActionTypeText = _str(json['sap_action_type_text']);
    sapActionReason = _str(json['sap_action_reason']);
    sapActionReasonText = _str(json['sap_action_reason_text']);
    sapEmployeeStatusCode = _str(json['sap_employee_status_code']);
    sapEmployeeStatusText = _str(json['sap_employee_status_text']);

    sapDivisionCode = _str(json['sap_division_code']);
    sapDivisionText = _str(json['sap_division_text']);
    sapSectionCode = _str(json['sap_section_code']);
    sapSectionText = _str(json['sap_section_text']);
    sapFunctionArea = _str(json['sap_function_area']);
    sapFunctionAreaText = _str(json['sap_function_area_text']);

    workLocationCode = _str(json['work_location_code']);
    workLocationDescription = _str(json['work_location_description']);
    workLongTxt = _str(json['work_long_txt']);

    sapChangedBy = _str(json['sap_changed_by']);
    sapChangedOn = _date(json['sap_changed_on']);
    sapSedEmpNo = _str(json['sap_sed_emp_no']);
    sapData = _str(json['sap_data']);
    sapPrevEmpNo = _str(json['sap_prev_emp_no']);

    hrisGstStateCode = _str(json['hris_gst_state_code']);
    hrisFatherHusband = _str(json['hris_father_husband']);
    hrisMaritalstatus = _str(json['hris_maritalstatus']);
    hrisMaritalstatusDesc = _str(json['hris_maritalstatus_desc']);
    hrisDateofmarriage = _date(json['hris_dateofmarriage']);

    hrclCode = _str(json['hrcl_code']);
    hrclText = _str(json['hrcl_text']);
    omclCode = _str(json['omcl_code']);
    omclText = _str(json['omcl_text']);
    sbuCode = _str(json['sbu_code']);
    sbuText = _str(json['sbu_text']);

    divHrId = _str(json['div_hr_id']);
    divHrName = _str(json['div_hr_name']);
    divHeadHrId = _str(json['div_head_hr_id']);
    divHeadHrName = _str(json['div_head_hr_name']);
    cluHeadHrId = _str(json['clu_head_hr_id']);
    cluHeadHrName = _str(json['clu_head_hr_name']);
  }
}
