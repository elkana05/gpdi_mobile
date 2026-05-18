import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/church_profile_model.dart';
import '../models/content_model.dart';

class ContentService {
  final ApiClient _api = ApiClient();

  // --- Public Content ---
  Future<ChurchProfileModel> getChurchProfile() async {
    final response = await _api.get(ApiConstants.churchProfile);
    final data = response['data'] ?? response;
    return ChurchProfileModel.fromJson(data);
  }

  Future<List<GalleryModel>> getGallery() async {
    final response = await _api.get(ApiConstants.gallery);
    final List data = response['data'] ?? response;
    return data.map((json) => GalleryModel.fromJson(json)).toList();
  }

  Future<List<DevotionalModel>> getDevotionals() async {
    final response = await _api.get(ApiConstants.devotionals);
    final List data = response['data'] ?? response;
    return data.map((json) => DevotionalModel.fromJson(json)).toList();
  }

  Future<List<AnnouncementModel>> getAnnouncements() async {
    final response = await _api.get(ApiConstants.announcements);
    final List data = response['data'] ?? response;
    return data.map((json) => AnnouncementModel.fromJson(json)).toList();
  }

  // --- Admin Content Management ---

  // 1. Pengumuman
  Future<List<dynamic>> getAdminAnnouncements() async {
    final res = await _api.get(ApiConstants.announcements);
    return res is List ? res : (res['data'] ?? []);
  }

  Future<void> saveAnnouncement(Map<String, dynamic> data, {int? id}) async {
    if (id != null) {
      await _api.post("${ApiConstants.announcements}/$id/update", body: data);
    } else {
      await _api.post(ApiConstants.announcements, body: data);
    }
  }

  Future<void> deleteAnnouncement(int id) async {
    await _api.delete("${ApiConstants.announcements}/$id");
  }

  // 2. Renungan
  Future<List<dynamic>> getAdminDevotionals() async {
    final res = await _api.get(ApiConstants.adminRenungan);
    return res is List ? res : (res['data'] ?? []);
  }

  Future<void> saveDevotional(Map<String, dynamic> data, {int? id}) async {
    if (id != null) {
      await _api.post("${ApiConstants.adminRenungan}/$id/update", body: data);
    } else {
      await _api.post(ApiConstants.adminRenungan, body: data);
    }
  }

  Future<void> deleteDevotional(int id) async {
    await _api.delete("${ApiConstants.adminRenungan}/$id");
  }

  // 3. Galeri
  Future<List<dynamic>> getAdminGallery() async {
    final res = await _api.get(ApiConstants.adminGaleri);
    return res is List ? res : (res['data'] ?? []);
  }

  Future<void> saveGallery(Map<String, dynamic> data, {int? id}) async {
    if (id != null) {
      await _api.post("${ApiConstants.adminGaleri}/$id/update", body: data);
    } else {
      await _api.post(ApiConstants.adminGaleri, body: data);
    }
  }

  Future<void> deleteGallery(int id) async {
    await _api.delete("${ApiConstants.adminGaleri}/$id");
  }

  // Fitur lain
  Future<List<Map<String, dynamic>>> getPastors() async {
    final response = await _api.get('user/admin/users?role=pendeta');
    final List data = response['data'] ?? [];
    return List<Map<String, dynamic>>.from(data);
  }
}
