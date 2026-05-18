import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/auth/services/user_service.dart';
import '../../../features/jemaataktif/services/event_service.dart';

class PastorDashboardScreen extends StatefulWidget {
  final Function(int)? onTabSelected;
  const PastorDashboardScreen({super.key, this.onTabSelected});

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

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F9FE);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF7A7C92);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
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

    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'DASHBOARD',
          style: GoogleFonts.montserrat(
            color: navy,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadInitialData,
            icon: const Icon(Icons.refresh_rounded, color: navy, size: 22),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        color: navy,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user?.fullName ?? 'Hamba Tuhan'),
              const SizedBox(height: 32),
              _buildStatsGrid(),
              const SizedBox(height: 32),
              _buildSectionHeader('Pusat Kendali', 'Kelola seluruh operasional gereja'),
              const SizedBox(height: 16),
              _buildInfoBox(),
              const SizedBox(height: 32),
              _buildSectionHeader('Akses Cepat', 'Menu manajemen data'),
              const SizedBox(height: 16),
              _buildQuickNavGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Syalom,',
              style: GoogleFonts.montserrat(
                color: textGrey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.auto_awesome, color: gold, size: 18),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: GoogleFonts.montserrat(
            color: navy,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ringkasan sistem hari ini.',
          style: GoogleFonts.montserrat(
            color: textGrey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.montserrat(
            color: textGrey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        _buildStatsCard(
          label: 'Total Akun Jemaat',
          value: _userCount.toString(),
          icon: Icons.people_rounded,
          color: const Color(0xFF4361EE),
          onTap: () => widget.onTabSelected?.call(1),
        ),
        const SizedBox(height: 16),
        _buildStatsCard(
          label: 'Jadwal Ibadah',
          value: _jadwalCount.toString(),
          icon: Icons.church_rounded,
          color: const Color(0xFFF72585),
          onTap: () => widget.onTabSelected?.call(3),
        ),
        const SizedBox(height: 16),
        _buildStatsCard(
          label: 'Total Kegiatan',
          value: _kegiatanCount.toString(),
          icon: Icons.event_available_rounded,
          color: const Color(0xFF4CC9F0),
          onTap: () => widget.onTabSelected?.call(3),
        ),
      ],
    );
  }

  Widget _buildStatsCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.montserrat(
                      color: textGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _isLoading
                      ? const SizedBox(width: 30, height: 2, child: LinearProgressIndicator())
                      : Text(
                          value,
                          style: GoogleFonts.montserrat(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: textDark,
                          ),
                        ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: textGrey.withOpacity(0.3), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [navy, Color(0xFF1E208C)],
        ),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              Icons.admin_panel_settings_rounded,
              size: 100,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 16),
              Text(
                'Akses Penuh Pendeta',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gunakan panel ini untuk mengelola jemaat, jadwal, dan konten secara real-time.',
                style: GoogleFonts.montserrat(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickNavGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildNavCard(
            icon: Icons.calendar_month_rounded,
            title: 'Kelola\nAgenda',
            color: const Color(0xFF4361EE),
            onTap: () => widget.onTabSelected?.call(3),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildNavCard(
            icon: Icons.article_rounded,
            title: 'Kelola\nKonten',
            color: const Color(0xFFF72585),
            onTap: () => widget.onTabSelected?.call(2),
          ),
        ),
      ],
    );
  }

  Widget _buildNavCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.montserrat(
                color: textDark,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
