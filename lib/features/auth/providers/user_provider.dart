import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/family_member_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final _service = UserService();

  UserModel? _detailedProfile;
  List<FamilyMemberModel> _familyMembers = [];
  List<UserModel> _adminUserList = [];

  bool _isLoading = false;
  String _errorMessage = '';

  UserModel? get detailedProfile => _detailedProfile;
  List<FamilyMemberModel> get familyMembers => _familyMembers;
  List<UserModel> get adminUserList => _adminUserList;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // 1. Ambil Profil & Keluarga (Sekaligus)
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

  // 2. Update Profil
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      await _service.updateProfile(data);
      await fetchPersonalData(); // Refresh data setelah update
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Update Password
  Future<bool> changePassword(String oldPass, String newPass, String confirmPass) async {
    _isLoading = true;
    _errorMessage = '';
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

  // 4. Manajemen Keluarga
  Future<bool> addFamilyMember(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = '';
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
    _errorMessage = '';
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
    _errorMessage = '';
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

  // 5. Admin: Fetch Semua User
  Future<void> fetchAllUsersAdmin() async {
    _isLoading = true;
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
}
