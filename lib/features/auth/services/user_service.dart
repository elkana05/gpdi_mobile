import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/family_member_model.dart';

class UserService {
  final ApiClient _api = ApiClient();

  // 1. Profil & Keamanan Akun
  Future<UserModel> getProfile() async {
    final response = await _api.get(ApiConstants.userProfile);
    final data = response['data'] ?? response;
    return UserModel.fromJson(data);
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _api.post(ApiConstants.userProfile, body: {
      ...data,
      '_method': 'PUT',
    });
  }

  Future<void> updatePassword(String oldPassword, String newPassword, String confirmPassword) async {
    await _api.post(ApiConstants.updatePassword, body: {
      'old_password': oldPassword,
      'new_password': newPassword,
      'new_password_confirmation': confirmPassword,
      '_method': 'PUT',
    });
  }

  // 2. Anggota Keluarga
  Future<List<FamilyMemberModel>> getFamilyMembers() async {
    final response = await _api.get(ApiConstants.familyMembers);
    final List data = response['data'] ?? response;
    return data.map((json) => FamilyMemberModel.fromJson(json)).toList();
  }

  Future<void> addFamilyMember(Map<String, dynamic> data) async {
    await _api.post(ApiConstants.familyMembers, body: data);
  }

  Future<void> updateFamilyMember(int id, Map<String, dynamic> data) async {
    await _api.post("${ApiConstants.familyMembers}/$id", body: {
      ...data,
      '_method': 'PUT',
    });
  }

  Future<void> deleteFamilyMember(int id) async {
    // Menggunakan DELETE murni untuk menghindari 404/405
    await _api.delete("${ApiConstants.familyMembers}/$id");
  }

  // 3. Admin/Pastor: Manajemen Jemaat
  Future<List<UserModel>> getAllUsers() async {
    final response = await _api.get(ApiConstants.adminUsers);
    final List data = response['data'] ?? response;
    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  Future<void> createJemaat(Map<String, dynamic> data) async {
    // Gunakan manageJemaat (user/jemaat) karena adminUsers hanya support GET
    await _api.post(ApiConstants.manageJemaat, body: data);
  }

  Future<void> updateJemaat(String id, Map<String, dynamic> data) async {
    // Gunakan manageJemaat (user/jemaat) untuk konsistensi
    await _api.post("${ApiConstants.manageJemaat}/$id", body: {
      ...data,
      '_method': 'PUT',
    });
  }

  Future<void> deleteJemaat(String id) async {
    // Gunakan manageJemaat (user/jemaat) dengan DELETE murni
    await _api.delete("${ApiConstants.manageJemaat}/$id");
  }

  // Menyesuaikan peran (role) pengguna
  Future<void> updateUserRole(String id, String role) async {
    await _api.post("${ApiConstants.adminUsers}/$id/role", body: {
      'role': role,
      '_method': 'PUT',
    });
  }
}
