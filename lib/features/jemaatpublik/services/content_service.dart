import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/church_profile_model.dart';
import '../models/content_model.dart';

class ContentService {
  final ApiClient _api = ApiClient();

  Future<ChurchProfileModel> getChurchProfile() async {
    try {
      final response = await _api.get(ApiConstants.churchProfile);
      final data = response['data'] ?? response;
      return ChurchProfileModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // Fitur baru: Ambil daftar pendeta sesuai kode React
  Future<List<Map<String, dynamic>>> getPastors() async {
    try {
      // Menggunakan port 8001 (User Service)
      final response = await _api.get('user/admin/users?role=pendeta');
      final List data = response['data'] ?? [];
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<GalleryModel>> getGallery() async {
    try {
      final response = await _api.get(ApiConstants.gallery);
      final List data = response['data'] ?? response;
      return data.map((json) => GalleryModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DevotionalModel>> getDevotionals() async {
    try {
      final response = await _api.get(ApiConstants.devotionals);
      final List data = response['data'] ?? response;
      return data.map((json) => DevotionalModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AnnouncementModel>> getAnnouncements() async {
    try {
      final response = await _api.get(ApiConstants.announcements);
      final List data = response['data'] ?? response;
      return data.map((json) => AnnouncementModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
