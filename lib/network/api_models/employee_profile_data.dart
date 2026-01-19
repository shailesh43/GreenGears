class EmployeeProfileData {
  int? sapEmpNo;
  String? sapEmpSalutation;
  String? sapEmpSalutationDesc;
  String? sapLastName;
  String? sapFirstName;
  Null? sapMiddleName;
  String? sapShortName;
  String? sapGender;
  String? sapGenderDesc;
  String? sapReligion;
  String? sapReligionDesc;
  String? sapDob;
  Null? sapDojTemp;
  Null? sapDojTrainee;
  Null? sapDojWc;
  Null? sapDojTf;
  String? sapDojPerm;
  Null? sapBusinessArea;
  Null? sapBusinessAreaDesc;
  int? sapOrgUnit;
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
  int? sapCurrPosition;
  String? sapCurrPositionDesc;
  int? sapCurrJob;
  String? sapCurrJobDesc;
  String? sapShortNameModify;
  String? sapControllingArea;
  String? sapControllingAreaDesc;
  Null? sapBasic;
  Null? sapEmpQualification;
  String? sapEmail;
  Null? sapSeperationDate;
  Null? sapSeperationReason;
  String? sapChangedOn;
  String? sapChangedBy;
  Null? sapSedEmpNo;
  Null? sapData;
  String? sapDispName;
  String? sapPayrollArea;
  String? sapDojTpgr;
  Null? sapDojTatagr;
  Null? sapPrevEmpNo;
  String? sapRetirementDate;
  int? sapEmpMgr;
  String? sapEmpMgrEmailid;
  Null? sapEmpFunMgr;
  Null? sapFunMgrEmailid;
  String? sapActionType;
  String? sapActionTypeText;
  String? sapActionReason;
  String? sapActionReasonText;
  String? sapEmployeeStatusCode;
  String? sapEmployeeStatusText;
  int? sapDivisionCode;
  String? sapDivisionText;
  int? sapSectionCode;
  String? sapSectionText;
  Null? sapFunctionArea;
  Null? sapFunctionAreaText;
  String? workLocationCode;
  String? workLocationDescription;
  Null? sapIsdCode;
  String? sapMobileNo;
  Null? companyTransferDate;
  Null? sapFunMgrName;
  String? hrisGstStateCode;
  String? hrisFatherHusband;
  String? hrisMaritalstatus;
  String? hrisMaritalstatusDesc;
  Null? hrisDateofmarriage;
  String? pcell;
  Null? exten;
  String? workLongTxt;
  int? hrclCode;
  String? hrclText;
  Null? omclCode;
  Null? omclText;
  int? sbuCode;
  String? sbuText;
  int? divHrId;
  String? divHrName;
  int? divHeadHrId;
  String? divHeadHrName;
  int? cluHeadHrId;
  String? cluHeadHrName;

  EmployeeProfileData(
      {this.sapEmpNo,
        this.sapEmpSalutation,
        this.sapEmpSalutationDesc,
        this.sapLastName,
        this.sapFirstName,
        this.sapMiddleName,
        this.sapShortName,
        this.sapGender,
        this.sapGenderDesc,
        this.sapReligion,
        this.sapReligionDesc,
        this.sapDob,
        this.sapDojTemp,
        this.sapDojTrainee,
        this.sapDojWc,
        this.sapDojTf,
        this.sapDojPerm,
        this.sapBusinessArea,
        this.sapBusinessAreaDesc,
        this.sapOrgUnit,
        this.sapOrgUnitDesc,
        this.sapPersSubArea,
        this.sapPersSubAreaDesc,
        this.sapPersArea,
        this.sapPersAreaDesc,
        this.sapCostCenter,
        this.sapCostCenterDesc,
        this.sapCompany,
        this.sapCompanyDesc,
        this.sapEmpCategory,
        this.sapEmpCategoryDesc,
        this.sapCurrGrade,
        this.sapCurrGradeDesc,
        this.sapCurrPosition,
        this.sapCurrPositionDesc,
        this.sapCurrJob,
        this.sapCurrJobDesc,
        this.sapShortNameModify,
        this.sapControllingArea,
        this.sapControllingAreaDesc,
        this.sapBasic,
        this.sapEmpQualification,
        this.sapEmail,
        this.sapSeperationDate,
        this.sapSeperationReason,
        this.sapChangedOn,
        this.sapChangedBy,
        this.sapSedEmpNo,
        this.sapData,
        this.sapDispName,
        this.sapPayrollArea,
        this.sapDojTpgr,
        this.sapDojTatagr,
        this.sapPrevEmpNo,
        this.sapRetirementDate,
        this.sapEmpMgr,
        this.sapEmpMgrEmailid,
        this.sapEmpFunMgr,
        this.sapFunMgrEmailid,
        this.sapActionType,
        this.sapActionTypeText,
        this.sapActionReason,
        this.sapActionReasonText,
        this.sapEmployeeStatusCode,
        this.sapEmployeeStatusText,
        this.sapDivisionCode,
        this.sapDivisionText,
        this.sapSectionCode,
        this.sapSectionText,
        this.sapFunctionArea,
        this.sapFunctionAreaText,
        this.workLocationCode,
        this.workLocationDescription,
        this.sapIsdCode,
        this.sapMobileNo,
        this.companyTransferDate,
        this.sapFunMgrName,
        this.hrisGstStateCode,
        this.hrisFatherHusband,
        this.hrisMaritalstatus,
        this.hrisMaritalstatusDesc,
        this.hrisDateofmarriage,
        this.pcell,
        this.exten,
        this.workLongTxt,
        this.hrclCode,
        this.hrclText,
        this.omclCode,
        this.omclText,
        this.sbuCode,
        this.sbuText,
        this.divHrId,
        this.divHrName,
        this.divHeadHrId,
        this.divHeadHrName,
        this.cluHeadHrId,
        this.cluHeadHrName});

  EmployeeProfileData.fromJson(Map<String, dynamic> json) {
    sapEmpNo = json['sap_emp_no'];
    sapEmpSalutation = json['sap_emp_salutation'];
    sapEmpSalutationDesc = json['sap_emp_salutation_desc'];
    sapLastName = json['sap_last_name'];
    sapFirstName = json['sap_first_name'];
    sapMiddleName = json['sap_middle_name'];
    sapShortName = json['sap_short_name'];
    sapGender = json['sap_gender'];
    sapGenderDesc = json['sap_gender_desc'];
    sapReligion = json['sap_religion'];
    sapReligionDesc = json['sap_religion_desc'];
    sapDob = json['sap_dob'];
    sapDojTemp = json['sap_doj_temp'];
    sapDojTrainee = json['sap_doj_trainee'];
    sapDojWc = json['sap_doj_wc'];
    sapDojTf = json['sap_doj_tf'];
    sapDojPerm = json['sap_doj_perm'];
    sapBusinessArea = json['sap_business_area'];
    sapBusinessAreaDesc = json['sap_business_area_desc'];
    sapOrgUnit = json['sap_org_unit'];
    sapOrgUnitDesc = json['sap_org_unit_desc'];
    sapPersSubArea = json['sap_pers_sub_area'];
    sapPersSubAreaDesc = json['sap_pers_sub_area_desc'];
    sapPersArea = json['sap_pers_area'];
    sapPersAreaDesc = json['sap_pers_area_desc'];
    sapCostCenter = json['sap_cost_center'];
    sapCostCenterDesc = json['sap_cost_center_desc'];
    sapCompany = json['sap_company'];
    sapCompanyDesc = json['sap_company_desc'];
    sapEmpCategory = json['sap_emp_category'];
    sapEmpCategoryDesc = json['sap_emp_category_desc'];
    sapCurrGrade = json['sap_curr_grade'];
    sapCurrGradeDesc = json['sap_curr_grade_desc'];
    sapCurrPosition = json['sap_curr_position'];
    sapCurrPositionDesc = json['sap_curr_position_desc'];
    sapCurrJob = json['sap_curr_job'];
    sapCurrJobDesc = json['sap_curr_job_desc'];
    sapShortNameModify = json['sap_short_name_modify'];
    sapControllingArea = json['sap_controlling_area'];
    sapControllingAreaDesc = json['sap_controlling_area_desc'];
    sapBasic = json['sap_basic'];
    sapEmpQualification = json['sap_emp_qualification'];
    sapEmail = json['sap_email'];
    sapSeperationDate = json['sap_seperation_date'];
    sapSeperationReason = json['sap_seperation_reason'];
    sapChangedOn = json['sap_changed_on'];
    sapChangedBy = json['sap_changed_by'];
    sapSedEmpNo = json['sap_sed_emp_no'];
    sapData = json['sap_data'];
    sapDispName = json['sap_disp_name'];
    sapPayrollArea = json['sap_payroll_area'];
    sapDojTpgr = json['sap_doj_tpgr'];
    sapDojTatagr = json['sap_doj_tatagr'];
    sapPrevEmpNo = json['sap_prev_emp_no'];
    sapRetirementDate = json['sap_retirement_date'];
    sapEmpMgr = json['sap_emp_mgr'];
    sapEmpMgrEmailid = json['sap_emp_mgr_emailid'];
    sapEmpFunMgr = json['sap_emp_fun_mgr'];
    sapFunMgrEmailid = json['sap_fun_mgr_emailid'];
    sapActionType = json['sap_action_type'];
    sapActionTypeText = json['sap_action_type_text'];
    sapActionReason = json['sap_action_reason'];
    sapActionReasonText = json['sap_action_reason_text'];
    sapEmployeeStatusCode = json['sap_employee_status_code'];
    sapEmployeeStatusText = json['sap_employee_status_text'];
    sapDivisionCode = json['sap_division_code'];
    sapDivisionText = json['sap_division_text'];
    sapSectionCode = json['sap_section_code'];
    sapSectionText = json['sap_section_text'];
    sapFunctionArea = json['sap_function_area'];
    sapFunctionAreaText = json['sap_function_area_text'];
    workLocationCode = json['work_location_code'];
    workLocationDescription = json['work_location_description'];
    sapIsdCode = json['sap_isd_code'];
    sapMobileNo = json['sap_mobile_no'];
    companyTransferDate = json['company_transfer_date'];
    sapFunMgrName = json['sap_fun_mgr_name'];
    hrisGstStateCode = json['hris_gst_state_code'];
    hrisFatherHusband = json['hris_father_husband'];
    hrisMaritalstatus = json['hris_maritalstatus'];
    hrisMaritalstatusDesc = json['hris_maritalstatus_desc'];
    hrisDateofmarriage = json['hris_dateofmarriage'];
    pcell = json['pcell'];
    exten = json['exten'];
    workLongTxt = json['work_long_txt'];
    hrclCode = json['hrcl_code'];
    hrclText = json['hrcl_text'];
    omclCode = json['omcl_code'];
    omclText = json['omcl_text'];
    sbuCode = json['sbu_code'];
    sbuText = json['sbu_text'];
    divHrId = json['div_hr_id'];
    divHrName = json['div_hr_name'];
    divHeadHrId = json['div_head_hr_id'];
    divHeadHrName = json['div_head_hr_name'];
    cluHeadHrId = json['clu_head_hr_id'];
    cluHeadHrName = json['clu_head_hr_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sap_emp_no'] = this.sapEmpNo;
    data['sap_emp_salutation'] = this.sapEmpSalutation;
    data['sap_emp_salutation_desc'] = this.sapEmpSalutationDesc;
    data['sap_last_name'] = this.sapLastName;
    data['sap_first_name'] = this.sapFirstName;
    data['sap_middle_name'] = this.sapMiddleName;
    data['sap_short_name'] = this.sapShortName;
    data['sap_gender'] = this.sapGender;
    data['sap_gender_desc'] = this.sapGenderDesc;
    data['sap_religion'] = this.sapReligion;
    data['sap_religion_desc'] = this.sapReligionDesc;
    data['sap_dob'] = this.sapDob;
    data['sap_doj_temp'] = this.sapDojTemp;
    data['sap_doj_trainee'] = this.sapDojTrainee;
    data['sap_doj_wc'] = this.sapDojWc;
    data['sap_doj_tf'] = this.sapDojTf;
    data['sap_doj_perm'] = this.sapDojPerm;
    data['sap_business_area'] = this.sapBusinessArea;
    data['sap_business_area_desc'] = this.sapBusinessAreaDesc;
    data['sap_org_unit'] = this.sapOrgUnit;
    data['sap_org_unit_desc'] = this.sapOrgUnitDesc;
    data['sap_pers_sub_area'] = this.sapPersSubArea;
    data['sap_pers_sub_area_desc'] = this.sapPersSubAreaDesc;
    data['sap_pers_area'] = this.sapPersArea;
    data['sap_pers_area_desc'] = this.sapPersAreaDesc;
    data['sap_cost_center'] = this.sapCostCenter;
    data['sap_cost_center_desc'] = this.sapCostCenterDesc;
    data['sap_company'] = this.sapCompany;
    data['sap_company_desc'] = this.sapCompanyDesc;
    data['sap_emp_category'] = this.sapEmpCategory;
    data['sap_emp_category_desc'] = this.sapEmpCategoryDesc;
    data['sap_curr_grade'] = this.sapCurrGrade;
    data['sap_curr_grade_desc'] = this.sapCurrGradeDesc;
    data['sap_curr_position'] = this.sapCurrPosition;
    data['sap_curr_position_desc'] = this.sapCurrPositionDesc;
    data['sap_curr_job'] = this.sapCurrJob;
    data['sap_curr_job_desc'] = this.sapCurrJobDesc;
    data['sap_short_name_modify'] = this.sapShortNameModify;
    data['sap_controlling_area'] = this.sapControllingArea;
    data['sap_controlling_area_desc'] = this.sapControllingAreaDesc;
    data['sap_basic'] = this.sapBasic;
    data['sap_emp_qualification'] = this.sapEmpQualification;
    data['sap_email'] = this.sapEmail;
    data['sap_seperation_date'] = this.sapSeperationDate;
    data['sap_seperation_reason'] = this.sapSeperationReason;
    data['sap_changed_on'] = this.sapChangedOn;
    data['sap_changed_by'] = this.sapChangedBy;
    data['sap_sed_emp_no'] = this.sapSedEmpNo;
    data['sap_data'] = this.sapData;
    data['sap_disp_name'] = this.sapDispName;
    data['sap_payroll_area'] = this.sapPayrollArea;
    data['sap_doj_tpgr'] = this.sapDojTpgr;
    data['sap_doj_tatagr'] = this.sapDojTatagr;
    data['sap_prev_emp_no'] = this.sapPrevEmpNo;
    data['sap_retirement_date'] = this.sapRetirementDate;
    data['sap_emp_mgr'] = this.sapEmpMgr;
    data['sap_emp_mgr_emailid'] = this.sapEmpMgrEmailid;
    data['sap_emp_fun_mgr'] = this.sapEmpFunMgr;
    data['sap_fun_mgr_emailid'] = this.sapFunMgrEmailid;
    data['sap_action_type'] = this.sapActionType;
    data['sap_action_type_text'] = this.sapActionTypeText;
    data['sap_action_reason'] = this.sapActionReason;
    data['sap_action_reason_text'] = this.sapActionReasonText;
    data['sap_employee_status_code'] = this.sapEmployeeStatusCode;
    data['sap_employee_status_text'] = this.sapEmployeeStatusText;
    data['sap_division_code'] = this.sapDivisionCode;
    data['sap_division_text'] = this.sapDivisionText;
    data['sap_section_code'] = this.sapSectionCode;
    data['sap_section_text'] = this.sapSectionText;
    data['sap_function_area'] = this.sapFunctionArea;
    data['sap_function_area_text'] = this.sapFunctionAreaText;
    data['work_location_code'] = this.workLocationCode;
    data['work_location_description'] = this.workLocationDescription;
    data['sap_isd_code'] = this.sapIsdCode;
    data['sap_mobile_no'] = this.sapMobileNo;
    data['company_transfer_date'] = this.companyTransferDate;
    data['sap_fun_mgr_name'] = this.sapFunMgrName;
    data['hris_gst_state_code'] = this.hrisGstStateCode;
    data['hris_father_husband'] = this.hrisFatherHusband;
    data['hris_maritalstatus'] = this.hrisMaritalstatus;
    data['hris_maritalstatus_desc'] = this.hrisMaritalstatusDesc;
    data['hris_dateofmarriage'] = this.hrisDateofmarriage;
    data['pcell'] = this.pcell;
    data['exten'] = this.exten;
    data['work_long_txt'] = this.workLongTxt;
    data['hrcl_code'] = this.hrclCode;
    data['hrcl_text'] = this.hrclText;
    data['omcl_code'] = this.omclCode;
    data['omcl_text'] = this.omclText;
    data['sbu_code'] = this.sbuCode;
    data['sbu_text'] = this.sbuText;
    data['div_hr_id'] = this.divHrId;
    data['div_hr_name'] = this.divHrName;
    data['div_head_hr_id'] = this.divHeadHrId;
    data['div_head_hr_name'] = this.divHeadHrName;
    data['clu_head_hr_id'] = this.cluHeadHrId;
    data['clu_head_hr_name'] = this.cluHeadHrName;
    return data;
  }
}
