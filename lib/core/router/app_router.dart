import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/auth/ui/forgot_password_screen.dart';
import '../../features/jemaatpublik/ui/home_screen.dart';
import '../../features/jemaatpublik/ui/galeri_screen.dart';
import '../../features/jemaatpublik/ui/jadwal_ibadah_screen.dart';
import '../../features/jemaatpublik/ui/pengumuman_screen.dart';
import '../../features/jemaatpublik/ui/pelayanan_gereja_screen.dart';
import '../../features/jemaatpublik/ui/profil_gereja_screen.dart';
import '../../features/jemaatpublik/ui/public_kontak.dart';
import '../../features/jemaataktif/ui/member_home_screen.dart';
import '../../features/jemaataktif/ui/member_profile_screen.dart';
import '../../features/jemaataktif/ui/jadwal_rayon_screen.dart';
import '../../features/jemaataktif/ui/request_surat_screen.dart';
import '../../features/jemaataktif/ui/member_pengumuman.dart';
import '../../features/alkitab/ui/alkitab_screen.dart';
import '../../features/profile/ui/profile_screen.dart';
import '../../pendeta/ui/pastor_main_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final status = authProvider.status;
    final user = authProvider.user;

    // Daftar rute yang hanya boleh diakses jika sudah login
    final bool loggingIn = state.matchedLocation == '/login';
    final bool isAuthRoute = state.matchedLocation.startsWith('/pastor-') ||
                             state.matchedLocation.startsWith('/member-');

    // Jika sedang di initial (sedang cek token), jangan redirect dulu
    if (status == AuthStatus.initial) return null;

    // Jika belum login dan mencoba akses rute terproteksi, lempar ke home publik (bukan login, agar user bisa lihat konten publik dulu)
    if (status != AuthStatus.authenticated && isAuthRoute) {
      return '/home';
    }

    // Jika sudah login dan mencoba ke halaman login, redirect ke dashboard yang sesuai
    if (status == AuthStatus.authenticated && loggingIn) {
      if (user?.roles?.contains('pastor') ?? false) {
        return '/pastor-home';
      }
      return '/member-home';
    }

    return null;
  },
  routes: [
    // ==========================================
    // RUTE JEMAAT PUBLIK (GUEST)
    // ==========================================
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/jadwal-ibadah',
      builder: (context, state) => const JadwalIbadahScreen(),
    ),
    GoRoute(
      path: '/galeri',
      builder: (context, state) => const GaleriScreen(),
    ),
    GoRoute(
      path: '/pengumuman-publik',
      builder: (context, state) => const PengumumanScreen(),
    ),
    GoRoute(
      path: '/pelayanan',
      builder: (context, state) => const PelayananGerejaScreen(),
    ),
    GoRoute(
      path: '/profil-gereja',
      builder: (context, state) => const ProfilGerejaScreen(),
    ),
    GoRoute(
      path: '/kontak',
      builder: (context, state) => const PublicKontakScreen(),
    ),
    GoRoute(
      path: '/profile-guest',
      builder: (context, state) => const ProfileScreen(),
    ),

    // ==========================================
    // RUTE AUTH
    // ==========================================
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // ==========================================
    // RUTE JEMAAT AKTIF (MEMBER)
    // ==========================================
    GoRoute(
      path: '/member-home',
      builder: (context, state) => const MemberHomeScreen(),
    ),
    GoRoute(
      path: '/member-profile',
      builder: (context, state) => const MemberProfileScreen(),
    ),
    GoRoute(
      path: '/jadwal-rayon',
      builder: (context, state) => const JadwalRayonScreen(),
    ),
    GoRoute(
      path: '/request-surat',
      builder: (context, state) => const RequestSuratScreen(),
    ),
    GoRoute(
      path: '/member-pengumuman',
      builder: (context, state) => const MemberPengumumanScreen(),
    ),

    // ==========================================
    // RUTE UMUM (ADAPTIF PUBLIK/MEMBER)
    // ==========================================
    GoRoute(
      path: '/alkitab',
      builder: (context, state) => const AlkitabScreen(),
    ),

    // ==========================================
    // RUTE PENDETA (PASTOR)
    // ==========================================
    GoRoute(
      path: '/pastor-home',
      builder: (context, state) => const PastorMainScreen(),
    ),
  ],
);
