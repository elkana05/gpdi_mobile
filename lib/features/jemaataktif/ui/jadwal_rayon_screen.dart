import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import 'member_drawer.dart';
import 'member_bottom_navigation.dart';

class JadwalRayonScreen extends StatefulWidget {
  const JadwalRayonScreen({super.key});

  @override
  State<JadwalRayonScreen> createState() => _JadwalRayonScreenState();
}

class _JadwalRayonScreenState extends State<JadwalRayonScreen> {
  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFFFC326);
  static const Color softBg = Color(0xFFF8F4FC);

  bool isLoading = true;
  String errorMsg = '';
  Map<String, dynamic> rayonInfo = {};
  Map<String, dynamic> jadwalAktif = {};
  List<dynamic> riwayatJadwal = [];
  String namaKetua = 'Mencari data ketua...';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMsg = '';
    });

    try {
      // Mencoba memanggil endpoint rayon khusus jemaat login
      final response = await ApiClient().get(ApiConstants.rayonSchedule);

      if (response != null) {
        // Mendukung format { success: true, data: { ... } } atau langsung data
        final dynamic responseData = (response is Map<String, dynamic> && response.containsKey('data'))
            ? response['data']
            : response;

        if (mounted) {
          setState(() {
            // Pemetaan data dari response backend
            rayonInfo = responseData['rayon'] ?? {};

            // Mengambil jadwal aktif (mendatang)
            jadwalAktif = responseData['jadwal_aktif'] ?? responseData['jadwalAktif'] ?? {};

            // Mengambil riwayat
            riwayatJadwal = responseData['riwayat'] ?? responseData['history'] ?? [];

            // Mengambil nama ketua rayon
            final ketua = responseData['ketua_rayon'] ?? responseData['ketua'];
            namaKetua = ketua?['name'] ?? ketua?['full_name'] ?? "Belum ada Ketua Rayon";

            isLoading = false;
          });
        }
      } else {
        throw "Data tidak ditemukan.";
      }
    } catch (e) {
      debugPrint("DEBUG ERROR JADWAL RAYON: $e");
      if (mounted) {
        setState(() {
          // Jika 404, kemungkinan besar user memang belum di-assign ke rayon mana pun di backend
          if (e.toString().contains('404')) {
            errorMsg = "Data rayon belum tersedia untuk akun Anda.\nSilakan hubungi pengurus gereja untuk update data rayon.";
          } else {
            errorMsg = "Gagal memuat data jadwal rayon.\n${e.toString()}";
          }
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MemberDrawer(activeMenu: MemberDrawerMenu.jadwalRayon),
      backgroundColor: softBg,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: navy, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Jadwal Rayon',
          style: TextStyle(color: navy, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return RefreshIndicator(
                onRefresh: fetchData,
                color: navy,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informasi Rayon',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: navy),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Detail jadwal ibadah keluarga di lingkungan rayon Anda.',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),

                          const SizedBox(height: 24),

                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.only(top: 80),
                              child: Center(child: CircularProgressIndicator(color: navy)),
                            )
                          else if (errorMsg.isNotEmpty)
                            _buildErrorState()
                          else if (rayonInfo.isEmpty)
                            _buildEmptyState()
                          else ...[
                            _buildRayonCard(),
                            const SizedBox(height: 28),

                            // SEKSI JADWAL MENDATANG
                            const Text(
                              'Ibadah Mendatang',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: navy),
                            ),
                            const SizedBox(height: 12),
                            if (jadwalAktif.isNotEmpty)
                              _buildActiveScheduleCard()
                            else
                              _buildNoActiveSchedule(),

                            const SizedBox(height: 28),

                            // SEKSI RIWAYAT
                            if (riwayatJadwal.isNotEmpty) ...[
                              const Text(
                                'Riwayat Ibadah',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: navy),
                              ),
                              const SizedBox(height: 12),
                              _buildHistoryList(),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MemberBottomNavigation(currentIndex: -1),
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
            const Icon(Icons.cloud_off_rounded, color: Colors.redAccent, size: 64),
            const SizedBox(height: 16),
            Text(
              errorMsg,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w500)
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: fetchData,
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                minimumSize: const Size(180, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              child: const Text("Coba Lagi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(Icons.map_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              "Data Rayon Kosong",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              "Anda belum terdaftar dalam rayon aktif.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoActiveSchedule() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_busy, color: Colors.grey, size: 40),
          SizedBox(height: 12),
          Text("Belum ada jadwal ibadah mendatang.", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildRayonCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: gold.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.location_on_rounded, color: Color(0xFF866B00), size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rayonInfo['nama_rayon'] ?? rayonInfo['name'] ?? 'Rayon',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: navy)
                    ),
                    Text(
                      'Ketua: $namaKetua',
                      style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600)
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),
          const Text('KETERANGAN RAYON', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Text(
            rayonInfo['keterangan'] ?? rayonInfo['description'] ?? 'Informasi rayon aktif.',
            style: const TextStyle(fontSize: 15, color: navy, height: 1.5)
          ),
        ],
      ),
    );
  }

  Widget _buildActiveScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [navy, Color(0xFF1E208F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: navy.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                jadwalAktif['tanggal_ibadah'] ?? jadwalAktif['date'] ?? '-',
                style: const TextStyle(color: gold, fontWeight: FontWeight.w900, fontSize: 17),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Text(
                  jadwalAktif['waktu'] ?? jadwalAktif['time'] ?? '-',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _scheduleInfoItem(Icons.home_work_rounded, 'Lokasi', jadwalAktif['lokasi'] ?? jadwalAktif['location']),
          const SizedBox(height: 12),
          _scheduleInfoItem(Icons.person_pin_rounded, 'Pelayan', jadwalAktif['pelayan_firman'] ?? jadwalAktif['preacher']),
        ],
      ),
    );
  }

  Widget _scheduleInfoItem(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value ?? '-',
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    return Column(
      children: riwayatJadwal.map((item) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          leading: const CircleAvatar(
            backgroundColor: Color(0xFFF1EFFB),
            child: Icon(Icons.history_rounded, color: navy, size: 22),
          ),
          title: Text(item['pelayan_firman'] ?? item['preacher'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: navy)),
          subtitle: Text('${item['tanggal_ibadah'] ?? item['date']} | ${item['lokasi'] ?? item['location']}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (item['status']?.toString().toLowerCase() == 'selesai') ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item['status']?.toString().toUpperCase() ?? '-',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: (item['status']?.toString().toLowerCase() == 'selesai') ? Colors.green : Colors.orange
              ),
            ),
          ),
        ),
      )).toList(),
    );
  }
}
