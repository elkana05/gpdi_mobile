import 'package:flutter/material.dart';

import 'jadwal_rayon_screen.dart';
import 'member_drawer.dart';
import 'request_surat_screen.dart';

class MemberHomeScreen extends StatelessWidget {
  const MemberHomeScreen({super.key});

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFFFC326);
  static const Color softBg = Color(0xFFF8F4FC);
  static const Color textDark = Color(0xFF1E1E2F);
  static const Color textGrey = Color(0xFF6F7182);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MemberDrawer(
        activeMenu: MemberDrawerMenu.beranda,
      ),
      backgroundColor: softBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: navy,
                size: 28,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        titleSpacing: 0,
        title: const Text(
          'Jemaat Aktif',
          style: TextStyle(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: CircleAvatar(
              radius: 21,
              backgroundColor: gold,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF17616A),
                child: Icon(
                  Icons.person,
                  color: gold,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Syalom, Jemaat Aktif',
              style: TextStyle(
                color: navy,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Login berhasil. Sekarang sidebar sudah bisa dibuka dari tombol menu di kiri atas.',
              style: TextStyle(
                color: textGrey,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    navy,
                    Color(0xFF1E208F),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: navy.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Akses Fitur Jemaat',
                    style: TextStyle(
                      color: gold,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gunakan sidebar untuk berpindah menu atau pilih salah satu fitur cepat di bawah ini.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Menu Cepat',
              style: TextStyle(
                color: textDark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            _QuickAccessCard(
              icon: Icons.calendar_month_outlined,
              title: 'Jadwal Ibadah Rayon',
              subtitle: 'Lihat informasi jadwal ibadah rayon terbaru.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JadwalRayonScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            _QuickAccessCard(
              icon: Icons.description_outlined,
              title: 'Request Surat',
              subtitle: 'Ajukan kebutuhan surat jemaat langsung dari aplikasi.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RequestSuratScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE3E4EC),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: MemberHomeScreen.navy,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: MemberHomeScreen.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: MemberHomeScreen.textGrey,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.chevron_right_rounded,
                color: MemberHomeScreen.navy,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
