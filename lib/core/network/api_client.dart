import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class ApiClient {
  static final ApiClient instance = ApiClient._internal();
  late final Dio dio;
  final _storage = const FlutterSecureStorage();

  String? _cachedToken;
  Future<String?>? _tokenFuture;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_cachedToken != null) {
            options.headers['Authorization'] = 'Bearer $_cachedToken';
            return handler.next(options);
          }

          _tokenFuture ??= _storage.read(key: 'jwt_token');
          _cachedToken = await _tokenFuture;

          if (_cachedToken != null) {
            options.headers['Authorization'] = 'Bearer $_cachedToken';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            _cachedToken = null;
            _tokenFuture = null;
          }
          return handler.next(e);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true, // Diaktifkan untuk membantu debug koneksi
        error: true,
      ));
    }
  }

  factory ApiClient() => instance;

  void resetToken() {
    _cachedToken = null;
    _tokenFuture = null;
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await dio.get(endpoint);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await dio.post(endpoint, data: body ?? {});
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await dio.delete(endpoint);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.sendTimeout) {
      return "Koneksi Timeout. Pastikan Server Nyala & IP Laptop Benar.";
    }
    if (e.type == DioExceptionType.connectionError) {
      return "Tidak bisa terhubung ke server (${ApiConstants.baseUrl}). Cek Wi-Fi & IP.";
    }

    if (e.response != null && e.response?.data is Map) {
      return e.response?.data['message'] ?? 'Gagal memproses data (${e.response?.statusCode}).';
    }
    return 'Terjadi kesalahan: ${e.message}';
  }
}
