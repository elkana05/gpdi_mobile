import 'package:flutter/material.dart';
import '../../home/ui/public_drawer.dart';
import '../../home/ui/app_bottom_navigation.dart';

class AlkitabScreen extends StatelessWidget {
  const AlkitabScreen({super.key});

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
        activeMenu: DrawerMenu.none,
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
          'Alkitab',
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
              color: Color(0xFF5D5FA8),
              size: 27,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _DailyVerseHeader(),
                const SizedBox(height: 18),
                const _DailyVerseCard(),
                const SizedBox(height: 38),

                const Row(
                  children: [
                    Expanded(
                      child: _BibleCategoryCard(
                        icon: Icons.history_edu_outlined,
                        title: 'Perjanjian\nLama',
                        subtitle: '39 Kitab',
                        borderColor: navy,
                        iconColor: navy,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _BibleCategoryCard(
                        icon: Icons.menu_book_outlined,
                        title: 'Perjanjian Baru',
                        subtitle: '27 Kitab',
                        borderColor: gold,
                        iconColor: gold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 44),

                const Text(
                  'RENUNGAN HARIAN',
                  style: TextStyle(
                    color: gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Harapan di Tengah\nBadai',
                  style: TextStyle(
                    color: navy,
                    fontSize: 30,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 26),

                const _ReflectionCard(),

                const SizedBox(height: 36),

                const _ReadingPlanCard(),
              ],
            ),
          ),

          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNavigation(currentIndex: 1),
          ),
        ],
      ),
    );
  }
}

class _DailyVerseHeader extends StatelessWidget {
  const _DailyVerseHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Text(
            'AYAT ALKITAB HARIAN',
            style: TextStyle(
              color: AlkitabScreen.gold,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.8,
            ),
          ),
        ),
        Text(
          '24 MEI 2024',
          style: TextStyle(
            color: AlkitabScreen.textGrey,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DailyVerseCard extends StatelessWidget {
  const _DailyVerseCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 30, 28, 32),
      decoration: BoxDecoration(
        color: AlkitabScreen.navy,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AlkitabScreen.navy.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -6,
            child: Icon(
              Icons.window_rounded,
              color: Colors.black.withOpacity(0.18),
              size: 150,
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '”',
                style: TextStyle(
                  color: Color(0xFFFFD34E),
                  fontSize: 54,
                  height: 0.7,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 18),
              Text(
                '"Sebab Aku ini\nmengetahui\nrancangan-rancangan\napa yang ada pada-Ku\nmengenai kamu,\ndemikianlah firman\nTUHAN."',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  height: 1.18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 28),
              Text(
                'YEREMIA 29:11',
                style: TextStyle(
                  color: Color(0xFFFFD34E),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BibleCategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color borderColor;
  final Color iconColor;

  const _BibleCategoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.borderColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 158,
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 16),
      decoration: BoxDecoration(
        color: AlkitabScreen.softCard,
        borderRadius: BorderRadius.circular(11),
        border: Border(
          left: BorderSide(
            color: borderColor,
            width: 4,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
          const SizedBox(height: 18),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AlkitabScreen.textDark,
              fontSize: 15,
              height: 1.25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AlkitabScreen.textGrey,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard();

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
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 190,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF19384D),
                  Color(0xFF0A1A28),
                ],
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.landscape_outlined,
                    color: Colors.white.withOpacity(0.24),
                    size: 110,
                  ),
                ),
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.06),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 34, 32, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kehidupan tidak selamanya tenang. Adakalanya badai datang tanpa diduga, menggoncang iman dan pengharapan kita. Namun, janji Tuhan tetap teguh. Ia bukan saja menyertai kita di saat tenang, tapi Ia adalah nahkoda yang setia di tengah badai yang paling besar sekalipun.',
                  style: TextStyle(
                    color: AlkitabScreen.textGrey,
                    fontSize: 17,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Ketika murid-murid ketakutan di tengah danau, Yesus berkata: "Tenanglah, ini Aku, jangan takut!" Kata-kata yang sama Ia ucapkan bagi kita hari ini.',
                  style: TextStyle(
                    color: AlkitabScreen.textGrey,
                    fontSize: 17,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
                  decoration: BoxDecoration(
                    color: AlkitabScreen.softCard,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✣  SPIRITUAL INSIGHT',
                        style: TextStyle(
                          color: AlkitabScreen.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 14),
                      Text(
                        '"Kekuatan kita bukan terletak\npada ketiadaan badai, melainkan\npada kehadiran Kristus di dalam\nperahu kehidupan kita."',
                        style: TextStyle(
                          color: AlkitabScreen.navy,
                          fontSize: 15,
                          height: 1.35,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 34),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD86B),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Icon(
                        Icons.self_improvement_rounded,
                        color: AlkitabScreen.navy,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 18),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'POKOK DOA',
                            style: TextStyle(
                              color: AlkitabScreen.gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Ketenangan & Keteguhan Hati',
                            style: TextStyle(
                              color: AlkitabScreen.textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AlkitabScreen.navy,
                      elevation: 8,
                      shadowColor: AlkitabScreen.navy.withOpacity(0.25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: const Text(
                      'Selesaikan Renungan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
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

class _ReadingPlanCard extends StatelessWidget {
  const _ReadingPlanCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: AlkitabScreen.softCard,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              color: AlkitabScreen.navy,
              size: 25,
            ),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rencana Baca',
                  style: TextStyle(
                    color: AlkitabScreen.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Lanjutkan: Matius Pasal 5',
                  style: TextStyle(
                    color: AlkitabScreen.textGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF9CA1B5),
            size: 30,
          ),
        ],
      ),
    );
  }
}