import 'package:flutter/material.dart';
import 'public_drawer.dart';

class GaleriScreen extends StatelessWidget {
  const GaleriScreen({super.key});

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F4FC);
  static const Color textDark = Color(0xFF1E1E2F);
  static const Color textGrey = Color(0xFF7D7F91);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PublicDrawer(
        activeMenu: DrawerMenu.galeri,
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
          'Galeri',
          style: TextStyle(
            color: navy,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search_rounded,
              color: navy,
              size: 27,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 130),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KATEGORI EKSPLORASI',
                  style: TextStyle(
                    color: gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      _CategoryChip(
                        title: 'Semua',
                        isActive: true,
                      ),
                      SizedBox(width: 12),
                      _CategoryChip(title: 'Ibadah Minggu'),
                      SizedBox(width: 12),
                      _CategoryChip(title: 'Kegiatan Pemuda'),
                      SizedBox(width: 12),
                      _CategoryChip(title: 'Natal'),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _GalleryCard(
                            title: 'Kedalaman Ibadah',
                            category: 'IBADAH MINGGU',
                            height: 220,
                            gradientColors: [
                              Color(0xFFC09044),
                              Color(0xFF3B240D),
                            ],
                            icon: Icons.church_outlined,
                          ),
                          SizedBox(height: 16),
                          _GalleryCard(
                            title: 'Paduan Suara\nNatal',
                            category: 'NATAL 2024',
                            height: 252,
                            gradientColors: [
                              Color(0xFFF6B333),
                              Color(0xFF2E1909),
                            ],
                            icon: Icons.groups_rounded,
                          ),
                          SizedBox(height: 16),
                          _GalleryCard(
                            title: 'Diskusi Pemuda',
                            category: 'KEGIATAN PEMUDA',
                            height: 252,
                            gradientColors: [
                              Color(0xFFB77842),
                              Color(0xFF2D160C),
                            ],
                            icon: Icons.forum_outlined,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(height: 32),
                          _GalleryCard(
                            title: 'Berbagi Kasih',
                            category: 'BAKTI SOSIAL',
                            height: 220,
                            gradientColors: [
                              Color(0xFFFFD782),
                              Color(0xFF856229),
                            ],
                            icon: Icons.volunteer_activism_outlined,
                          ),
                          SizedBox(height: 16),
                          _GalleryCard(
                            title: 'Retret\nKepemimpinan',
                            category: 'KEGIATAN PEMUDA',
                            height: 252,
                            gradientColors: [
                              Color(0xFFF9D25C),
                              Color(0xFF345E35),
                            ],
                            icon: Icons.people_alt_outlined,
                          ),
                          SizedBox(height: 16),
                          _GalleryCard(
                            title: 'Saat Teduh',
                            category: 'IBADAH MINGGU',
                            height: 220,
                            gradientColors: [
                              Color(0xFFAE8E64),
                              Color(0xFF080814),
                            ],
                            icon: Icons.self_improvement_outlined,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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

class _CategoryChip extends StatelessWidget {
  final String title;
  final bool isActive;

  const _CategoryChip({
    required this.title,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: BoxDecoration(
        color: isActive ? GaleriScreen.navy : Colors.white,
        borderRadius: BorderRadius.circular(40),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : GaleriScreen.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final String title;
  final String category;
  final double height;
  final List<Color> gradientColors;
  final IconData icon;

  const _GalleryCard({
    required this.title,
    required this.category,
    required this.height,
    required this.gradientColors,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final imageHeight = height * 0.68;

    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: imageHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    icon,
                    color: Colors.white.withOpacity(0.28),
                    size: 70,
                  ),
                ),
                Positioned(
                  right: -18,
                  top: -18,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: GaleriScreen.navy,
                      fontSize: 15,
                      height: 1.25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    category,
                    style: const TextStyle(
                      color: GaleriScreen.textGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
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