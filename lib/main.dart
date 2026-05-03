import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Import router dan provider
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

void main() async {
  // 1. Inisialisasi binding Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Terapkan bypass SSL untuk tahap development Docker
  HttpOverrides.global = MyHttpOverrides();

  // 3. Inisialisasi AuthProvider dan cek sesi login yang tersimpan
  final authProvider = AuthProvider();
  await authProvider.checkAuth();

  runApp(
    MultiProvider(
      providers: [
        // Menggunakan value yang sudah di-init di atas agar checkAuth selesai dulu
        ChangeNotifierProvider.value(value: authProvider),

        // Tambahkan Provider lain di sini jika ada:
        // ChangeNotifierProvider(create: (_) => RayonProvider()),
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

      // Konfigurasi Tema Global agar seragam di semua Role
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF05066F), // Navy GPdI
          primary: const Color(0xFF05066F),
          secondary: const Color(0xFFC5A327), // Gold GPdI
        ),

        // Font Montserrat untuk kesan profesional
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),

        // Standarisasi styling tombol secara global
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF05066F),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),

        // Standarisasi styling input field (TextFormField)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF05066F), width: 1.5),
          ),
        ),
      ),
    );
  }
}
