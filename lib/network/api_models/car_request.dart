import '../../core/utils/enum.dart';

class CarRequest {
  String? requestId;
  String? manufacturer;
  String? carModel;
  String? colorChoice;
  String? choiceOfLease;
  String? purpose;
  String? vehicleType;

  int? currentStage;
  int? createdByRole;

  // Derived helpers
  Stage? stage;
  UserRole? createdRole;

  CarRequest.fromJson(Map<String, dynamic> json) {
    requestId = json['request_id']?.toString();
    manufacturer = json['manufacturer'];
    carModel = json['car_model'];
    colorChoice = json['color_choice'];
    choiceOfLease = json['choice_of_lease'];
    purpose = json['purpose'];
    vehicleType = json['vehicle_type'];

    currentStage = _int(json['current_stage']);
    createdByRole = _int(json['created_by_role']);

    stage = currentStage != null
        ? Stage.fromStageNo(currentStage!)
        : null;

    createdRole = createdByRole != null
        ? UserRole.fromId(createdByRole!)
        : null;
  }

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
