import 'package:flutter/material.dart';

class PastorBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PastorBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const Color navy = Color(0xFF05066F);
  static const Color inactiveColor = Color(0xFF95A0B6);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90, // Ukuran disesuaikan agar lebih proporsional
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(
            icon: Icons.dashboard_rounded,
            label: 'DASHBOARD',
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _BottomNavItem(
            icon: Icons.people_alt_rounded,
            label: 'JEMAAT',
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _BottomNavItem(
            icon: Icons.article_rounded,
            label: 'KONTEN',
            isActive: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _BottomNavItem(
            icon: Icons.event_note_rounded,
            label: 'AGENDA',
            isActive: currentIndex == 3,
            onTap: () => onTap(3),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 75,
        height: 56,
        decoration: BoxDecoration(
          color: isActive ? PastorBottomNavigation.navy : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : PastorBottomNavigation.inactiveColor,
              size: 22, // Ukuran ikon dioptimalkan
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : PastorBottomNavigation.inactiveColor,
                fontSize: 8, // Font diatur agar tidak membebani layout
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
