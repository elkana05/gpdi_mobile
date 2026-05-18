import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PastorBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PastorBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color inactiveColor = Color(0xFF95A0B6);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavItem(
                icon: currentIndex == 0 ? Icons.grid_view_rounded : Icons.grid_view_outlined,
                label: 'Beranda',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _BottomNavItem(
                icon: currentIndex == 1 ? Icons.people_alt_rounded : Icons.people_alt_outlined,
                label: 'Jemaat',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _BottomNavItem(
                icon: currentIndex == 2 ? Icons.article_rounded : Icons.article_outlined,
                label: 'Konten',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _BottomNavItem(
                icon: currentIndex == 3 ? Icons.event_note_rounded : Icons.event_note_outlined,
                label: 'Agenda',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _BottomNavItem(
                icon: currentIndex == 4 ? Icons.person_rounded : Icons.person_outline_rounded,
                label: 'Profil',
                isActive: currentIndex == 4,
                onTap: () => onTap(4),
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
        width: 65,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(bottom: 4),
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 14 : 10,
                vertical: isActive ? 6 : 4,
              ),
              decoration: BoxDecoration(
                color: isActive ? PastorBottomNavigation.navy : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : PastorBottomNavigation.inactiveColor,
                size: 20,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              style: GoogleFonts.montserrat(
                color: isActive ? PastorBottomNavigation.navy : PastorBottomNavigation.inactiveColor,
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
