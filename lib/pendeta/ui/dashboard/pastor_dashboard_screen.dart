import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/auth/services/user_service.dart';
import '../../../features/jemaataktif/services/event_service.dart';

class PastorDashboardScreen extends StatefulWidget {
  const PastorDashboardScreen({super.key});

  @override
  State<PastorDashboardScreen> createState() => _PastorDashboardScreenState();
}

class _PastorDashboardScreenState extends State<PastorDashboardScreen> {
  final UserService _userService = UserService();
  final EventService _eventService = EventService();

  bool _isLoading = true;
  int _userCount = 0;
  int _jadwalCount = 0;
  int _kegiatanCount = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Menggunakan Service agar lebih terstruktur
      final results = await Future.wait([
        _userService.getAllUsers().catchError((_) => []),
        _eventService.getAdminWorship().catchError((_) => []),
        _eventService.getAdminActivity().catchError((_) => []),
      ]);

      if (mounted) {
        setState(() {
          _userCount = results[0].length;
          _jadwalCount = results[1].length;
          _kegiatanCount = results[2].length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    const Color navy = Color(0xFF05066F);
    const Color textSlate800 = Color(0xFF1E293B);
    const Color textSlate500 = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Dashboard Utama',
          style: TextStyle(color: textSlate800, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        color: navy,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER DASHBOARD ---
              const Text(
                'Dashboard Utama',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textSlate800, letterSpacing: -0.5),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: textSlate500, fontSize: 14),
                  children: [
                    const TextSpan(text: 'Selamat datang kembali, '),
                    TextSpan(
                      text: user?.fullName ?? 'Administrator',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
                    ),
                    const TextSpan(text: '. Berikut adalah ringkasan sistem hari ini.'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- STATS CARDS ---
              _buildStatsCard(
                label: 'Total Akun User',
                value: _userCount.toString(),
                icon: Icons.people_outline,
                iconColor: Colors.blue,
                bgColor: const Color(0xFFEFF6FF),
                borderColor: const Color(0xFFDBEAFE),
              ),
              const SizedBox(height: 16),
              _buildStatsCard(
                label: 'Jadwal Ibadah Terdaftar',
                value: _jadwalCount.toString(),
                icon: Icons.event_available_outlined,
                iconColor: Colors.amber,
                bgColor: const Color(0xFFFFFBEB),
                borderColor: const Color(0xFFFEF3C7),
              ),
              const SizedBox(height: 16),
              _buildStatsCard(
                label: 'Total Kegiatan',
                value: _kegiatanCount.toString(),
                icon: Icons.assignment_outlined,
                iconColor: Colors.purple,
                bgColor: const Color(0xFFFAF5FF),
                borderColor: const Color(0xFFF3E8FF),
              ),

              const SizedBox(height: 32),

              // --- BOTTOM AREA ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.info_outline, color: Color(0xFF94A3B8), size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pusat Kendali Admin',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textSlate800),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gunakan menu navigasi di bawah untuk mulai mengelola data jemaat, jadwal ibadah, serta konten publikasi gereja. Seluruh perubahan akan otomatis disinkronisasi ke aplikasi jemaat.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textSlate500, fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                _isLoading
                    ? const SizedBox(width: 40, height: 2, child: LinearProgressIndicator())
                    : Text(
                        value,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              Navigator.pop(context);
              await authProvider.logout();
              if (context.mounted) context.go('/home');
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
