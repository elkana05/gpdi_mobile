import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/home/ui/home_screen.dart';
import 'features/home/ui/public_drawer.dart';

// Import file internal proyek (Sesuaikan dengan nama package di pubspec.yaml Anda)
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';

/// Class untuk mengizinkan koneksi HTTP ke server lokal (Docker)
/// yang tidak menggunakan sertifikat SSL (HTTPS) resmi.
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  // 1. Inisialisasi binding Flutter sebelum menjalankan aplikasi
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Terapkan bypass SSL khusus untuk tahap development
  HttpOverrides.global = MyHttpOverrides();

  runApp(
    MultiProvider(
      providers: [
        // AuthProvider tetap didaftarkan untuk kebutuhan layar lain,
        // tetapi proses login sementara tidak diaktifkan.
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Nantinya developer lain tinggal menambahkan Provider mereka di sini:
        // ChangeNotifierProvider(create: (_) => EventProvider()),
        // ChangeNotifierProvider(create: (_) => ContentProvider()),
      ],
      child: const GPdISibuleleApp(),
    ),
  );
}

class GPdISibuleleApp extends StatelessWidget {
  const GPdISibuleleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GPdI Sibulele',
      debugShowCheckedModeBanner: false,

      // Menggunakan konfigurasi router dari AppRouter
      routerConfig: appRouter,

      // Konfigurasi Tema Global
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D1282), // Warna Biru GPdI
          primary: const Color(0xFF0D1282),
          secondary: const Color(0xFFD71313), // Warna Merah GPdI
        ),

        // Menggunakan font standar agar UI terlihat profesional di semua device
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),

        // Standarisasi styling tombol
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D1282),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Standarisasi styling input field (TextFormField)
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }
}
