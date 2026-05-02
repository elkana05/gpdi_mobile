import 'package:flutter/material.dart';
import 'public_drawer.dart';
import 'profil_gereja_screen.dart';
import 'pelayanan_gereja_screen.dart';
import 'jadwal_ibadah_screen.dart';
import 'galeri_screen.dart';
import 'pengumuman_screen.dart';
import 'app_bottom_navigation.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';



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
                size: 27,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        titleSpacing: 0,
        title: const Text(
          'Beranda',
          style: TextStyle(
            color: navy,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final result = await ApiClient().get(ApiConstants.health);
                      debugPrint('BERHASIL KONEK BACKEND: $result');
                    } catch (e) {
                      debugPrint('GAGAL KONEK BACKEND: $e');
                    }
                  },
                  child: const Text('Tes Koneksi Backend'),
                ),

                const SizedBox(height: 16),

                _HeaderSection(),
                const SizedBox(height: 30),
                _VerseCard(),
                const SizedBox(height: 40),
                InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const JadwalIbadahScreen(),
                      ),
                    );
                  },
                  child: _ScheduleCard(),
                ),
                const SizedBox(height: 16),
                _MenuGrid(),
                const SizedBox(height: 40),
                _ContactCard(),
              ],
            ),
          ),

          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNavigation(currentIndex: 0),
          ),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SELAMAT DATANG',
                style: TextStyle(
                  color: HomeScreen.gold,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Shalom, Jemaat',
                style: TextStyle(
                  color: HomeScreen.navy,
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 25,
          backgroundColor: Color(0xFFFFC326),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFF17616A),
            child: Icon(
              Icons.person,
              color: Color(0xFFFFC326),
              size: 30,
            ),
          ),
        ),
      ],
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
          colors: [
            Color(0xFF05066F),
            Color(0xFF07046F),
            Color(0xFF15015F),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF05066F).withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Divider(
                      color: Color(0xFFFFC326),
                      thickness: 1.2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'AYAT TAHUNAN 2024',
                    style: TextStyle(
                      color: Color(0xFFFFD34E),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                '"Sebab Aku ini mengetahui\nrancangan-rancangan apa\nyang ada pada-Ku mengenai\nkamu, demikianlah firman\nTUHAN."',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  height: 1.55,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Yeremia 29:11',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.auto_awesome,
                  color: const Color(0xFFFFD34E),
                  size: 27,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 105,
      padding: const EdgeInsets.symmetric(horizontal: 23),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EEFA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: HomeScreen.navy,
              size: 29,
            ),
          ),
          const SizedBox(width: 22),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jadwal Ibadah',
                  style: TextStyle(
                    color: HomeScreen.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Minggu, Pemuda, & Kaum Ibu',
                  style: TextStyle(
                    color: HomeScreen.textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFC8C8D4),
            size: 35,
          ),
        ],
      ),
    );
  }
}

class _MenuGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MenuBox(
                icon: Icons.church_outlined,
                title: 'Profil Gereja',
                iconColor: HomeScreen.gold,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfilGerejaScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MenuBox(
                icon: Icons.volunteer_activism_outlined,
                title: 'Pelayanan',
                iconColor: HomeScreen.navy,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PelayananGerejaScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MenuBox(
                icon: Icons.photo_library_outlined,
                title: 'Galeri',
                iconColor: const Color(0xFF6E7080),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GaleriScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MenuBox(
                icon: Icons.campaign_outlined,
                title: 'Pengumuman',
                iconColor: const Color(0xFFE21E2B),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PengumumanScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
class _MenuBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback? onTap;

  const _MenuBox({
    required this.icon,
    required this.title,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: onTap,
      child: Container(
        height: 116,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: HomeScreen.softCard,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: HomeScreen.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
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
      padding: const EdgeInsets.fromLTRB(32, 34, 32, 31),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Hubungi Kami',
                style: TextStyle(
                  color: HomeScreen.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 12),
              SizedBox(
                width: 48,
                child: Divider(
                  color: HomeScreen.gold,
                  thickness: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const _ContactItem(
            icon: Icons.location_on_outlined,
            title: 'Alamat',
            content: 'Jl. Keramat Raya No. 123, Jakarta\nPusat, DKI Jakarta',
          ),
          const SizedBox(height: 20),
          const _ContactItem(
            icon: Icons.phone_outlined,
            title: 'Telepon',
            content: '(021) 555-0192',
          ),
          const SizedBox(height: 20),
          const _ContactItem(
            icon: Icons.mail_outline_rounded,
            title: 'Email',
            content: 'sekretariat@gpdi-pusat.org',
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: HomeScreen.navy,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Kirim Pesan Doa',
                style: TextStyle(
                  color: Colors.white,
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

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _ContactItem({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: HomeScreen.navy,
          size: 22,
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: HomeScreen.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                content,
                style: const TextStyle(
                  color: HomeScreen.textGrey,
                  fontSize: 14,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(22),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BottomNavItem(
            icon: Icons.home_rounded,
            label: 'HOME',
            isActive: true,
          ),
          _BottomNavItem(
            icon: Icons.menu_book_outlined,
            label: 'ALKITAB',
          ),
          _BottomNavItem(
            icon: Icons.person_outline_rounded,
            label: 'PROFIL',
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return Container(
        width: 84,
        height: 56,
        decoration: BoxDecoration(
          color: HomeScreen.navy,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: 84,
      height: 56,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF95A0B6),
            size: 24,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF95A0B6),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}