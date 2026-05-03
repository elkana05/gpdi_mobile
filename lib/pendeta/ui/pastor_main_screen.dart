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

  final List<Widget> _pages = [
    const PastorDashboardScreen(),
    const PastorJemaatScreen(),
    const PastorKontenScreen(),
    const PastorAgendaScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: PastorBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
