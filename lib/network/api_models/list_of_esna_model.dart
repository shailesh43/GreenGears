// API response: GET "/getListOfEsna"
class GetListOfEsnaModel {
  final String empId;
  final String shortName;

  GetListOfEsnaModel({
    required this.empId,
    required this.shortName,
  });

  factory GetListOfEsnaModel.fromJson(Map<String, dynamic> json) {
    return GetListOfEsnaModel(
      empId: json['emp_id'] ?? '',
      shortName: json['sap_short_name'] ?? '',
    );
  }

  static List<GetListOfEsnaModel> listFromJson(List<dynamic> json) {
    return json
        .map((e) => GetListOfEsnaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
