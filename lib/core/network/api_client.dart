import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

class ApiClient {
  static final ApiClient instance = ApiClient._internal();

  late final Dio dio;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );
  }

  factory ApiClient() {
    return instance;
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await dio.get(endpoint);
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<dynamic> post(
      String endpoint, {
        Map<String, dynamic>? body,
      }) async {
    try {
      final response = await dio.post(
        endpoint,
        data: body ?? {},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<dynamic> put(
      String endpoint, {
        Map<String, dynamic>? body,
      }) async {
    try {
      final response = await dio.put(
        endpoint,
        data: body ?? {},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await dio.delete(endpoint);
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      return 'Request gagal. Status: ${e.response?.statusCode}, Data: ${e.response?.data}';
    }

    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Koneksi timeout. Server terlalu lama merespons.';
    }

    if (e.type == DioExceptionType.receiveTimeout) {
      return 'Receive timeout. Server tidak mengirim respons.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak bisa terhubung ke backend. Pastikan Docker API Gateway berjalan.';
    }

    return e.message ?? 'Terjadi kesalahan koneksi.';
  }
}