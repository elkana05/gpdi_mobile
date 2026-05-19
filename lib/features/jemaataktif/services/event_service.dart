import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

class EventService {
  final ApiClient _api = ApiClient();

  // --- Worship / Ibadah ---
  Future<List<dynamic>> getAdminWorship() async {
    final res = await _api.get(ApiConstants.adminWorship);
    return res is List ? res : (res['data'] ?? []);
  }

  Future<void> saveWorship(Map<String, dynamic> data, {int? id}) async {
    if (id != null) {
      await _api.post("${ApiConstants.adminWorship}/$id", body: {
        ...data,
        '_method': 'PUT',
      });
    } else {
      await _api.post(ApiConstants.adminWorship, body: data);
    }
  }

  Future<void> deleteWorship(int id) async {
    await _api.delete("${ApiConstants.adminWorship}/$id");
  }

  // --- Activity / Kegiatan ---
  Future<List<dynamic>> getAdminActivity() async {
    final res = await _api.get(ApiConstants.adminActivity);
    return res is List ? res : (res['data'] ?? []);
  }

  Future<void> saveActivity(Map<String, dynamic> data, {int? id}) async {
    if (id != null) {
      await _api.post("${ApiConstants.adminActivity}/$id", body: {
        ...data,
        '_method': 'PUT',
      });
    } else {
      await _api.post(ApiConstants.adminActivity, body: data);
    }
  }

  Future<void> deleteActivity(int id) async {
    await _api.delete("${ApiConstants.adminActivity}/$id");
  }

  // --- Rayon Schedules ---
  Future<List<dynamic>> getManageRayonSchedules() async {
    final res = await _api.get(ApiConstants.manageRayonSchedules);
    return res is List ? res : (res['data'] ?? []);
  }

  Future<void> saveRayonSchedule(Map<String, dynamic> data, {int? id}) async {
    if (id != null) {
      await _api.post("${ApiConstants.manageRayonSchedules}/$id", body: {
        ...data,
        '_method': 'PUT',
      });
    } else {
      await _api.post(ApiConstants.manageRayonSchedules, body: data);
    }
  }

  Future<void> deleteRayonSchedule(int id) async {
    await _api.delete("${ApiConstants.manageRayonSchedules}/$id");
  }

  // --- Rayon Master Data ---
  Future<List<dynamic>> getRayons() async {
    final res = await _api.get(ApiConstants.rayons);
    return res is List ? res : (res['data'] ?? []);
  }

  Future<void> saveRayon(Map<String, dynamic> data, {int? id}) async {
    if (id != null) {
      await _api.post("${ApiConstants.rayons}/$id", body: {
        ...data,
        '_method': 'PUT',
      });
    } else {
      await _api.post(ApiConstants.rayons, body: data);
    }
  }

  Future<void> deleteRayon(int id) async {
    await _api.delete("${ApiConstants.rayons}/$id");
  }
}
