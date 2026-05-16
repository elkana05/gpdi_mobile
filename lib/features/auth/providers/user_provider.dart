import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/family_member_model.dart';
import '../models/rayon_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final _service = UserService();

  UserModel? _detailedProfile;
  List<FamilyMemberModel> _familyMembers = [];
  List<UserModel> _adminUserList = [];
  List<RayonModel> _rayons = [];

  bool _isLoading = false;
  String _errorMessage = '';

  UserModel? get detailedProfile => _detailedProfile;
  List<FamilyMemberModel> get familyMembers => _familyMembers;
  List<UserModel> get adminUsers => _adminUserList;
  List<RayonModel> get rayons => _rayons;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchPersonalData() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.getProfile(),
        _service.getFamilyMembers(),
      ]);
      _detailedProfile = results[0] as UserModel;
      _familyMembers = results[1] as List<FamilyMemberModel>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Manajemen Jemaat (Admin/Pastor) ---

  Future<void> fetchAdminUsers() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _adminUserList = await _service.getAllUsers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRayons() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _rayons = await _service.getRayons();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createJemaat(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.createJemaat(data);
      await fetchAdminUsers();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateJemaat(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.updateJemaat(id, data);
      // Jika role berubah, update juga rolenya secara spesifik sesuai logic React
      if (data.containsKey('role')) {
        await _service.updateUserRole(id, data['role']);
      }
      await fetchAdminUsers();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteJemaat(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.deleteJemaat(id);
      await fetchAdminUsers();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserRole(String id, String role) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.updateUserRole(id, role);
      await fetchAdminUsers();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Profil & Keluarga ---

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      await _service.updateProfile(data);
      await fetchPersonalData();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword(String oldPass, String newPass, String confirmPass) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.updatePassword(oldPass, newPass, confirmPass);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addFamilyMember(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.addFamilyMember(data);
      await fetchPersonalData();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateFamilyMember(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.updateFamilyMember(id, data);
      await fetchPersonalData();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteFamilyMember(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.deleteFamilyMember(id);
      await fetchPersonalData();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
