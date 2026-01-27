import '../utils/enum.dart';
import '../utils/role_stage_policy.dart';
import '../../network/api_models/admin_page_response.dart';
import '../../network/api_models/car_request.dart';
import '../utils/role_stage_policy.dart';

Map<Stage, List<CarRequest>> filterRequestsByRole({
  required AdminPageResponse response,
  required UserRole role,
}) {
  final allowedStages = RoleStagePolicy.allowedStages[role] ?? [];
  final Map<Stage, List<CarRequest>> stageMap = {};

  for (final request in response.allRequests) {
    final stage = request.stage; // derived in CarRequest
    if (stage == null) continue;

    if (!allowedStages.contains(stage)) continue;

    stageMap.putIfAbsent(stage, () => []);
    stageMap[stage]!.add(request);
  }

  return stageMap;
}
