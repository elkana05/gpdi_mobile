import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      try {
        _user = await _authService.getMe();
        _status = AuthStatus.authenticated;
      } catch (e) {
        await logout(); // Token mungkin expired
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  /// Proses Login (Versi Teroptimasi)
  Future<bool> login(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = '';
    notifyListeners();

    try {
      // Dapatkan token dan user dari auth_service
      final result = await _authService.login(email: email, password: password);

      // Simpan token ke brankas
      await _storage.write(key: 'jwt_token', value: result['token']);

      // Langsung masukkan data user (TIDAK PERLU panggil getMe() lagi!)
      _user = result['user'];

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Proses Logout
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}