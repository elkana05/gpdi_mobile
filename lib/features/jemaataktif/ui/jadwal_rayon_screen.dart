import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  // Mobile consistency colors
  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color redAccent = Color(0xFFD71313);
  static const Color softBg = Color(0xFFF7F4FB);
  static const Color sectionGray = Color(0xFFEEEDED);

  bool isLoading = true;
  String errorMsg = '';
  Map<String, dynamic>? rayonInfo;
  Map<String, dynamic>? jadwalAktif;
  List<dynamic> riwayatJadwal = [];
  String namaKetua = 'Memuat nama ketua...';

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
      // 1. Ambil data Jadwal dan Rayon (Sesuai getJadwalRayonJemaat di React)
      final response = await ApiClient().get(ApiConstants.rayonSchedules);
      final data = (response is Map<String, dynamic> && response.containsKey('data'))
          ? response['data']
          : response;

      if (mounted) {
        setState(() {
          rayonInfo = data['rayon'];
          jadwalAktif = data['jadwalAktif'] ?? data['jadwal_aktif'];
          riwayatJadwal = data['riwayat'] ?? [];

          // Reset nama ketua jika rayon tidak ada
          if (rayonInfo == null) {
            namaKetua = "-";
          }
        });

        // 2. Cari nama Ketua Rayon (Sesuai logic React yang memanggil getAllUsers)
        if (rayonInfo != null && rayonInfo?['id'] != null) {
          try {
            final usersResponse = await ApiClient().get(ApiConstants.allUsers);
            final List usersList = (usersResponse is Map<String, dynamic> && usersResponse.containsKey('data'))
                ? usersResponse['data']
                : usersResponse;

            final ketua = usersList.firstWhere(
              (u) => u['role'] == 'ketua_rayon' && u['id_rayon'] == rayonInfo!['id'],
              orElse: () => null,
            );

            if (mounted) {
              setState(() {
                namaKetua = ketua != null ? (ketua['name'] ?? ketua['full_name'] ?? "Ketua Rayon") : "Belum ada Ketua Rayon";
              });
            }
          } catch (e) {
            if (mounted) setState(() => namaKetua = "Gagal memuat nama");
          }
        }

        setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMsg = e.toString().contains('404')
              ? "Data rayon belum tersedia."
              : "Terjadi kesalahan saat memuat data jadwal rayon.";
          isLoading = false;
        });
      }
    }
  }

  String get _today {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MemberDrawer(activeMenu: MemberDrawerMenu.jadwalRayon),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: navy),
        title: const Text(
          'Jadwal Rayon',
          style: TextStyle(color: navy, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchData,
        color: navy,
        child: isLoading
          ? const Center(child: CircularProgressIndicator(color: navy))
          : (rayonInfo == null)
            ? _buildNotRegisteredState()
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER ---
                    const Text(
                      'Jadwal Ibadah Rayon',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: navy, height: 1.1),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Informasi jadwal ibadah rayon terbaru',
                      style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tanggal: $_today',
                      style: const TextStyle(fontSize: 16, color: redAccent, fontWeight: FontWeight.bold),
                    ),

                    if (errorMsg.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(errorMsg, style: const TextStyle(color: redAccent)),
                      ),

                    // --- SECTION: INFORMASI RAYON ---
                    _buildSectionBox(
                      title: "Informasi Rayon Anda",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoText("Nama Rayon", rayonInfo?['nama_rayon'] ?? rayonInfo?['namaRayon'] ?? "-"),
                          _buildInfoText("Ketua Rayon", namaKetua),
                          _buildInfoText("Keterangan", rayonInfo?['keterangan'] ?? "-"),
                          const SizedBox(height: 16),
                          const Text(
                            '“Informasi jadwal diperbarui secara real-time oleh Ketua Rayon.”',
                            style: TextStyle(fontSize: 15, color: Color(0xFF6E6E6E), fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),

                    // --- SECTION: JADWAL AKTIF ---
                    if (jadwalAktif != null && jadwalAktif!.isNotEmpty)
                      _buildSectionBox(
                        title: "Jadwal Ibadah Aktif",
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoText("Tanggal Ibadah", jadwalAktif?['tanggal_ibadah'] ?? jadwalAktif?['tanggalIbadah'] ?? "-"),
                            _buildInfoText("Waktu", jadwalAktif?['waktu'] ?? "-"),
                            _buildInfoText("Lokasi", jadwalAktif?['lokasi'] ?? "-"),
                            _buildInfoText("Pelayan Firman", jadwalAktif?['pelayan_firman'] ?? jadwalAktif?['pelayanFirman'] ?? "-"),
                            _buildInfoText("Penanggung Jawab", jadwalAktif?['penanggung_jawab'] ?? jadwalAktif?['penanggungJawab'] ?? "-"),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFE6F8E8), borderRadius: BorderRadius.circular(6)),
                              child: Text(
                                'Status: ${jadwalAktif?['status'] ?? "Aktif"}',
                                style: const TextStyle(color: Color(0xFF29C244), fontSize: 15, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      _buildSectionBox(
                        title: "Jadwal Ibadah Aktif",
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text("Belum ada jadwal ibadah aktif untuk rayon Anda saat ini.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ),
                        ),
                      ),

                    // --- SECTION: RIWAYAT ---
                    const SizedBox(height: 40),
                    const Text(
                      "Riwayat Jadwal Sebelumnya",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: navy),
                    ),
                    const SizedBox(height: 16),
                    if (riwayatJadwal.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFCFCFCF))),
                        child: const Text("Belum ada riwayat ibadah rayon.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                      )
                    else
                      ...riwayatJadwal.map((item) => _buildHistoryCard(item)),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const MemberBottomNavigation(currentIndex: -1),
    );
  }

  Widget _buildSectionBox({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 28),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: sectionGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: navy)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black, height: 1.6, fontWeight: FontWeight.w500),
          children: [
            TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.w800)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCFCFCF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['pelayan_firman'] ?? item['pelayanFirman'] ?? "Ibadah Rayon", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: navy)),
                const SizedBox(height: 8),
                Text(item['tanggal_ibadah'] ?? item['tanggal'] ?? "-", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(item['lokasi'] ?? "-", style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500))),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (item['status'] == 'Selesai') ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item['status'] ?? 'Selesai',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: (item['status'] == 'Selesai') ? const Color(0xFF15803D) : const Color(0xFF374151)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotRegisteredState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF3F4F6)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
              child: Column(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 64),
                  const SizedBox(height: 16),
                  const Text("Belum Terdaftar di Rayon", textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 12),
                  const Text(
                    "Akun Anda saat ini belum dihubungkan ke Rayon mana pun. Silakan hubungi Admin atau Pendeta untuk mengatur penempatan Rayon Anda.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF4B5563), fontSize: 15, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
