import 'package:flutter/material.dart';
import 'public_drawer.dart';

class PengumumanScreen extends StatelessWidget {
  const PengumumanScreen({super.key});

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F4FC);
  static const Color softCard = Color(0xFFF1EFFB);
  static const Color textDark = Color(0xFF1E1E2F);
  static const Color textGrey = Color(0xFF7D7F91);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PublicDrawer(
        activeMenu: DrawerMenu.pengumuman,
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
          'Pengumuman',
          style: TextStyle(
            color: navy,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 42, 24, 130),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _SpecialReportHeader(),
                SizedBox(height: 26),
                _ImportantAnnouncementCard(),

                SizedBox(height: 54),

                _SectionDividerTitle(),

                SizedBox(height: 28),

                _MainNewsCard(),

                SizedBox(height: 24),

                _SmallAnnouncementCard(
                  tag: 'BERITA DUKA',
                  tagColor: Color(0xFFFFE388),
                  date: 'Kemarin',
                  title: 'Berpulangnya Bpk. Samuel Wijaya',
                  description:
                  'Segenap jemaat GPdI Sanctuary berduka atas berpulangnya salah satu penatua kita. Ibadah penghiburan diadakan malam ini pukul 19.00.',
                  showDetail: true,
                  backgroundColor: Colors.white,
                ),

                SizedBox(height: 24),

                _SmallAnnouncementCard(
                  tag: 'PELAYANAN',
                  tagColor: Color(0xFFE3E2FF),
                  date: '23 Okt 2023',
                  title: 'Pendaftaran Kelas Katekisasi Baru',
                  description:
                  'Dibuka pendaftaran bagi jemaat yang rindu untuk dibaptis dan menerima pengajaran dasar iman Kristen.',
                  showDetail: false,
                  backgroundColor: softCard,
                ),

                SizedBox(height: 48),

                _BibleQuoteCard(),
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

class _SpecialReportHeader extends StatelessWidget {
  const _SpecialReportHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: Text(
            'LIPUTAN KHUSUS',
            style: TextStyle(
              color: PengumumanScreen.gold,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.6,
            ),
          ),
        ),
        Text(
          'Oct 24, 2023',
          style: TextStyle(
            color: PengumumanScreen.textGrey,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ImportantAnnouncementCard extends StatelessWidget {
  const _ImportantAnnouncementCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 220,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFC28B35),
                        Color(0xFF1E1308),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 0,
                  bottom: 0,
                  child: Icon(
                    Icons.church_outlined,
                    color: Colors.white.withOpacity(0.24),
                    size: 160,
                  ),
                ),
                Positioned(
                  right: -18,
                  top: -18,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 0,
            left: 32,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(32, 31, 28, 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.055),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PENGUMUMAN PENTING',
                    style: TextStyle(
                      color: PengumumanScreen.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.8,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Renovasi Area\nIbadah Utama',
                    style: TextStyle(
                      color: PengumumanScreen.navy,
                      fontSize: 25,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Persiapan kenyamanan jemaat\nmenjelang perayaan Natal 2023.\nIbadah akan dipindahkan sementara\nke Aula Lt. 2.',
                    style: TextStyle(
                      color: PengumumanScreen.textGrey,
                      fontSize: 15,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
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

class _SectionDividerTitle extends StatelessWidget {
  const _SectionDividerTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'WARTA JEMAAT',
          style: TextStyle(
            color: Color(0xFF8C8D9E),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Divider(
            color: Colors.black.withOpacity(0.10),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

class _MainNewsCard extends StatelessWidget {
  const _MainNewsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: PengumumanScreen.softCard,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 175,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFE8B06D),
                          Color(0xFF3D2414),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.groups_2_outlined,
                      color: Colors.white.withOpacity(0.24),
                      size: 95,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1E0FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'KEGIATAN',
                    style: TextStyle(
                      color: PengumumanScreen.navy,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  '2 jam yang lalu',
                  style: TextStyle(
                    color: PengumumanScreen.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Pertemuan Kaum Muda (Youth)',
              style: TextStyle(
                color: PengumumanScreen.textDark,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            const _AnnouncementInfoRow(
              icon: Icons.calendar_month_outlined,
              text: 'Sabtu, 28 Oktober 2023',
            ),
            const SizedBox(height: 6),
            const _AnnouncementInfoRow(
              icon: Icons.location_on_outlined,
              text: 'Aula Pemuda, Lantai 3',
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AnnouncementInfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: PengumumanScreen.textGrey,
          size: 17,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: PengumumanScreen.textGrey,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SmallAnnouncementCard extends StatelessWidget {
  final String tag;
  final Color tagColor;
  final String date;
  final String title;
  final String description;
  final bool showDetail;
  final Color backgroundColor;

  const _SmallAnnouncementCard({
    required this.tag,
    required this.tagColor,
    required this.date,
    required this.title,
    required this.description,
    required this.showDetail,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(11),
        boxShadow: backgroundColor == Colors.white
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: PengumumanScreen.navy,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                date,
                style: const TextStyle(
                  color: PengumumanScreen.textGrey,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              color: PengumumanScreen.textDark,
              fontSize: 19,
              height: 1.25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: PengumumanScreen.textGrey,
              fontSize: 14,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (showDetail) ...[
            const SizedBox(height: 20),
            const Text(
              'LIHAT DETAIL ›',
              style: TextStyle(
                color: PengumumanScreen.navy,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BibleQuoteCard extends StatelessWidget {
  const _BibleQuoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 42, 28, 42),
      decoration: BoxDecoration(
        color: PengumumanScreen.navy,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: PengumumanScreen.navy.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        children: [
          Text(
            '”',
            style: TextStyle(
              color: PengumumanScreen.gold,
              fontSize: 45,
              height: 0.7,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 12),
          Text(
            '"Segala perkara dapat\nkutanggung di dalam Dia\nyang memberi kekuatan\nkepadaku."',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'FILIPI 4:13',
            style: TextStyle(
              color: PengumumanScreen.gold,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
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