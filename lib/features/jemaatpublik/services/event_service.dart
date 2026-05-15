import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/event_model.dart';

class EventService {
  final ApiClient _api = ApiClient();

  // --- PUBLIC ROUTES ---

  Future<List<WorshipScheduleModel>> getPublicWorship() async {
    final response = await _api.get(ApiConstants.worshipSchedules);
    final List data = response['data'] ?? response;
    return data.map((json) => WorshipScheduleModel.fromJson(json)).toList();
  }

  Future<List<ActivityModel>> getPublicActivities() async {
    final response = await _api.get(ApiConstants.activitySchedules);
    final List data = response['data'] ?? response;
    return data.map((json) => ActivityModel.fromJson(json)).toList();
  }

  // --- JEMAAT ROUTES (Private) ---

  Future<List<RayonScheduleModel>> getJemaatRayonSchedules() async {
    final response = await _api.get(ApiConstants.rayonSchedules);
    final List data = response['data'] ?? response;
    return data.map((json) => RayonScheduleModel.fromJson(json)).toList();
  }

  // --- ADMIN ROUTES (CRUD) ---
  // Kita tambahkan secara bertahap sesuai kebutuhan Dasbor Pendeta
}
