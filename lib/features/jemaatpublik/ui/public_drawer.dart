import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';

enum DrawerMenu {
  beranda,
  jadwalIbadah,
  profilGereja,
  pelayanan,
  galeri,
  pengumuman,
  kontak,
  none,
}

class PublicDrawer extends StatelessWidget {
  final DrawerMenu activeMenu;

  const PublicDrawer({
    super.key,
    required this.activeMenu,
  });

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color surfaceNavy = Color(0xFF13147E);

  void _goToPage(BuildContext context, DrawerMenu targetMenu, String routePath) {
    if (activeMenu == targetMenu) {
      Navigator.pop(context);
      return;
    }

    Navigator.pop(context); // Tutup drawer
    context.go(routePath); // Gunakan GoRouter
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isLoggedIn = authProvider.status == AuthStatus.authenticated;
    final user = authProvider.user;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      backgroundColor: navy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(isLoggedIn, user),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _DrawerMenuItem(
                          icon: Icons.home_rounded,
                          title: 'Beranda',
                          isActive: activeMenu == DrawerMenu.beranda,
                          onTap: () => _goToPage(context, DrawerMenu.beranda, '/home'),
                        ),
                        if (isLoggedIn)
                          _DrawerMenuItem(
                            icon: Icons.person_rounded,
                            title: 'Profil Saya',
                            isActive: false,
                            onTap: () {
                              Navigator.pop(context);
                              context.go('/member-profile');
                            },
                          ),
                        _buildDivider(),
                        _DrawerMenuItem(
                          icon: Icons.event_note_rounded,
                          title: 'Jadwal Ibadah',
                          isActive: activeMenu == DrawerMenu.jadwalIbadah,
                          onTap: () => _goToPage(context, DrawerMenu.jadwalIbadah, '/jadwal-ibadah'),
                        ),
                        _DrawerMenuItem(
                          icon: Icons.church_rounded,
                          title: 'Profil Gereja',
                          isActive: activeMenu == DrawerMenu.profilGereja,
                          onTap: () => _goToPage(context, DrawerMenu.profilGereja, '/profil-gereja'),
                        ),
                        _DrawerMenuItem(
                          icon: Icons.volunteer_activism_rounded,
                          title: 'Pelayanan',
                          isActive: activeMenu == DrawerMenu.pelayanan,
                          onTap: () => _goToPage(context, DrawerMenu.pelayanan, '/pelayanan'),
                        ),
                        _DrawerMenuItem(
                          icon: Icons.photo_library_rounded,
                          title: 'Galeri Foto',
                          isActive: activeMenu == DrawerMenu.galeri,
                          onTap: () => _goToPage(context, DrawerMenu.galeri, '/galeri'),
                        ),
                        _DrawerMenuItem(
                          icon: Icons.campaign_rounded,
                          title: 'Pengumuman',
                          isActive: activeMenu == DrawerMenu.pengumuman,
                          onTap: () => _goToPage(context, DrawerMenu.pengumuman, '/pengumuman-publik'),
                        ),
                        _DrawerMenuItem(
                          icon: Icons.location_on_rounded,
                          title: 'Kontak & Lokasi',
                          isActive: activeMenu == DrawerMenu.kontak,
                          onTap: () => _goToPage(context, DrawerMenu.kontak, '/kontak'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: isLoggedIn
                        ? _LogoutButton(onTap: () async {
                            Navigator.pop(context);
                            await authProvider.logout();
                            if (context.mounted) {
                              context.go('/home');
                            }
                          })
                        : const _LoginButton(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isLoggedIn, dynamic user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: gold.withOpacity(0.5), width: 2),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Image.asset('web/favicon.png', errorBuilder: (context, error, stackTrace) => const Icon(Icons.church, color: navy)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn ? 'Shalom,' : 'Selamat Datang',
                  style: GoogleFonts.montserrat(
                    color: gold,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isLoggedIn ? (user?.fullName ?? 'Jemaat') : 'GPdI Sibulele',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Divider(color: Colors.grey.withOpacity(0.1), thickness: 1),
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
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? PublicDrawer.navy.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(
          icon,
          color: isActive ? PublicDrawer.navy : const Color(0xFF7A7C92),
          size: 24,
        ),
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            color: isActive ? PublicDrawer.navy : const Color(0xFF1A1A2E),
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        trailing: isActive
            ? Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: PublicDrawer.gold,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pop(context);
        context.go('/login');
      },
      icon: const Icon(Icons.login_rounded, size: 20),
      label: const Text('MASUK KE AKUN'),
      style: ElevatedButton.styleFrom(
        backgroundColor: PublicDrawer.navy,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w800, letterSpacing: 1),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.logout_rounded, size: 20),
      label: const Text('KELUAR'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.redAccent,
        side: const BorderSide(color: Colors.redAccent, width: 1.5),
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w800, letterSpacing: 1),
      ),
    );
  }
}
