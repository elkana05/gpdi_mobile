import 'package:flutter/material.dart';
import 'public_drawer.dart';
import 'jadwal_ibadah_screen.dart';
import 'profil_gereja_screen.dart';
import 'pelayanan_gereja_screen.dart';
import 'galeri_screen.dart';
import 'pengumuman_screen.dart';
import 'app_bottom_navigation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF7F4FB);
  static const Color softCard = Color(0xFFF0EEFA);
  static const Color textDark = Color(0xFF1E1E2F);
  static const Color textGrey = Color(0xFF85879A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PublicDrawer(
        activeMenu: DrawerMenu.beranda,
      ),
      backgroundColor: softBg,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu_rounded, color: navy, size: 27),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: Row(
          children: [
            Image.asset(
              'web/favicon.png',
              height: 30,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
            const SizedBox(width: 10),
            const Text(
              'GPdI Sibulele',
              style: TextStyle(color: navy, fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 30),
                    _VerseCard(),
                    const SizedBox(height: 40),
                    _buildScheduleSection(context),
                    const SizedBox(height: 16),
                    _MenuGrid(),
                    const SizedBox(height: 40),
                    _ContactCard(),
                  ],
                ),
              ),
            ),
          );
        }
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELAMAT DATANG',
          style: TextStyle(color: gold, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2.2),
        ),
        SizedBox(height: 8),
        Text(
          'Shalom,\nSelamat Datang',
          style: TextStyle(color: navy, fontSize: 29, fontWeight: FontWeight.w800, height: 1.1),
        ),
      ],
    );
  }

  Widget _buildScheduleSection(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const JadwalIbadahScreen()));
      },
      child: _ScheduleCard(),
    );
  }
}

class _VerseCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(31, 32, 28, 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF05066F), Color(0xFF07046F), Color(0xFF15015F)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF05066F).withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AYAT TAHUNAN 2024',
            style: TextStyle(color: Color(0xFFFFD34E), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1),
          ),
          SizedBox(height: 18),
          Text(
            '"Sebab Aku ini mengetahui rancangan-rancangan apa yang ada pada-Ku mengenai kamu, demikianlah firman TUHAN."',
            style: TextStyle(color: Colors.white, fontSize: 19, height: 1.5, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 12),
          Text('Yeremia 29:11', style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: const Row(
        children: [
          Icon(Icons.event_available_rounded, color: HomeScreen.navy, size: 30),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jadwal Ibadah', style: TextStyle(color: HomeScreen.textDark, fontSize: 16, fontWeight: FontWeight.w800)),
                Text('Minggu & Ibadah Kategori', style: TextStyle(color: HomeScreen.textGrey, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }
}

class _MenuGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _MenuBox(
          icon: Icons.church_outlined,
          title: 'Profil Gereja',
          iconColor: HomeScreen.gold,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilGerejaScreen())),
        ),
        _MenuBox(
          icon: Icons.volunteer_activism_outlined,
          title: 'Pelayanan',
          iconColor: HomeScreen.navy,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PelayananGerejaScreen())),
        ),
        _MenuBox(
          icon: Icons.photo_library_outlined,
          title: 'Galeri',
          iconColor: Colors.blueGrey,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GaleriScreen())),
        ),
        _MenuBox(
          icon: Icons.campaign_outlined,
          title: 'Pengumuman',
          iconColor: Colors.redAccent,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PengumumanScreen())),
        ),
      ],
    );
  }
}

class _MenuBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;
  const _MenuBox({required this.icon, required this.title, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: HomeScreen.softBg, borderRadius: BorderRadius.circular(11), border: Border.all(color: Colors.white, width: 1.5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: iconColor, size: 28),
            Text(title, style: const TextStyle(color: HomeScreen.textDark, fontSize: 13, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hubungi Kami', style: TextStyle(color: HomeScreen.textDark, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _contactItem(Icons.location_on_outlined, 'Jl. Raya Sibulele No. 123'),
          _contactItem(Icons.phone_outlined, '(021) 123-4567'),
          _contactItem(Icons.mail_outline, 'sekretariat@gpdisibulele.org'),
        ],
      ),
    );
  }

  Widget _contactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [Icon(icon, size: 18, color: HomeScreen.navy), const SizedBox(width: 12), Text(text, style: const TextStyle(fontSize: 13))]),
    );
  }
}
