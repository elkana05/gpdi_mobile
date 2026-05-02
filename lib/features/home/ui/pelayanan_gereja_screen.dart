import 'package:flutter/material.dart';
import 'public_drawer.dart';

class PelayananGerejaScreen extends StatelessWidget {
  const PelayananGerejaScreen({super.key});

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFFFD86B);
  static const Color softBg = Color(0xFFF8F4FC);
  static const Color softCard = Color(0xFFF1EFFB);
  static const Color textDark = Color(0xFF1E1E2F);
  static const Color textGrey = Color(0xFF7C7E91);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PublicDrawer(
        activeMenu: DrawerMenu.pelayanan,
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
          'Pelayanan Gereja',
          style: TextStyle(
            color: navy,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search_rounded,
              color: navy,
              size: 25,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 130),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'KOMUNITAS & IMAN',
                  style: TextStyle(
                    color: Color(0xFFC5A327),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: 12),

                const Text(
                  'Temukan Panggilan\nAnda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: navy,
                    fontSize: 28,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Bergabunglah bersama kami dalam melayani Tuhan\nmelalui berbagai wadah pelayanan di GPdI.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 13,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 34),

                const _ServiceImageCard(
                  title: 'Sekolah Minggu',
                  description:
                  'Membentuk karakter dan iman anak-anak sejak usia dini melalui pengajaran Alkitab yang kreatif dan menyenangkan.',
                  gradientColors: [
                    Color(0xFFE2D3B5),
                    Color(0xFF506A57),
                  ],
                  icon: Icons.menu_book_outlined,
                  buttonDark: false,
                ),

                const SizedBox(height: 22),

                const _ServiceImageCard(
                  title: 'Pemuda dan Remaja',
                  description:
                  'Wadah bagi generasi muda untuk bertumbuh, berbagi pengalaman, dan mengasah potensi dalam komunitas yang positif.',
                  gradientColors: [
                    Color(0xFF4FA093),
                    Color(0xFF123F47),
                  ],
                  icon: Icons.groups_rounded,
                  buttonDark: false,
                ),

                const SizedBox(height: 22),

                const _ServiceSimpleCard(
                  icon: Icons.female_rounded,
                  title: 'Pelayanan Wanita',
                  description:
                  'Membangun iman dan persaudaraan antar wanita melalui persekutuan doa dan kegiatan sosial.',
                  buttonDark: true,
                ),

                const SizedBox(height: 22),

                const _ServiceSimpleCard(
                  icon: Icons.male_rounded,
                  title: 'Pelayanan Pria',
                  description:
                  'Memperkuat kepemimpinan spiritual pria sebagai kepala keluarga dan pelayan jemaat.',
                  buttonDark: true,
                ),

                const SizedBox(height: 22),

                const _ServiceImageCard(
                  title: 'Musik dan Pujian',
                  description:
                  'Melayani melalui talenta musik dan vokal untuk menciptakan suasana ibadah yang khusyuk dan penuh sukacita.',
                  gradientColors: [
                    Color(0xFF3A2312),
                    Color(0xFF070707),
                  ],
                  icon: Icons.music_note_rounded,
                  buttonDark: false,
                ),

                const SizedBox(height: 22),

                const _ServiceImageCard(
                  title: 'Multimedia',
                  description:
                  'Mengelola tata cahaya, visual, dan siaran langsung untuk menjangkau jemaat secara digital dan onsite.',
                  gradientColors: [
                    Color(0xFF061414),
                    Color(0xFF031827),
                  ],
                  icon: Icons.videocam_outlined,
                  buttonDark: false,
                ),

                const SizedBox(height: 34),

                const _JoinServiceCard(),
              ],
            ),
          ),

          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomNavigation(),
          ),
        ],
      ),
    );
  }
}

class _ServiceImageCard extends StatelessWidget {
  final String title;
  final String description;
  final List<Color> gradientColors;
  final IconData icon;
  final bool buttonDark;

  const _ServiceImageCard({
    required this.title,
    required this.description,
    required this.gradientColors,
    required this.icon,
    required this.buttonDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 135,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 20,
                  top: 22,
                  child: Icon(
                    icon,
                    size: 90,
                    color: Colors.white.withOpacity(0.20),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    color: PelayananGerejaScreen.textGrey,
                    fontSize: 13,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 22),
                _DetailButton(isDark: buttonDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceSimpleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool buttonDark;

  const _ServiceSimpleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: PelayananGerejaScreen.softCard,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFC7C4D8),
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: PelayananGerejaScreen.navy,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: PelayananGerejaScreen.textGrey,
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          _DetailButton(isDark: buttonDark),
        ],
      ),
    );
  }
}

class _DetailButton extends StatelessWidget {
  final bool isDark;

  const _DetailButton({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor:
          isDark ? PelayananGerejaScreen.navy : PelayananGerejaScreen.softCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        child: Text(
          'Detail Pelayanan',
          style: TextStyle(
            color: isDark ? Colors.white : PelayananGerejaScreen.navy,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _JoinServiceCard extends StatelessWidget {
  const _JoinServiceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
      decoration: BoxDecoration(
        color: PelayananGerejaScreen.navy,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: PelayananGerejaScreen.navy.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Mari Bergabung dalam\nPelayanan',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Temukan tempat terbaik bagi Anda\nuntuk berkontribusi dan menjadi berkat\nbagi sesama jemaat.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFD7D8FF),
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: 160,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: PelayananGerejaScreen.gold,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: const Text(
                'Daftar Sekarang',
                style: TextStyle(
                  color: PelayananGerejaScreen.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
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
            icon: Icons.home_outlined,
            label: 'HOME',
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

  const _BottomNavItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
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