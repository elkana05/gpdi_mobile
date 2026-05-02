import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../auth/ui/login_screen.dart';
import 'jadwal_rayon_screen.dart';
import 'member_home_screen.dart';
import 'request_surat_screen.dart';

enum MemberDrawerMenu {
  beranda,
  jadwalRayon,
  requestSurat,
  pengumuman,
  none,
}

class MemberDrawer extends StatelessWidget {
  final MemberDrawerMenu activeMenu;

  const MemberDrawer({
    super.key,
    required this.activeMenu,
  });

  static const Color navy = Color(0xFF05066F);
  static const Color activeNavy = Color(0xFF252681);
  static const Color gold = Color(0xFFFFC326);
  static const Color menuText = Color(0xFFD9DAFF);
  static const Color subtitleText = Color(0xFFA8A9D9);

  void _goToPage(
      BuildContext context, MemberDrawerMenu targetMenu, Widget page) {
    if (activeMenu == targetMenu) return;

    Navigator.pop(context);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    const secureStorage = FlutterSecureStorage();

    await secureStorage.delete(key: 'access_token');
    await secureStorage.delete(key: 'jwt_token');
    await secureStorage.delete(key: 'user_role');

    if (!context.mounted) return;

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
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 26,
                offset: const Offset(8, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _MemberDrawerHeader(),
              const SizedBox(height: 20),
              Divider(
                color: Colors.white.withValues(alpha: 0.13),
                thickness: 1,
              ),
              const SizedBox(height: 28),
              _MemberDrawerItem(
                icon: Icons.home_rounded,
                title: 'Beranda',
                isActive: activeMenu == MemberDrawerMenu.beranda,
                onTap: () {
                  _goToPage(
                    context,
                    MemberDrawerMenu.beranda,
                    const MemberHomeScreen(),
                  );
                },
              ),
              _MemberDrawerItem(
                icon: Icons.calendar_month_outlined,
                title: 'Jadwal Ibadah Rayon',
                isActive: activeMenu == MemberDrawerMenu.jadwalRayon,
                onTap: () {
                  _goToPage(
                    context,
                    MemberDrawerMenu.jadwalRayon,
                    const JadwalRayonScreen(),
                  );
                },
              ),
              _MemberDrawerItem(
                icon: Icons.groups_rounded,
                title: 'Request Surat',
                isActive: activeMenu == MemberDrawerMenu.requestSurat,
                onTap: () {
                  _goToPage(
                    context,
                    MemberDrawerMenu.requestSurat,
                    const RequestSuratScreen(),
                  );
                },
              ),
              _MemberDrawerItem(
                icon: Icons.campaign_outlined,
                title: 'Pengumuman',
                isActive: activeMenu == MemberDrawerMenu.pengumuman,
                onTap: () {
                  if (activeMenu == MemberDrawerMenu.pengumuman) return;

                  Navigator.pop(context);

                  // Nanti diarahkan ke halaman Pengumuman Jemaat
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => const MemberPengumumanScreen(),
                  //   ),
                  // );
                },
              ),
              const Spacer(),
              _LogoutButton(
                onTap: () {
                  _logout(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberDrawerHeader extends StatelessWidget {
  const _MemberDrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: MemberDrawer.gold,
          ),
          child: const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: MemberDrawer.navy,
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
                  color: MemberDrawer.gold,
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
                  color: MemberDrawer.subtitleText,
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

class _MemberDrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _MemberDrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isActive ? MemberDrawer.activeNavy : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              )
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? MemberDrawer.gold : const Color(0xFFE7E7FF),
                size: 24,
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isActive ? MemberDrawer.gold : MemberDrawer.menuText,
                    fontSize: 17,
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
        color: MemberDrawer.gold,
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
                  color: MemberDrawer.navy,
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
