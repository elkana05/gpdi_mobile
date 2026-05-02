import 'package:flutter/material.dart';

import 'member_drawer.dart';

class JadwalRayonScreen extends StatelessWidget {
  const JadwalRayonScreen({super.key});

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF7F8FC);
  static const Color textDark = Color(0xFF1E1E2F);
  static const Color textGrey = Color(0xFF7D7F91);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MemberDrawer(
        activeMenu: MemberDrawerMenu.jadwalRayon,
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
          'GPDI SIBULELE',
          style: TextStyle(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: CircleAvatar(
              radius: 21,
              backgroundColor: Color(0xFFFFC326),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF17616A),
                child: Icon(
                  Icons.person,
                  color: Color(0xFFFFC326),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _PageHeader(),
            SizedBox(height: 26),
            _RayonInfoCard(),
            SizedBox(height: 34),
            _ActiveScheduleSection(),
            SizedBox(height: 34),
            _HistorySection(),
          ],
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jadwal Ibadah Rayon',
          style: TextStyle(
            color: JadwalRayonScreen.navy,
            fontSize: 27,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Informasi jadwal ibadah rayon terbaru',
          style: TextStyle(
            color: JadwalRayonScreen.textGrey,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Senin, 27 April 2026',
          style: TextStyle(
            color: Color(0xFFD40000),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RayonInfoCard extends StatelessWidget {
  const _RayonInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE3E4EC),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              color: JadwalRayonScreen.navy,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.info_rounded,
                          color: JadwalRayonScreen.navy,
                          size: 21,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Informasi Rayon Anda',
                            style: TextStyle(
                              color: JadwalRayonScreen.navy,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    const _RayonInfoItem(
                      label: 'NAMA RAYON',
                      value: 'Balige',
                      icon: Icons.location_on_outlined,
                    ),

                    const _Divider(),

                    const _RayonInfoItem(
                      label: 'KETUA RAYON',
                      value: 'Belum ada Ketua rayon',
                      icon: Icons.person_outline_rounded,
                      isGrey: true,
                    ),

                    const _Divider(),

                    const _RayonInfoItem(
                      label: 'KETERANGAN',
                      value: 'Kec. balige',
                      icon: Icons.description_outlined,
                    ),

                    const SizedBox(height: 22),

                    Divider(
                      color: Colors.black.withOpacity(0.08),
                      thickness: 1,
                    ),

                    const SizedBox(height: 14),

                    const Center(
                      child: Text(
                        '"Informasi jadwal diperbarui secara real-time oleh\nKetua rayon."',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: JadwalRayonScreen.textGrey,
                          fontSize: 11,
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RayonInfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isGrey;

  const _RayonInfoItem({
    required this.label,
    required this.value,
    required this.icon,
    this.isGrey = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF7C7E8F),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: isGrey
                      ? JadwalRayonScreen.textGrey
                      : JadwalRayonScreen.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Icon(
          icon,
          color: const Color(0xFFA9ABB8),
          size: 24,
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Divider(
        color: Colors.black.withOpacity(0.08),
        thickness: 1,
      ),
    );
  }
}

class _ActiveScheduleSection extends StatelessWidget {
  const _ActiveScheduleSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(
              child: Text(
                'Jadwal Aktif',
                style: TextStyle(
                  color: JadwalRayonScreen.navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            _ScheduleBadge(),
          ],
        ),

        const SizedBox(height: 18),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 34, 24, 34),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE4E5EE),
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: Color(0xFFD9D9E4),
                size: 46,
              ),
              SizedBox(height: 16),
              Text(
                'Belum ada jadwal ibadah\naktif untuk rayon Anda saat\nini.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: JadwalRayonScreen.textGrey,
                  fontSize: 16,
                  height: 1.45,
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

class _ScheduleBadge extends StatelessWidget {
  const _ScheduleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E1FF),
        borderRadius: BorderRadius.circular(50),
      ),
      child: const Text(
        '0 JADWAL',
        style: TextStyle(
          color: JadwalRayonScreen.navy,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(
              child: Text(
                'Riwayat Jadwal',
                style: TextStyle(
                  color: JadwalRayonScreen.navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              'Lihat Semua',
              style: TextStyle(
                color: JadwalRayonScreen.navy,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE7E8EF),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.025),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E9EC),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Color(0xFF858796),
                  size: 25,
                ),
              ),
              const SizedBox(width: 18),
              const Expanded(
                child: Text(
                  'Belum ada riwayat ibadah\nrayon.',
                  style: TextStyle(
                    color: JadwalRayonScreen.textGrey,
                    fontSize: 16,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}