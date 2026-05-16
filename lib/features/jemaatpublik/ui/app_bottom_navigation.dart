import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import 'home_screen.dart';
import '../../alkitab/ui/alkitab_screen.dart';
import '../../profile/ui/profile_screen.dart';
import '../../jemaataktif/ui/member_profile_screen.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
  });

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color inactiveColor = Color(0xFF95A0B6);

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.status == AuthStatus.authenticated;

    Widget targetPage;

    if (index == 0) {
      targetPage = const HomeScreen();
    } else if (index == 1) {
      targetPage = const AlkitabScreen();
    } else {
      targetPage = isLoggedIn ? const MemberProfileScreen() : const ProfileScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.05);
          const end = Offset.zero;
          const curve = Curves.easeOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: animation.drive(tween), child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 95,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.12),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavItem(
                icon: currentIndex == 0 ? Icons.grid_view_rounded : Icons.grid_view_outlined,
                label: 'Beranda',
                isActive: currentIndex == 0,
                onTap: () => _navigate(context, 0),
              ),
              _BottomNavItem(
                icon: currentIndex == 1 ? Icons.menu_book_rounded : Icons.menu_book_outlined,
                label: 'Alkitab',
                isActive: currentIndex == 1,
                onTap: () => _navigate(context, 1),
              ),
              _BottomNavItem(
                icon: currentIndex == 2 ? Icons.person_rounded : Icons.person_outline_rounded,
                label: 'Profil',
                isActive: currentIndex == 2,
                onTap: () => _navigate(context, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              margin: const EdgeInsets.only(bottom: 6),
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 22 : 10,
                vertical: isActive ? 10 : 8,
              ),
              decoration: BoxDecoration(
                color: isActive ? AppBottomNavigation.navy : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isActive ? [
                  BoxShadow(
                    color: AppBottomNavigation.navy.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ] : null,
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : AppBottomNavigation.inactiveColor,
                size: 24,
              ),
            ),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: GoogleFonts.montserrat(
                color: isActive ? AppBottomNavigation.navy : AppBottomNavigation.inactiveColor,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0.3,
              ),
              child: Text(label),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppBottomNavigation.gold,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
