// Lokasi: lib/core/constants/api_constants.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Setup Dinamis untuk menghubungkan Emulator ke Docker Localhost (Port 8000 Gateway)
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    if (Platform.isAndroid) {
      // 10.0.2.2 adalah alias IP emulator Android untuk localhost host-nya
      return 'http://10.0.2.2:8000/api';
    } else {
      // iOS Simulator mengenali 127.0.0.1 secara langsung
      return 'http://127.0.0.1:8000/api';
    }
  }

  // Daftarkan Base Endpoints
  static const String login = '/auth/login';
  static const String worshipSchedules = '/event/worship';
  static const String publicAnnouncements = '/content/pengumuman';
}