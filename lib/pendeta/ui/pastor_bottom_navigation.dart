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
      height: 95,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.12),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
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
        width: 75,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(bottom: 6),
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 18 : 10,
                vertical: isActive ? 8 : 6,
              ),
              decoration: BoxDecoration(
                color: isActive ? PastorBottomNavigation.navy : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isActive ? [
                  BoxShadow(
                    color: PastorBottomNavigation.navy.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ] : [], // Use empty list instead of null to prevent lerp issues
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : PastorBottomNavigation.inactiveColor,
                size: 22,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              style: GoogleFonts.montserrat(
                color: isActive ? PastorBottomNavigation.navy : PastorBottomNavigation.inactiveColor,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: PastorBottomNavigation.gold,
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
