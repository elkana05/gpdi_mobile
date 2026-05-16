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
  static const Color softBg = Color(0xFFF8F9FE);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF7A7C92);
  static const Color redAccent = Color(0xFFD71313);

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
      final response = await ApiClient().get(ApiConstants.rayonSchedules);
      final data = (response is Map<String, dynamic> && response.containsKey('data'))
          ? response['data']
          : response;

      if (mounted) {
        setState(() {
          rayonInfo = data['rayon'];
          jadwalAktif = data['jadwalAktif'] ?? data['jadwal_aktif'];
          riwayatJadwal = data['riwayat'] ?? [];

          if (rayonInfo == null) {
            namaKetua = "-";
          }
        });

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
      backgroundColor: softBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: navy.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu_rounded, color: navy, size: 22),
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: const Text(
          'Jadwal Rayon',
          style: TextStyle(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
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
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),

                    _buildSectionHeader('Rayon Anda', 'Informasi kelompok pelayanan Anda'),
                    const SizedBox(height: 16),
                    _buildRayonInfoCard(),

                    const SizedBox(height: 32),
                    _buildSectionHeader('Jadwal Aktif', 'Ibadah rayon yang akan datang'),
                    const SizedBox(height: 16),
                    _buildJadwalAktifCard(),

                    const SizedBox(height: 32),
                    _buildSectionHeader('Riwayat Ibadah', 'Catatan ibadah rayon sebelumnya'),
                    const SizedBox(height: 16),
                    if (riwayatJadwal.isEmpty)
                      _buildEmptyState("Belum ada riwayat ibadah rayon.")
                    else
                      ...riwayatJadwal.map((item) => _buildHistoryCard(item)),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: const MemberBottomNavigation(currentIndex: -1),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'IBADAH RAYON',
            style: TextStyle(
              color: gold,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Jadwal & Informasi\nPelayanan Rayon',
          style: TextStyle(
            color: navy,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _today,
          style: const TextStyle(
            color: redAccent,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.w800
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: textGrey,
            fontSize: 13,
            fontWeight: FontWeight.w500
          ),
        ),
      ],
    );
  }

  Widget _buildRayonInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.groups_rounded, "Nama Rayon", rayonInfo?['nama_rayon'] ?? rayonInfo?['namaRayon'] ?? "-", gold),
          const Divider(height: 32, thickness: 0.5),
          _buildInfoRow(Icons.person_pin_rounded, "Ketua Rayon", namaKetua, navy),
          const Divider(height: 32, thickness: 0.5),
          _buildInfoRow(Icons.info_outline_rounded, "Keterangan", rayonInfo?['keterangan'] ?? "-", Colors.blueGrey),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: navy.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: navy.withOpacity(0.1)),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, color: gold, size: 16),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Informasi jadwal diperbarui secara real-time oleh Ketua Rayon.',
                    style: TextStyle(
                      fontSize: 12,
                      color: textGrey,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: textGrey, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
              Text(
                value,
                style: const TextStyle(color: textDark, fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJadwalAktifCard() {
    if (jadwalAktif == null || jadwalAktif!.isEmpty) {
      return _buildEmptyState("Belum ada jadwal ibadah aktif untuk rayon Anda saat ini.");
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [navy, Color(0xFF1A1B8C)],
        ),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.event_available_rounded,
              size: 140,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stars_rounded, color: Color(0xFFFFD34E), size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'JADWAL BERIKUTNYA',
                          style: TextStyle(
                            color: Color(0xFFFFD34E),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          )
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'AKTIF',
                        style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildJadwalDetail(Icons.calendar_today_rounded, "Tanggal", jadwalAktif?['tanggal_ibadah'] ?? jadwalAktif?['tanggalIbadah'] ?? "-"),
                const SizedBox(height: 12),
                _buildJadwalDetail(Icons.access_time_rounded, "Waktu", jadwalAktif?['waktu'] ?? "-"),
                const SizedBox(height: 12),
                _buildJadwalDetail(Icons.location_on_rounded, "Lokasi", jadwalAktif?['lokasi'] ?? "-"),
                const SizedBox(height: 12),
                _buildJadwalDetail(Icons.person_rounded, "Pelayan Firman", jadwalAktif?['pelayan_firman'] ?? jadwalAktif?['pelayanFirman'] ?? "-"),
                const SizedBox(height: 12),
                _buildJadwalDetail(Icons.assignment_ind_rounded, "PJ Ibadah", jadwalAktif?['penanggung_jawab'] ?? jadwalAktif?['penanggungJawab'] ?? "-"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalDetail(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.6), size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
              children: [
                TextSpan(text: "$label: ", style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w500)),
                TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: navy.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.history_rounded, color: navy, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['tanggal_ibadah'] ?? item['tanggal'] ?? "-",
                  style: const TextStyle(color: textGrey, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  item['pelayan_firman'] ?? item['pelayanFirman'] ?? "Ibadah Rayon",
                  style: const TextStyle(color: textDark, fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 12, color: gold),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item['lokasi'] ?? "-",
                        style: const TextStyle(color: textGrey, fontSize: 13, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'SELESAI',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF15803D)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded, size: 48, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: textGrey, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotRegisteredState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 40),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Belum Terdaftar",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: navy),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Akun Anda saat ini belum dihubungkan ke Rayon mana pun. Silakan hubungi Admin atau Pendeta untuk mengatur penempatan Rayon Anda.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textGrey, fontSize: 14, height: 1.6, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: fetchData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: const Text('Refresh Halaman', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
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
