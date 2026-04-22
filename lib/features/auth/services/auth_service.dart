// lib/features/auth/services/auth_service.dart

import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  /// Memanggil API Login
  /// Expected response format: { "data": { "token": "eyJ..." } }
  // Ubah tipe kembalian menjadi Map
  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    try {
      final response = await _dio.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final responseData = response.data;
        String? token;

        // Ambil token sesuai struktur JSON Anda
        if (responseData['data'] != null) {
          token = responseData['data']['access_token'] ?? responseData['data']['token'];
        }

        if (token != null && token.isNotEmpty) {
          // OPTIMASI: Langsung ambil data user dari respons login
          final userData = responseData['data']['user'];
          final user = UserModel.fromJson(userData);

          // Kembalikan token dan user secara bersamaan
          return {
            'token': token.toString(),
            'user': user,
          };
        } else {
          throw Exception('Token tidak ditemukan dalam respons JSON.');
        }
      }
      throw Exception('Gagal mendapatkan token.');
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Kredensial tidak valid';
      throw Exception(message);
    }
  }

  /// Memanggil API Profil Saya
  Future<UserModel> getMe() async {
    try {
      // PERBAIKAN UTAMA: Menggunakan rute bawaan dari api.php Anda
      final response = await _dio.get('/auth/me');

      if (response.statusCode == 200) {
        // Tangkap objek user (Bisa berada di response.data['data']['user'] atau langsung di ['data'])
        final userData = response.data['data']['user'] ?? response.data['data'] ?? response.data['user'] ?? response.data;

        return UserModel.fromJson(userData);
      }
      throw Exception('Gagal memuat profil');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Sesi telah berakhir atau rute tidak ditemukan');
    }
  }
}