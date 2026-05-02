import 'package:flutter/material.dart';
import 'public_drawer.dart';

class ProfilGerejaScreen extends StatelessWidget {
  const ProfilGerejaScreen({super.key});

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F4FC);
  static const Color softCard = Color(0xFFF1EFFB);
  static const Color textDark = Color(0xFF1E1E2F);
  static const Color textGrey = Color(0xFF747688);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PublicDrawer(
        activeMenu: DrawerMenu.profilGereja,
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
          'Profil Gereja',
          style: TextStyle(
            color: navy,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 130),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HeroChurchCard(),
                const SizedBox(height: 22),

                const Text(
                  'Berdiri sebagai mercusuar iman di tengah masyarakat, GPdI Jemaat Sibulele memiliki akar sejarah yang kuat dalam gerakan Pentakosta di Indonesia.',
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 15,
                    height: 1.65,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 18),

                const _HistoryCard(
                  title: 'Awal Mula',
                  description:
                  'Dimulai dari persekutuan doa kecil di tahun 1980-an, membawa api kegerakan ke wilayah Sibulele.',
                  lineColor: gold,
                ),

                const SizedBox(height: 12),

                const _HistoryCard(
                  title: 'Pertumbuhan',
                  description:
                  'Melalui kesetiaan jemaat, kini telah menjadi pusat transformasi rohani yang berkembang pesat.',
                  lineColor: navy,
                ),

                const SizedBox(height: 36),

                const _SectionTitle(
                  title: 'Visi & Misi',
                  showLine: true,
                ),

                const SizedBox(height: 22),

                const _VisionCard(),

                const SizedBox(height: 18),

                const _MissionItem(
                  icon: Icons.menu_book_outlined,
                  iconBg: Color(0xFFFFE388),
                  iconColor: navy,
                  title: 'Pemberdayaan Rohani',
                  description:
                  'Membangun kedewasaan iman melalui pengajaran Alkitab yang mendalam.',
                ),

                const SizedBox(height: 14),

                const _MissionItem(
                  icon: Icons.groups_rounded,
                  iconBg: Color(0xFFE6E3F8),
                  iconColor: navy,
                  title: 'Persekutuan Kasih',
                  description:
                  'Menciptakan komunitas yang saling mendukung dan melayani satu sama lain.',
                ),

                const SizedBox(height: 14),

                const _MissionItem(
                  icon: Icons.volunteer_activism_outlined,
                  iconBg: Color(0xFFE6E3F8),
                  iconColor: navy,
                  title: 'Kesaksian Publik',
                  description:
                  'Menjadi garam dan terang bagi lingkungan sekitar melalui aksi nyata.',
                ),

                const SizedBox(height: 36),

                const _SectionTitle(
                  title: 'Pengakuan Iman',
                  icon: Icons.verified_rounded,
                ),

                const SizedBox(height: 20),

                const _FaithStatementCard(),

                const SizedBox(height: 40),

                const Center(
                  child: Text(
                    'Struktur Pelayanan',
                    style: TextStyle(
                      color: navy,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                const _OrganizationChart(),
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

class _HeroChurchCard extends StatelessWidget {
  const _HeroChurchCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 185,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0474BA),
                  Color(0xFF0B4C91),
                  Color(0xFF0B144C),
                ],
              ),
            ),
          ),

          Positioned(
            right: 34,
            top: 0,
            child: Icon(
              Icons.church_outlined,
              size: 140,
              color: Colors.white.withOpacity(0.75),
            ),
          ),

          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'FONDASI',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'GPdI Jemaat Sibulele',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
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

class _HistoryCard extends StatelessWidget {
  final String title;
  final String description;
  final Color lineColor;

