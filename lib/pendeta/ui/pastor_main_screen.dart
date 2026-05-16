import 'package:flutter/material.dart';
import 'pastor_bottom_navigation.dart';
import 'dashboard/pastor_dashboard_screen.dart';
import 'jemaat/pastor_jemaat_screen.dart';
import 'konten/pastor_konten_screen.dart';
import 'agenda/pastor_agenda_screen.dart';

class PastorMainScreen extends StatefulWidget {
  const PastorMainScreen({super.key});

  @override
  State<PastorMainScreen> createState() => _PastorMainScreenState();
}

class _PastorMainScreenState extends State<PastorMainScreen> {
  int _currentIndex = 0;

  // Melacak halaman mana saja yang sudah pernah dibuka (kembali ke 4 halaman)
  final List<bool> _pageInitialized = [true, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack menjaga state halaman agar tidak hilang/load ulang saat pindah tab
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const PastorDashboardScreen(), // 0
          _pageInitialized[1] ? const PastorJemaatScreen() : const SizedBox.shrink(), // 1
          _pageInitialized[2] ? const PastorKontenScreen() : const SizedBox.shrink(), // 2
          _pageInitialized[3] ? const PastorAgendaScreen() : const SizedBox.shrink(), // 3
        ],
      ),
      bottomNavigationBar: PastorBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (_currentIndex != index) {
            setState(() {
              _currentIndex = index;
              _pageInitialized[index] = true; // Tandai halaman sudah dibuka
            });
          }
        },
      ),
    );
  }
}
