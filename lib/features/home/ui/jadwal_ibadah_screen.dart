import 'package:flutter/material.dart';
import 'public_drawer.dart';

class JadwalIbadahScreen extends StatelessWidget {
  const JadwalIbadahScreen({super.key});

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F4FC);
  static const Color textDark = Color(0xFF1E1E2F);
  static const Color textGrey = Color(0xFF7D7F91);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PublicDrawer(
        activeMenu: DrawerMenu.jadwalIbadah,
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
          'Jadwal Ibadah',
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
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 130),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(
                  title: 'Jadwal Ibadah',
                  actionText: 'Mingguan',
                ),
                const SizedBox(height: 22),

                const _ScheduleCard(
                  title: 'Ibadah Raya',
                  location: 'Ruang Ibadah Utama',
                  time: '08:00 & 10:30',
                  day: 'Setiap Minggu',
                  isMain: true,
                ),
                const SizedBox(height: 16),
                const _ScheduleCard(
                  title: 'Ibadah Pemuda Remaja',
                  location: 'Aula Pemuda, Lantai 2',
                  time: '17:00',
                  day: 'Setiap Sabtu',
                ),
                const SizedBox(height: 16),
                const _ScheduleCard(
                  title: 'Ibadah Puasa',
                  location: 'Ruang Doa',
                  time: '10:00',
                  day: 'Setiap Jumat',
                ),
                const SizedBox(height: 16),
                const _ScheduleCard(
                  title: 'Ibadah Rayon Kota',
                  location: 'Lokasi Bergilir',
                  time: '19:00',
                  day: 'Setiap Rabu',
                ),

                const SizedBox(height: 48),

                const _SectionHeader(
                  title: 'Event Gereja',
                  actionText: 'Mendatang',
                ),
                const SizedBox(height: 22),

                _EventCard(
                  title: 'Natal Gereja',
                  date: '25 DESEMBER 2024',
                  description:
                  'Rayakan kelahiran Sang Juru Selamat dalam ibadah syukur dan perayaan kasih bersama seluruh jemaat GPdI.',
                  imageGradient: const [
                    Color(0xFF1B072E),
                    Color(0xFF05066F),
                  ],
                  buttonColor: const Color(0xFFFFDC79),
                  buttonTextColor: textDark,
                  icon: Icons.celebration_outlined,
                ),

                const SizedBox(height: 24),

                _EventCard(
                  title: 'Bakti Sosial',
                  date: '12 JANUARI 2025',
                  description:
                  'Wujud nyata kasih kepada sesama melalui pembagian sembako dan pelayanan kesehatan gratis untuk masyarakat sekitar.',
                  imageGradient: const [
                    Color(0xFF031827),
                    Color(0xFF05066F),
                  ],
                  buttonColor: const Color(0xFFE5E3F2),
                  buttonTextColor: navy,
                  icon: Icons.volunteer_activism_outlined,
                ),

                const SizedBox(height: 44),

                const _InfoNote(),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;

  const _SectionHeader({
    required this.title,
    required this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: JadwalIbadahScreen.navy,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          actionText,
          style: const TextStyle(
            color: JadwalIbadahScreen.textGrey,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final String title;
  final String location;
  final String time;
  final String day;
  final bool isMain;

  const _ScheduleCard({
    required this.title,
    required this.location,
    required this.time,
    required this.day,
    this.isMain = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: JadwalIbadahScreen.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (isMain)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E5FA),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'UTAMA',
                    style: TextStyle(
                      color: JadwalIbadahScreen.navy,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF70727D),
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(
                    color: JadwalIbadahScreen.textGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(
            color: Colors.black.withOpacity(0.06),
            height: 1,
            thickness: 1,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: JadwalIbadahScreen.gold,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                time,
                style: const TextStyle(
                  color: JadwalIbadahScreen.navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                width: 1,
                height: 18,
                color: Colors.black.withOpacity(0.08),
              ),
              Expanded(
                child: Text(
                  day,
                  style: const TextStyle(
                    color: JadwalIbadahScreen.textGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String description;
  final List<Color> imageGradient;
  final Color buttonColor;
  final Color buttonTextColor;
  final IconData icon;

  const _EventCard({
    required this.title,
    required this.date,
    required this.description,
    required this.imageGradient,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 178,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: imageGradient,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    icon,
                    size: 96,
                    color: Colors.white.withOpacity(0.18),
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: Colors.white,
                          size: 13,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          date,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: JadwalIbadahScreen.navy,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(
                    color: JadwalIbadahScreen.textGrey,
                    fontSize: 14,
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Detail Acara',
                          style: TextStyle(
                            color: buttonTextColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: buttonTextColor,
                          size: 20,
                        ),
                      ],
                    ),
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

class _InfoNote extends StatelessWidget {
  const _InfoNote();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.info_outline_rounded,
          color: Color(0xFFB1B2BE),
          size: 18,
        ),
        SizedBox(width: 12),
        Flexible(
          child: Text(
            'Jadwal dapat berubah sesuai pengumuman\ngereja',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFB1B2BE),
              fontSize: 12,
              height: 1.4,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w700,
            ),
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