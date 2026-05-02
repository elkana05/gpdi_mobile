import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'jadwal_ibadah_screen.dart';
import 'profil_gereja_screen.dart';
import 'pelayanan_gereja_screen.dart';
import 'galeri_screen.dart';
import 'pengumuman_screen.dart';
import '../../auth/ui/login_screen.dart';


enum DrawerMenu {
  beranda,
  jadwalIbadah,
  profilGereja,
  pelayanan,
  galeri,
  pengumuman,
  none,
}

class PublicDrawer extends StatelessWidget {
  final DrawerMenu activeMenu;

  const PublicDrawer({
    super.key,
    required this.activeMenu,
  });

  static const Color navy = Color(0xFF05066F);
  static const Color activeNavy = Color(0xFF252681);
  static const Color gold = Color(0xFFFFC326);
  static const Color menuText = Color(0xFFD9DAFF);
  static const Color subtitleText = Color(0xFFA8A9D9);

  void _goToPage(BuildContext context, DrawerMenu targetMenu, Widget page) {
    if (activeMenu == targetMenu) return;

    Navigator.pop(context);

    if (targetMenu == DrawerMenu.beranda) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => page),
            (route) => false,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
    }
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
              // HEADER
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: gold,
                    ),
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: navy,
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
                            color: gold,
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
                            color: subtitleText,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Divider(
                color: Colors.white.withOpacity(0.13),
                thickness: 1,
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Column(
                  children: [
                    _DrawerMenuItem(
                      icon: Icons.home_rounded,
                      title: 'Beranda',
                      isActive: activeMenu == DrawerMenu.beranda,
                      onTap: () => _goToPage(
                        context,
                        DrawerMenu.beranda,
                        const HomeScreen(),
                      ),
                    ),
                    _DrawerMenuItem(
                      icon: Icons.calendar_month_outlined,
                      title: 'Jadwal Ibadah',
                      isActive: activeMenu == DrawerMenu.jadwalIbadah,
                      onTap: () => _goToPage(
                        context,
                        DrawerMenu.jadwalIbadah,
                        const JadwalIbadahScreen(),
                      ),
                    ),
                    _DrawerMenuItem(
                      icon: Icons.church_outlined,
                      title: 'Profil Gereja',
                      isActive: activeMenu == DrawerMenu.profilGereja,
                      onTap: () => _goToPage(
                        context,
                        DrawerMenu.profilGereja,
                        const ProfilGerejaScreen(),
                      ),
                    ),
                    _DrawerMenuItem(
                      icon: Icons.groups_rounded,
                      title: 'Pelayanan',
                      isActive: activeMenu == DrawerMenu.pelayanan,
                      onTap: () => _goToPage(
                        context,
                        DrawerMenu.pelayanan,
                        const PelayananGerejaScreen(),
                      ),
                    ),
                    _DrawerMenuItem(
                      icon: Icons.photo_library_outlined,
                      title: 'Galeri',
                      isActive: activeMenu == DrawerMenu.galeri,
                      onTap: () => _goToPage(
                        context,
                        DrawerMenu.galeri,
                        const GaleriScreen(),
                      ),
                    ),
                    _DrawerMenuItem(
                      icon: Icons.campaign_outlined,
                      title: 'Pengumuman',
                      isActive: activeMenu == DrawerMenu.pengumuman,
                      onTap: () => _goToPage(
                        context,
                        DrawerMenu.pengumuman,
                        const PengumumanScreen(),
                      ),
                    ),

                    const Spacer(),

                    const _LoginButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? PublicDrawer.activeNavy : Colors.transparent,
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
                    ? PublicDrawer.gold
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
                    color:
                    isActive ? PublicDrawer.gold : PublicDrawer.menuText,
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

class _LoginButton extends StatelessWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: Material(
        color: PublicDrawer.gold,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: () {
            Navigator.pop(context);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
            );
          },
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.login_rounded,
                  color: PublicDrawer.navy,
                  size: 21,
                ),
                SizedBox(width: 8),
                Text(
                  'Login',
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