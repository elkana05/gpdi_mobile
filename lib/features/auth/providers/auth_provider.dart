import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

enum AuthStatus { initial, authenticating, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String _errorMessage = '';

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String get errorMessage => _errorMessage;

  /// Cek status login saat aplikasi pertama kali dibuka
  Future<void> checkAuth() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token != null) {
        // Pastikan ApiClient tahu tentang token ini (jika baru di-restart)
        ApiClient().resetToken();

        _user = await _authService.getMe();
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      debugPrint("CheckAuth Error: $e");
      await logout();
    }
    notifyListeners();
  }

  /// Proses Login
  Future<bool> login(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _authService.login(email: email, password: password);

      // Reset token di ApiClient agar mengambil yang baru dari storage
      ApiClient().resetToken();

      // Pastikan token tersimpan sebelum lanjut
      await _storage.write(key: 'jwt_token', value: result['token']);

      _user = result['user'];
      _status = AuthStatus.authenticated;

      debugPrint("Login Success: User ${_user?.fullName} authenticated with roles: ${_user?.roles}");

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Login Provider Error: $e");
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Proses Logout
  Future<void> logout() async {
    try {
      await _storage.delete(key: 'jwt_token');
      // Penting: Reset token di ApiClient
      ApiClient().resetToken();
    } catch (e) {
      debugPrint("Logout Error (Storage): $e");
    }
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
