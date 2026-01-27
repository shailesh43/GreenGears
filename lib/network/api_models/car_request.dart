import '../../core/utils/enum.dart';
// import 'stage_bucket.dart';

class CarRequest {
  // --- Request core ---
  String? requestId;
  String? manufacturer;
  String? carModel;
  String? colorChoice;
  String? choiceOfLease;
  String? purpose;
  String? vehicleType;

  // --- Stage / status ---
  int? processStage;          // process_stage
  String? stageName;          // stage_name
  int? status;                // status
  String? recordStatusName;   // record_status_name

  // --- Financial ---
  double? quotation;
  int? coolingPeriod;
  int? completeEmiTenure;
  double? emiAmount;
  double? totalEmi;
  double? poValue;
  double? carAllowance;
  double? companyContribution;

  // --- Payment / PO ---
  String? poNumber;
  DateTime? poDateOfPayment;
  DateTime? paymentDate;
  String? utr;

  // --- Insurance ---
  double? baseInsurancePremium;
  double? addOnCoverTataPower;
  double? addOnSapphirePlus;
  double? finalInsuranceQuotation;
  DateTime? insuranceExpireOn;

  // --- Employee details ---
  String? empId;
  String? employeeName;
  String? grade;
  String? email;
  DateTime? dob;
  String? contact;
  String? company;
  String? workLocation;
  double? eligibility;
  String? costCentre;
  DateTime? retirementDate;

  // --- Audit ---
  int? updatedBy;
  DateTime? updatedTime;
  int? assignedTo;

  // --- Derived helpers ---
  Stage? stage;

  CarRequest.fromJson(Map<String, dynamic> json) {
    // Core
    requestId = json['request_id']?.toString();
    manufacturer = json['manufacturer'];
    carModel = json['car_model'];
    colorChoice = json['color_choice'];
    choiceOfLease = json['choice_of_lease'];
    purpose = json['purpose'];
    vehicleType = json['vehicle_type'];

    // Stage / status
    processStage = _int(json['process_stage']);
    stageName = json['stage_name'];
    status = _int(json['status']);
    recordStatusName = json['record_status_name'];

    // Financial
    quotation = _double(json['quotation']);
    coolingPeriod = _int(json['cooling_period']);
    completeEmiTenure = _int(json['complete_emi_tenure']);
    emiAmount = _double(json['emi_amount']);
    totalEmi = _double(json['total_emi']);
    poValue = _double(json['po_value']);
    carAllowance = _double(json['car_allowance']);
    companyContribution = _double(json['company_contribution']);

    // Payment / PO
    poNumber = json['po_number'];
    poDateOfPayment = _date(json['po_date_of_payment']);
    paymentDate = _date(json['payment_date']);
    utr = json['utr'];

    // Insurance
    baseInsurancePremium = _double(json['base_insurance_premium']);
    addOnCoverTataPower = _double(json['add_on_cover_tata_power']);
    addOnSapphirePlus = _double(json['add_on_sapphire_plus']);
    finalInsuranceQuotation = _double(json['final_insurance_quotation']);
    insuranceExpireOn = _date(json['insurance_expire_on']);

    // Employee
    empId = json['emp_id']?.toString();
    employeeName = json['name'];
    grade = json['grade'];
    email = json['email'];
    dob = _date(json['dob']);
    contact = json['contact'];
    company = json['company'];
    workLocation = json['worklocation'];
    eligibility = _double(json['eligibility']);
    costCentre = json['cost_centre'];
    retirementDate = _date(json['retirement_date']);

    // Audit
    updatedBy = _int(json['updated_by']);
    updatedTime = _date(json['updated_time']);
    assignedTo = _int(json['assigned_to']);

    // Derived
    stage = processStage != null
        ? Stage.fromStageNo(processStage!)
        : null;
  }

  // ---------- Safe parsers ----------

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static double? _double(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static DateTime? _date(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}
