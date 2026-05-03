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

  // =========================
  // AUTH / USER
  // =========================
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String logout = 'auth/logout';
  static const String userProfile = 'user/profile';
  static const String updateProfile = 'user/profile/update';
  static const String familyMembers = 'user/family-members';
  static const String allUsers = 'users';

  // =========================
  // EVENT / JADWAL
  // =========================
  static const String worshipSchedules = 'event/worship';
  static const String activitySchedules = 'event/activity';
  static const String rayonSchedules = 'event/rayon-schedule'; // Untuk manajemen (Admin/Pendeta)
  static const String rayons = 'event/rayon'; // Master data Rayon
  static const String rayonSchedule = 'event/rayon/my-schedule'; // Untuk Jemaat

  // =========================
  // CONTENT / PENGUMUMAN / GALERI
  // =========================
  static const String gallery = 'content/galeri';
  static const String devotionals = 'content/devotionals';
  static const String announcements = 'content/pengumuman';
  static const String services = 'content/pelayanan';
  static const String churchProfile = 'content/profil-gereja';
  static const String adminAnnouncements = 'content/admin/pengumuman';

  // =========================
  // PERSURATAN
  // =========================
  static const String requestSurat = 'surat/request';
}
