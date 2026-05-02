import 'package:flutter/material.dart';
import '../../home/ui/public_drawer.dart';
import '../../home/ui/app_bottom_navigation.dart';
import '../../auth/ui/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F4FC);
  static const Color softCard = Color(0xFFF1EFFB);
  static const Color textDark = Color(0xFF1E1E2F);
  static const Color textGrey = Color(0xFF64677A);

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
          'Profil',
          style: TextStyle(
            color: navy,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 140),
            child: Column(
              children: const [
                _GuestProfileCard(),
                SizedBox(height: 48),
                _ChurchImageCard(),
              ],
            ),
          ),

          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNavigation(currentIndex: 2),
          ),
        ],
      ),
    );
  }
}

class _GuestProfileCard extends StatelessWidget {
  const _GuestProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(34, 42, 34, 38),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: ProfileScreen.softCard,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(
              Icons.account_circle_outlined,
              color: Color(0xFF999BCB),
              size: 68,
            ),
          ),

          const SizedBox(height: 34),

          const Text(
            'Anda Belum\nMasuk',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ProfileScreen.textDark,
              fontSize: 30,
              height: 1.22,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Silakan login untuk mengakses fitur\nlengkap seperti rencana baca Alkitab\npersonal, pendaftaran pelayanan,\ndan informasi jemaat.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ProfileScreen.textGrey,
              fontSize: 15,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 48),

          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ProfileScreen.navy,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: const Text(
                'Login / Masuk',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(height: 48),

          Divider(
            color: Colors.black.withOpacity(0.10),
            thickness: 1,
          ),

          const SizedBox(height: 34),

          const Text(
            'GEREJA PANTEKOSTA DI INDONESIA',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ProfileScreen.gold,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChurchImageCard extends StatelessWidget {
  const _ChurchImageCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 185,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE5E5EA),
                  Color(0xFFCFCFD7),
                ],
              ),
            ),
          ),

          Center(
            child: Icon(
              Icons.church_outlined,
              size: 120,
              color: Colors.white.withOpacity(0.45),
            ),
          ),

          Container(
            color: Colors.white.withOpacity(0.32),
          ),
        ],
      ),
    );
  }
}