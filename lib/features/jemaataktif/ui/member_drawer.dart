import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../auth/providers/auth_provider.dart';

enum MemberDrawerMenu {
  beranda,
  jadwalRayon,
  requestSurat,
  pengumuman,
  profil,
  none,
}

class MemberDrawer extends StatelessWidget {
  final MemberDrawerMenu activeMenu;

  const MemberDrawer({
    super.key,
    required this.activeMenu,
  });

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);

  void _goToPage(BuildContext context, String path) {
    Navigator.pop(context); // Close drawer
    context.go(path);
  }

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    Navigator.pop(context);
    await authProvider.logout();
    if (!context.mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

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
          // PREMIUM HEADER (NAVY BACKGROUND)
          _buildHeader(user),

          const SizedBox(height: 12),

          // MENU LIST (WHITE BACKGROUND)
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
                        _MemberDrawerItem(
                          icon: Icons.grid_view_rounded,
                          title: 'Beranda',
                          isActive: activeMenu == MemberDrawerMenu.beranda,
                          onTap: () => _goToPage(context, '/member-home'),
                        ),
                        _MemberDrawerItem(
                          icon: Icons.calendar_month_rounded,
                          title: 'Jadwal Ibadah Rayon',
                          isActive: activeMenu == MemberDrawerMenu.jadwalRayon,
                          onTap: () => _goToPage(context, '/jadwal-rayon'),
                        ),
                        _MemberDrawerItem(
                          icon: Icons.assignment_rounded,
                          title: 'Request Surat',
                          isActive: activeMenu == MemberDrawerMenu.requestSurat,
                          onTap: () => _goToPage(context, '/request-surat'),
                        ),
                        _MemberDrawerItem(
                          icon: Icons.campaign_rounded,
                          title: 'Pengumuman',
                          isActive: activeMenu == MemberDrawerMenu.pengumuman,
                          onTap: () => _goToPage(context, '/member-pengumuman'),
                        ),
                        _MemberDrawerItem(
                          icon: Icons.person_rounded,
                          title: 'Profil Saya',
                          isActive: activeMenu == MemberDrawerMenu.profil,
                          onTap: () => _goToPage(context, '/member-profile'),
                        ),
                      ],
                    ),
                  ),

                  // FOOTER ACTIONS
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: _LogoutButton(
                      onTap: () => _logout(context),
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

  Widget _buildHeader(dynamic user) {
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
                child: Image.asset(
                  'web/favicon.png',
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: navy),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shalom,',
                  style: GoogleFonts.montserrat(
                    color: gold,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.fullName ?? 'Jemaat',
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
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? MemberDrawer.navy.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(
          icon,
          color: isActive ? MemberDrawer.navy : const Color(0xFF7A7C92),
          size: 24,
        ),
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            color: isActive ? MemberDrawer.navy : const Color(0xFF1A1A2E),
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        trailing: isActive
            ? Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: MemberDrawer.gold,
                  shape: BoxShape.circle,
                ),
              )
            : null,
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
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.logout_rounded, size: 20),
      label: const Text('KELUAR DARI AKUN'),
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
