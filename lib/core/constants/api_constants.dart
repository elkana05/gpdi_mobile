import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  /*
    Backend Docker:
    - API Gateway: port 8000
    - HP fisik pakai IP laptop: 10.220.181.201
    - Route Gateway memakai prefix /api
  */

  static String get host {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    if (Platform.isAndroid) {
      return 'http://10.220.181.201:8000';
    }

    if (Platform.isIOS) {
      return 'http://127.0.0.1:8000';
    }

    return 'http://127.0.0.1:8000';
  }

  static String get baseUrl => '$host/api';

  // =========================
  // TEST
  // =========================
  static const String health = '/event/worship';

  // =========================
  // AUTH / USER
  // Gateway: api/auth/{path}, api/user/{path}
  // =========================
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String userProfile = '/user/profile';

  // =========================
  // EVENT / JADWAL IBADAH
  // Service route: api/event/worship, api/event/activity
  // Flutter URL: /api/event/worship, /api/event/activity
  // =========================
  static const String worshipSchedules = '/event/worship';
  static const String activitySchedules = '/event/activity';

  // =========================
  // CONTENT / GALERI / RENUNGAN
  // Service route: api/content/galeri, api/content/devotionals
  // Flutter URL: /api/content/galeri, /api/content/devotionals
  // =========================
  static const String gallery = '/content/galeri';
  static const String devotionals = '/content/devotionals';

  // =========================
  // CONTENT ADMIN / PENGUMUMAN
  // Catatan: dari route:list content, yang tersedia untuk pengumuman baru admin route.
  // Kalau butuh pengumuman publik, backend perlu menyediakan route public-nya.
  // =========================
  static const String adminAnnouncements = '/content/admin/pengumuman';
}