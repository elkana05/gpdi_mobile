import 'package:flutter/material.dart';

import '../../auth/ui/login_screen.dart';

enum JemaatMenu {
  jadwalIbadahRayon,
  requestSurat,
  pengumuman,
  none,
}

class JemaatDrawer extends StatelessWidget {
  final JemaatMenu activeMenu;

  const JemaatDrawer({
    super.key,
    required this.activeMenu,
  });

  static const Color navy = Color(0xFF05066F);
  static const Color activeNavy = Color(0xFF252681);
  static const Color gold = Color(0xFFFFC326);
  static const Color menuText = Color(0xFFD9DAFF);
  static const Color subtitleText = Color(0xFFA8A9D9);

  void _stayIfActive(
      BuildContext context,
      JemaatMenu targetMenu,
      Widget targetPage,
      ) {
    if (activeMenu == targetMenu) return;

    Navigator.pop(context);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => targetPage,
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pop(context);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 315,
      backgroundColor: Colors.transparent,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
          decoration: BoxDecoration(
            color: navy,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 26,
                offset: const Offset(8, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _JemaatDrawerHeader(),

              const SizedBox(height: 20),

              Divider(
                color: Colors.white.withOpacity(0.13),
                thickness: 1,
              ),

              const SizedBox(height: 28),

              _JemaatDrawerItem(
                icon: Icons.calendar_month_outlined,
                title: 'Jadwal Ibadah Rayon',
                isActive: activeMenu == JemaatMenu.jadwalIbadahRayon,
                onTap: () {
                  // Nanti arahkan ke halaman Jadwal Ibadah Rayon
                  // _stayIfActive(
                  //   context,
                  //   JemaatMenu.jadwalIbadahRayon,
                  //   const JadwalIbadahRayonScreen(),
                  // );
                },
              ),

              _JemaatDrawerItem(
                icon: Icons.groups_rounded,
                title: 'Request Surat',
                isActive: activeMenu == JemaatMenu.requestSurat,
                onTap: () {
                  // Nanti arahkan ke halaman Request Surat
                  // _stayIfActive(
                  //   context,
                  //   JemaatMenu.requestSurat,
                  //   const RequestSuratScreen(),
                  // );
                },
              ),

              _JemaatDrawerItem(
                icon: Icons.campaign_outlined,
                title: 'Pengumuman',
                isActive: activeMenu == JemaatMenu.pengumuman,
                onTap: () {
                  // Nanti arahkan ke halaman Pengumuman Jemaat
                  // _stayIfActive(
                  //   context,
                  //   JemaatMenu.pengumuman,
                  //   const PengumumanJemaatScreen(),
                  // );
                },
              ),

              const Spacer(),

              _LogoutButton(
                onTap: () => _logout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JemaatDrawerHeader extends StatelessWidget {
  const _JemaatDrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: JemaatDrawer.gold,
          ),
          child: const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: JemaatDrawer.navy,
              size: 26,
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Syalom',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: JemaatDrawer.gold,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Selamat Datang di GPdI',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: JemaatDrawer.subtitleText,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _JemaatDrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _JemaatDrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? JemaatDrawer.activeNavy : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        )
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive
                    ? JemaatDrawer.gold
                    : const Color(0xFFE7E7FF),
                size: 23,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isActive
                        ? JemaatDrawer.gold
                        : JemaatDrawer.menuText,
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: Material(
        color: JemaatDrawer.gold,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: onTap,
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: JemaatDrawer.navy,
                  size: 22,
                ),
                SizedBox(width: 8),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}