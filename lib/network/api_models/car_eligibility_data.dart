// API response: POST "/getCarEligibility" - req body: work_level(empGrade)
class CarEligibilityData {
  final String workLevel;
  final String carEligibilityExShowroomPrice;
  final String additionalNotes;

  CarEligibilityData({
    required this.workLevel,
    required this.carEligibilityExShowroomPrice,
    required this.additionalNotes,
  });

  factory CarEligibilityData.fromJson(Map<String, dynamic> json) {
    return CarEligibilityData(
      workLevel: json['work_level'] ?? '',
      carEligibilityExShowroomPrice:
      json['car_eligibility_ex_showroom_price'] ?? '',
      additionalNotes: json['additional_notes'] ?? '',
    );
  }
}
