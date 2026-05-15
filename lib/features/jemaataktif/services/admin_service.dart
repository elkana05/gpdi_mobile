import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/admin_model.dart';

class AdminService {
  final ApiClient _api = ApiClient();

  // --- Layanan Surat ---

  Future<List<LetterRequestModel>> getLetters() async {
    final response = await _api.get(ApiConstants.letters);
    final List data = response['data'] ?? response;
    return data.map((json) => LetterRequestModel.fromJson(json)).toList();
  }

  Future<void> requestLetter(Map<String, dynamic> body) async {
    await _api.post(ApiConstants.letters, body: body);
  }

  // --- Notifikasi ---

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _api.get(ApiConstants.notifications);
    final List data = response['data'] ?? response;
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }
}
