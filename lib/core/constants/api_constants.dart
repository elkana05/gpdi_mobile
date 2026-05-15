import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Update IP Address berdasarkan ipconfig terbaru
  static const String _localIp = '10.117.145.201';

  static final String host = _getHost();
  static final String baseUrl = '$host/api/';

  // Host khusus untuk aset gambar (langsung ke Content Service Port 8002)
  static String _getAssetHost() {
    if (kIsWeb) return 'http://localhost:8002';
    return 'http://$_localIp:8002';
  }

  static String _getHost() {
    if (kIsWeb) return 'http://localhost:8000';
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        return 'http://$_localIp:8000'; // API Gateway
      }
    } catch (_) {}
    return 'http://localhost:8000';
  }

  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';

    // Jika path sudah berupa URL lengkap (http...)
    if (path.startsWith('http')) {
      String fixedUrl = path;
      if (!kIsWeb) {
        fixedUrl = fixedUrl
            .replaceAll('localhost', _localIp)
            .replaceAll('127.0.0.1', _localIp);
      }
      return fixedUrl;
    }

    // Pembersihan path
    String cleanPath = path.trim();
    if (cleanPath.startsWith('/')) cleanPath = cleanPath.substring(1);

    // Hapus prefix 'public/' jika ada dari database
    if (cleanPath.startsWith('public/')) {
      cleanPath = cleanPath.substring(7);
    }

    // Pastikan diawali dengan 'storage/' agar sesuai dengan link artisan storage:link
    if (!cleanPath.startsWith('storage/')) {
      cleanPath = 'storage/$cleanPath';
    }

    // Gunakan Port 8002 karena file fisik ada di content-publication-service
    final String finalUrl = '${_getAssetHost()}/$cleanPath';
    return finalUrl;
  }

  // --- Endpoints via API Gateway (Port 8000) ---

  // 1. User & Account Service (Port 8001)
  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String userMe = 'auth/me';
  static const String userProfile = 'user/profile';
  static const String updatePassword = 'user/password';
  static const String familyMembers = 'user/family-members';
  static const String manageJemaat = 'user/jemaat';
  static const String allUsers = 'user/admin/users';
  static const String adminUsers = 'user/admin/users';

  // 2. Content Service (Port 8002)
  static const String gallery = 'content/galeri';
  static const String devotionals = 'content/devotionals';
  static const String announcements = 'content/admin/pengumuman';
  static const String adminRenungan = 'content/admin/renungan';
  static const String adminGaleri = 'content/admin/galeri';
  static const String churchProfile = 'content/profil-gereja';
  static const String services = 'content/layanan';

  // 3. Event Service (Port 8003)
  static const String worshipSchedules = 'event/worship';
  static const String activitySchedules = 'event/activity';
  static const String adminWorship = 'event/admin/worship';
  static const String adminActivity = 'event/admin/activity';
  static const String rayonSchedules = 'event/jemaat/rayon-schedules';
  static const String myRayonSchedules = 'event/rayon-schedules/me';
  static const String manageRayonSchedules = 'event/admin/rayon-schedule';
  static const String adminRayons = 'event/admin/rayon';
  static const String rayons = 'event/admin/rayon';

  // 4. Administration Service (Port 8004)
  static const String letters = 'admin/surat';
  static const String notifications = 'admin/notifikasi';
}
