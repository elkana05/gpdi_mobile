import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get host {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    if (Platform.isAndroid) {
      return 'http://10.220.181.201:8000';
    }

    return 'http://127.0.0.1:8000';
  }

  static String get baseUrl => '$host/api/';

  
  // =========================================================
  // 1. USER & AUTH SERVICE (Gateway: /auth/ atau /user/)
  // =========================================================
  static const String login = 'auth/login';
  static const String logout = 'auth/logout';
  static const String userMe = 'auth/me';

  // Profil & Keamanan Akun
  static const String userProfile = 'user/profile';
  static const String updateProfile = 'user/profile';
  static const String updatePassword = 'user/password';

  // Anggota Keluarga
  static const String familyMembers = 'user/family-members';

  // Manajemen Jemaat & User (Admin)
  static const String jemaatList = 'user/jemaat';
  static const String allUsers = 'user/admin/users';

  // =========================================================
  // 2. EVENT & RAYON SERVICE (Gateway: /event/)
  // =========================================================
  static const String worshipSchedules = 'event/worship';
  static const String activitySchedules = 'event/activity';

  // Rute Jemaat melihat jadwal rayon
  static const String rayonSchedule = 'event/jemaat/rayon-schedules';

  // Rute Admin/Manajemen
  static const String rayons = 'event/admin/rayon';
  static const String rayonSchedules = 'event/admin/rayon-schedule';

  // =========================================================
  // 3. CONTENT & PUBLICATION SERVICE (Gateway: /content/)
  // =========================================================
  static const String gallery = 'content/galeri';
  static const String devotionals = 'content/devotionals';

  // Rute Pengumuman
  static const String announcements = 'content/admin/pengumuman';
  static const String adminAnnouncements = 'content/admin/pengumuman';

  static const String services = 'content/pelayanan';
  static const String churchProfile = 'content/profil-gereja';

  // =========================================================
  // 4. ADMINISTRATION & UTILITY SERVICE (Gateway: /admin/)
  // =========================================================
  static const String requestSurat = 'admin/surat';
  static const String notifications = 'admin/notifikasi';
}
