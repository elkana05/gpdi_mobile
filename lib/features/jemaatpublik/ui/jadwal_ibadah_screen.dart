import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import 'public_drawer.dart';
import 'app_bottom_navigation.dart';

class JadwalIbadahScreen extends StatefulWidget {
  const JadwalIbadahScreen({super.key});

  @override
  State<JadwalIbadahScreen> createState() => _JadwalIbadahScreenState();
}

class _JadwalIbadahScreenState extends State<JadwalIbadahScreen> {
  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F4FC);

  bool isLoading = true;
  String errorMsg = '';
  List<dynamic> worshipSchedules = [];
  List<dynamic> events = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMsg = '';
    });

    try {
      final results = await Future.wait([
        ApiClient().get(ApiConstants.worshipSchedules),
        ApiClient().get(ApiConstants.activitySchedules),
      ]);

      if (mounted) {
        setState(() {
          worshipSchedules = results[0] is List ? results[0] : (results[0]['data'] ?? []);
          events = results[1] is List ? results[1] : (results[1]['data'] ?? []);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMsg = "Gagal memuat jadwal ibadah.";
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PublicDrawer(activeMenu: DrawerMenu.jadwalIbadah),
      backgroundColor: softBg,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: navy, size: 27),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Jadwal Ibadah',
          style: TextStyle(color: navy, fontSize: 17, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return RefreshIndicator(
                onRefresh: _fetchData,
                color: navy,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 30, 24, 130),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('Jadwal Rutin', 'Mingguan'),
                          const SizedBox(height: 22),
                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.only(top: 100),
                              child: Center(child: CircularProgressIndicator(color: navy)),
                            )
                          else if (errorMsg.isNotEmpty)
                            _buildErrorState()
                          else if (worshipSchedules.isEmpty)
                            _buildEmptyState("Belum ada jadwal rutin.")
                          else
                            ...worshipSchedules.map((s) => Column(
                                  children: [
                                    _buildScheduleCard(
                                      s['nama_ibadah'] ?? s['title'] ?? '-',
                                      s['lokasi'] ?? s['location'] ?? '-',
                                      s['waktu'] ?? s['time'] ?? '-',
                                      s['hari'] ?? s['day'] ?? '-',
                                      isMain: s['is_main'] == true || s['is_main'] == 1,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                )),
                          const SizedBox(height: 32),
                          _buildSectionHeader('Agenda Gereja', 'Mendatang'),
                          const SizedBox(height: 22),
                          if (!isLoading)
                            if (events.isEmpty)
                              _buildEmptyState("Tidak ada agenda terdekat.")
                            else
                              ...events.map((e) => Column(
                                    children: [
                                      _buildEventCard(
                                        e['judul'] ?? e['title'] ?? '-',
                                        e['tanggal'] ?? e['date'] ?? '-',
                                        Icons.celebration_outlined,
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  )),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNavigation(currentIndex: -1),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(errorMsg, style: const TextStyle(color: Colors.red)),
            TextButton(onPressed: _fetchData, child: const Text("Coba Lagi")),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Text(msg, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
    );
  }

  Widget _buildSectionHeader(String title, String sub) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: navy, fontSize: 18, fontWeight: FontWeight.w900)),
        Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildScheduleCard(String title, String loc, String time, String day, {bool isMain = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(color: navy, fontSize: 17, fontWeight: FontWeight.w900))),
              if (isMain)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFE8E5FA), borderRadius: BorderRadius.circular(20)),
                  child: const Text('UTAMA', style: TextStyle(color: navy, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, color: gold, size: 18),
              const SizedBox(width: 8),
              Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(width: 12),
              Text(day, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.grey, size: 18),
              const SizedBox(width: 8),
              Text(loc, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(String title, String date, IconData icon) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [navy, Color(0xFF1B072E)]),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Stack(
        children: [
          Positioned(right: -10, bottom: -10, child: Icon(icon, color: Colors.white.withOpacity(0.05), size: 100)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(color: gold, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
