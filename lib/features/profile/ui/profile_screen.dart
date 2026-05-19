import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../jemaatpublik/ui/public_drawer.dart';
import '../../jemaatpublik/ui/app_bottom_navigation.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F9FE);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF7A7C92);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.status == AuthStatus.authenticated && auth.user != null) {
          final roles = auth.user!.roles.map((e) => e.toLowerCase()).toList();

          if (roles.contains('pendeta') || roles.contains('admin')) {
             // Use microtask to avoid building while navigating
             Future.microtask(() => context.go('/pastor-home'));
             return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          Future.microtask(() => context.go('/member-profile'));
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          drawer: const PublicDrawer(
            activeMenu: DrawerMenu.none,
          ),
          backgroundColor: softBg,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: navy.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.menu_rounded, color: navy, size: 22),
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                );
              },
            ),
            title: Text(
              'PROFIL',
              style: GoogleFonts.montserrat(
                color: navy,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                const _GuestProfileCard(),
                const SizedBox(height: 40),
                _buildBenefitsSection(),
              ],
            ),
          ),
          bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'AKSES JEMAAT',
            style: GoogleFonts.montserrat(
              color: gold,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Mari Bergabung\nBersama Kami',
          style: GoogleFonts.montserrat(
            color: navy,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manfaat Akun Jemaat',
          style: GoogleFonts.montserrat(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Keuntungan mendaftar sebagai jemaat aktif',
          style: GoogleFonts.montserrat(
            color: textGrey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        _buildBenefitItem(
          Icons.auto_stories_rounded,
          'Alkitab Personal',
          'Catat renungan dan progres baca Alkitab Anda secara tersimpan.',
          const Color(0xFF4361EE),
        ),
        _buildBenefitItem(
          Icons.groups_rounded,
          'Info Rayon',
          'Terhubung langsung dengan jadwal dan kegiatan di rayon Anda.',
          const Color(0xFFF72585),
        ),
        _buildBenefitItem(
          Icons.assignment_rounded,
          'Administrasi',
          'Kemudahan request surat keterangan jemaat via WhatsApp.',
          const Color(0xFF4CC9F0),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    color: textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.montserrat(
                    color: textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.5
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

class _GuestProfileCard extends StatelessWidget {
  const _GuestProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: ProfileScreen.navy.withOpacity(0.02),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_circle_rounded,
              color: ProfileScreen.navy.withOpacity(0.1),
              size: 80,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Anda Belum Masuk',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              color: ProfileScreen.textDark,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Login untuk mengakses fitur lengkap aplikasi GPdI Sibulele.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              color: ProfileScreen.textGrey,
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ProfileScreen.navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Masuk ke Akun',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