  const _HistoryCard({
    required this.title,
    required this.description,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
      decoration: BoxDecoration(
        color: ProfilGerejaScreen.softCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 70,
            decoration: BoxDecoration(
              color: lineColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ProfilGerejaScreen.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: ProfilGerejaScreen.textGrey,
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
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

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool showLine;
  final IconData? icon;

  const _SectionTitle({
    required this.title,
    this.showLine = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: ProfilGerejaScreen.gold,
            size: 22,
          ),
          const SizedBox(width: 12),
        ],
        Text(
          title,
          style: const TextStyle(
            color: ProfilGerejaScreen.navy,
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (showLine) ...[
          const SizedBox(width: 16),
          Expanded(
            child: Divider(
              color: Colors.black.withOpacity(0.10),
              thickness: 1,
            ),
          ),
        ],
      ],
    );
  }
}

class _VisionCard extends StatelessWidget {
  const _VisionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        color: ProfilGerejaScreen.navy,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -18,
            child: Icon(
              Icons.auto_awesome,
              color: Colors.white.withOpacity(0.10),
              size: 90,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'VISI KAMI',
                style: TextStyle(
                  color: Color(0xFFFFD34E),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              SizedBox(height: 14),
              Text(
                '"Menjadi jemaat yang\nberakar kuat dalam Firman,\nbertumbuh dalam kasih, dan\nberbuah bagi kemuliaan\nTuhan."',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MissionItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String description;

  const _MissionItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 23,
            ),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ProfilGerejaScreen.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: ProfilGerejaScreen.textGrey,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
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

class _FaithStatementCard extends StatelessWidget {
  const _FaithStatementCard();

  @override
  Widget build(BuildContext context) {
    final items = [
      'Alkitab adalah firman Allah yang diilhamkan.',
      'Allah yang Esa, hadir dalam tiga pribadi.',
      'Kelahiran, Kematian, dan Kebangkitan Yesus Kristus.',
      'Baptisan Roh Kudus dan Karunia-Karunia-Nya.',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: ProfilGerejaScreen.softCard,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          return Container(
            padding: const EdgeInsets.fromLTRB(22, 17, 22, 17),
            decoration: BoxDecoration(
              border: index == items.length - 1
                  ? null
                  : Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.6),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '0${index + 1}',
                  style: const TextStyle(
                    color: ProfilGerejaScreen.gold,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    items[index],
                    style: const TextStyle(
                      color: ProfilGerejaScreen.textDark,
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _OrganizationChart extends StatelessWidget {
  const _OrganizationChart();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _OrgMainCard(
          smallTitle: 'PEMIMPIN ROHANI',
          title: 'Gembala / Pendeta',
          isPrimary: true,
        ),
        const _VerticalLine(height: 34),
        const _OrgMainCard(
          smallTitle: 'DEWAN PENASIHAT',
          title: 'Wakil & Majelis Jemaat',
          isPrimary: false,
        ),
        const _VerticalLine(height: 34),
        Row(
          children: const [
            Expanded(
              child: _OrgSmallCard(
                icon: Icons.church_outlined,
                title: 'KOORDINATOR\nLITURGI',
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: _OrgSmallCard(
                icon: Icons.volunteer_activism_outlined,
                title: 'KOORDINATOR\nDIAKONIA',
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const _TeamCard(),
      ],
    );
  }
}

class _OrgMainCard extends StatelessWidget {
  final String smallTitle;
  final String title;
  final bool isPrimary;

  const _OrgMainCard({
    required this.smallTitle,
    required this.title,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isPrimary ? 260 : double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
      decoration: BoxDecoration(
        color: isPrimary ? ProfilGerejaScreen.navy : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isPrimary
            ? [
          BoxShadow(
            color: ProfilGerejaScreen.navy.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            smallTitle,
            style: TextStyle(
              color: isPrimary ? Colors.white70 : ProfilGerejaScreen.navy,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isPrimary ? Colors.white : ProfilGerejaScreen.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (isPrimary) ...[
            const SizedBox(height: 10),
            Container(
              width: 35,
              height: 2,
              color: ProfilGerejaScreen.gold,
            ),
          ],
        ],
      ),
    );
  }
}

class _VerticalLine extends StatelessWidget {
  final double height;

  const _VerticalLine({
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: height,
      color: Colors.black.withOpacity(0.12),
    );
  }
}

class _OrgSmallCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const _OrgSmallCard({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: BoxDecoration(
        color: ProfilGerejaScreen.softCard,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: ProfilGerejaScreen.navy,
            size: 23,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ProfilGerejaScreen.navy,
              fontSize: 10,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      decoration: BoxDecoration(
        color: ProfilGerejaScreen.softCard,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          const Text(
            'TIM PELAYAN TUHAN',
            style: TextStyle(
              color: ProfilGerejaScreen.textGrey,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: const [
              _TeamChip(label: 'Pemusik'),
              _TeamChip(label: 'Penyanyi'),
              _TeamChip(label: 'Multimedia'),
              _TeamChip(label: 'Penyambut Jemaat'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamChip extends StatelessWidget {
  final String label;

  const _TeamChip({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: ProfilGerejaScreen.navy,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
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