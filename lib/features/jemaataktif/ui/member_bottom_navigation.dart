import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MemberBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const MemberBottomNavigation({
    super.key,
    required this.currentIndex,
  });

  static const Color navy = Color(0xFF05066F);
  static const Color inactiveColor = Color(0xFF95A0B6);

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    if (index == 0) {
      context.go('/member-home');
    } else if (index == 1) {
      context.go('/alkitab');
    } else {
      context.go('/member-profile');
    }
  }

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BottomNavItem(
            icon: Icons.home_rounded,
            label: 'HOME',
            isActive: currentIndex == 0,
            onTap: () => _navigate(context, 0),
          ),
          _BottomNavItem(
            icon: Icons.menu_book_outlined,
            label: 'ALKITAB',
            isActive: currentIndex == 1,
            onTap: () => _navigate(context, 1),
          ),
          _BottomNavItem(
            icon: Icons.person_outline_rounded,
            label: 'PROFIL',
            isActive: currentIndex == 2,
            onTap: () => _navigate(context, 2),
          ),
        ],
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
    if (isActive) {
      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 84,
          height: 56,
          decoration: BoxDecoration(
            color: MemberBottomNavigation.navy,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: SizedBox(
        width: 84,
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: MemberBottomNavigation.inactiveColor, size: 24),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                color: MemberBottomNavigation.inactiveColor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
