import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';

class PastorDashboardScreen extends StatefulWidget {
  const PastorDashboardScreen({super.key});

  @override
  State<PastorDashboardScreen> createState() => _PastorDashboardScreenState();
}

class _PastorDashboardScreenState extends State<PastorDashboardScreen> {
  bool _isLoading = true;
  int _userCount = 0;
  int _jadwalCount = 0;
  int _kegiatanCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final apiClient = ApiClient();

      // Menggunakan Future.wait untuk menjalankan 3 request sekaligus
      final results = await Future.wait([
        apiClient.get(ApiConstants.allUsers).catchError((_) => []),
        apiClient.get(ApiConstants.worshipSchedules).catchError((_) => {'data': []}),
        apiClient.get(ApiConstants.activitySchedules).catchError((_) => {'data': []}),
      ]);

      // Ekstraksi data dari response
      final usersList = results[0] is List ? results[0] : (results[0]['data'] ?? []);
      final worshipList = results[1] is List ? results[1] : (results[1]['data'] ?? []);
      final activityList = results[2] is List ? results[2] : (results[2]['data'] ?? []);

      if (mounted) {
        setState(() {
          _userCount = usersList.length;
          _jadwalCount = worshipList.length;
          _kegiatanCount = activityList.length;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Kesalahan saat memuat data dashboard: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun Pendeta/Admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (mounted) {
                // Redirect ke Beranda Publik (Guest) setelah logout
                context.go('/home');
              }
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    const Color navy = Color(0xFF05066F);
    const Color textSlate = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Dashboard Utama',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        color: navy,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dashboard Utama',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: textSlate, fontSize: 14),
                      children: [
                        const TextSpan(text: 'Selamat datang kembali, '),
                        TextSpan(
                          text: user?.fullName ?? 'Administrator',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const TextSpan(text: '. Berikut adalah ringkasan sistem hari ini.'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Quick Stats Section
              _buildStatCard(
                label: 'Total Akun User',
                value: _userCount.toString(),
                icon: '👥',
                iconBg: const Color(0xFFEFF6FF),
                iconColor: Colors.blue[600]!,
                borderColor: const Color(0xFFDBEAFE),
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                label: 'Jadwal Ibadah Terdaftar',
                value: _jadwalCount.toString(),
                icon: '📅',
                iconBg: const Color(0xFFFFFBEB),
                iconColor: Colors.amber[600]!,
                borderColor: const Color(0xFFFEF3C7),
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                label: 'Total Kegiatan',
                value: _kegiatanCount.toString(),
                icon: '📋',
                iconBg: const Color(0xFFF5F3FF),
                iconColor: Colors.purple[600]!,
                borderColor: const Color(0xFFEDE9FE),
              ),

              const SizedBox(height: 32),

              // Call to Action Area
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF94A3B8),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pusat Kendali Admin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gunakan menu navigasi di bawah untuk mulai mengelola data jemaat, jadwal ibadah, serta konten publikasi gereja. Seluruh perubahan akan otomatis disinkronisasi ke aplikasi jemaat.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textSlate,
                        fontSize: 14,
                        height: 1.6,
                      ),
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

  Widget _buildStatCard({
    required String label,
    required String value,
    required String icon,
    required Color iconBg,
    required Color iconColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              icon,
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCBD5E1)),
                        ),
                      )
                    : Text(
                        value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
