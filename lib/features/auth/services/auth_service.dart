import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    try {
      final response = await _dio.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Logcat Anda menunjukkan token ada di data.access_token
        String? token;
        if (responseData['data'] != null) {
          token = responseData['data']['access_token'];
        }

        if (token != null && token.isNotEmpty) {
          final userData = responseData['data']['user'];
          if (userData == null) {
            throw Exception('Data profil user tidak lengkap.');
          }

          final user = UserModel.fromJson(userData);

          return {
            'token': token.toString(),
            'user': user,
          };
        } else {
          throw Exception('Token keamanan tidak ditemukan.');
        }
      }
      throw Exception('Gagal masuk ke sistem.');
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'ID Member atau Password salah.';
      throw Exception(message);
    } catch (e) {
      throw Exception('Terjadi kesalahan sistem: $e');
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.userMe);
      if (response.statusCode == 200) {
        final userData = response.data['data']['user'] ?? response.data['data'];
        return UserModel.fromJson(userData);
      }
      throw Exception('Gagal memuat profil');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Sesi berakhir.');
    }
  }
}
