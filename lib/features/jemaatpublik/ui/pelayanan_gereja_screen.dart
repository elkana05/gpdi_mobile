import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'public_drawer.dart';
import 'app_bottom_navigation.dart';

class PelayananGerejaScreen extends StatefulWidget {
  const PelayananGerejaScreen({super.key});

  @override
  State<PelayananGerejaScreen> createState() => _PelayananGerejaScreenState();
}

class _PelayananGerejaScreenState extends State<PelayananGerejaScreen> {
  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color redAccent = Color(0xFFD71313);
  static const Color softBg = Color(0xFFF8F9FE);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF7A7C92);

  final String adminWhatsApp = "6281263299741";

  final List<Map<String, dynamic>> items = [
    {
      'id': 1,
      'nama': 'Praise & Worship',
      'icon': Icons.music_note_rounded,
      'color': const Color(0xFF4A90E2),
      'tagline': 'Memuji Tuhan dengan Talenta',
      'deskripsiSingkat': 'Melayani melalui puji-pujian dan musik dalam setiap ibadah.',
      'deskripsiLengkap': 'Tim musik dan penyanyi yang bertugas memimpin jemaat dalam memuji Tuhan setiap ibadah raya dan kegiatan gereja lainnya. Kami percaya musik adalah sarana yang luar biasa untuk menghadirkan hadirat Tuhan.',
      'jadwal': 'Latihan: Sabtu, 17:00 WIB',
      'penanggungJawab': 'Bpk. Andre Siburian',
      'syarat': ['Jemaat aktif', 'Memiliki bakat musik/vokal', 'Komitmen waktu latihan'],
    },
    {
      'id': 2,
      'nama': 'Sekolah Minggu',
      'icon': Icons.child_care_rounded,
      'color': const Color(0xFFF5A623),
      'tagline': 'Membangun Generasi Ilahi',
      'deskripsiSingkat': 'Membimbing anak-anak mengenal Tuhan sejak usia dini.',
      'deskripsiLengkap': 'Pelayanan kategorial untuk anak-anak dengan metode pengajaran yang kreatif, menarik, dan berbasis Alkitab. Fokus kami adalah menanamkan nilai-nilai Kristiani sejak dini.',
      'jadwal': 'Ibadah: Minggu, 08:00 WIB',
      'penanggungJawab': 'Ibu Sari Nasution',
      'syarat': ['Hati yang mengasihi anak-anak', 'Sabar dan kreatif', 'Bersedia belajar'],
    },
    {
      'id': 3,
      'nama': 'Multimedia & IT',
      'icon': Icons.computer_rounded,
      'color': const Color(0xFF7ED321),
      'tagline': 'Melayani Lewat Teknologi',
      'deskripsiSingkat': 'Mendukung ibadah melalui visual, sound, dan streaming.',
      'deskripsiLengkap': 'Bertugas dalam pengelolaan sound system, live streaming, dan penyajian visual selama ibadah berlangsung. Kami memastikan pesan firman Tuhan tersampaikan dengan jelas melalui teknologi.',
      'jadwal': 'Tugas: Setiap Jadwal Ibadah',
      'penanggungJawab': 'Sdr. Kevin Panjaitan',
      'syarat': ['Menguasai dasar komputer/kamera', 'Teliti dan sigap', 'Mau belajar hal baru'],
    },
    {
      'id': 4,
      'nama': 'Diakonia',
      'icon': Icons.volunteer_activism_rounded,
      'color': const Color(0xFFD0021B),
      'tagline': 'Wujud Nyata Kasih Kristus',
      'deskripsiSingkat': 'Pelayanan kasih bagi jemaat yang sedang membutuhkan.',
      'deskripsiLengkap': 'Memberikan bantuan sosial, doa, dan kunjungan bagi jemaat yang sakit atau mengalami kesulitan. Kami menjadi tangan kanan gereja untuk menjangkau mereka yang lemah.',
      'jadwal': 'Kegiatan: Kondisional',
      'penanggungJawab': 'Ibu Maria Gultom',
      'syarat': ['Memiliki empati yang tinggi', 'Rendah hati', 'Rahasia jemaat terjamin'],
    },
  ];

  Future<void> _launchWhatsApp(String text) async {
    final Uri url = Uri.parse('https://wa.me/$adminWhatsApp?text=${Uri.encodeComponent(text)}');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showServiceDetail(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ServiceDetailModal(
        item: item,
        adminWhatsApp: adminWhatsApp,
        onContact: (text) => _launchWhatsApp(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PublicDrawer(activeMenu: DrawerMenu.pelayanan),
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
          'Bidang Pelayanan',
          style: TextStyle(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildSectionHeader('Wadah Melayani', 'Klik untuk melihat detail setiap bidang'),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) => _buildServiceCard(items[index]),
            ),
            const SizedBox(height: 40),
            _buildCTASection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: -1),
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
            'PELAYANAN GEREJA',
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
          'Gunakan Talenta Anda\nuntuk Kemuliaan-Nya',
          style: TextStyle(
            color: navy,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tuhan memanggil setiap kita untuk melayani sesuai karunia yang diberikan. Temukan tempat di mana Anda bisa berdampak bagi sesama.',
          style: TextStyle(
            color: textGrey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.5
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

  Widget _buildServiceCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showServiceDetail(item),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(item['icon'], color: item['color'], size: 30),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['nama'],
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 17,
                          fontWeight: FontWeight.w800
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['tagline'],
                        style: TextStyle(
                          color: item['color'],
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['deskripsiSingkat'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textGrey,
                          fontSize: 13,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: textGrey.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCTASection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [navy, Color(0xFF1A1B8C)],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_rounded, color: gold, size: 32),
          ),
          const SizedBox(height: 24),
          const Text(
            'Siap Untuk Melayani?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Klik tombol di bawah untuk terhubung dengan tim koordinasi pelayanan kami.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              height: 1.5
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _launchWhatsApp("Shalom admin, saya ingin mendaftar pelayanan di GPdI Jemaat Sibulele."),
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text(
              'Daftar Pelayanan Sekarang',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceDetailModal extends StatelessWidget {
  final Map<String, dynamic> item;
  final String adminWhatsApp;
  final Function(String) onContact;

  const _ServiceDetailModal({
    required this.item,
    required this.adminWhatsApp,
    required this.onContact
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2)
            )
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(item['icon'], color: item['color'], size: 28),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DETAIL BIDANG',
                              style: TextStyle(
                                color: (item['color'] as Color),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5
                              )
                            ),
                            const Text(
                              'Pelayanan',
                              style: TextStyle(
                                color: Color(0xFF05066F),
                                fontSize: 22,
                                fontWeight: FontWeight.w900
                              )
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF7A7C92))
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Apa Itu Pelayanan Ini?',
                    style: TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 16,
                      fontWeight: FontWeight.w800
                    )
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['deskripsiLengkap'],
                    style: const TextStyle(
                      color: Color(0xFF7A7C92),
                      fontSize: 15,
                      height: 1.7,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildInfoCard(Icons.access_time_filled_rounded, 'Waktu Pelayanan', item['jadwal']),
                  const SizedBox(height: 12),
                  _buildInfoCard(Icons.account_circle_rounded, 'Penanggung Jawab', item['penanggungJawab']),
                  const SizedBox(height: 32),
                  const Text(
                    'Kualifikasi & Syarat',
                    style: TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 16,
                      fontWeight: FontWeight.w800
                    )
                  ),
                  const SizedBox(height: 16),
                  ...item['syarat'].map<Widget>((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: (item['color'] as Color).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check, size: 10, color: item['color']),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          s,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1A1A2E),
                            fontWeight: FontWeight.w600
                          )
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => onContact("Shalom admin, saya ingin mengetahui lebih lanjut tentang ${item['nama']}"),
                      icon: const Icon(Icons.message_rounded),
                      label: const Text('Hubungi Koordinator'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF05066F)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF7A7C92),
                  fontSize: 11,
                  fontWeight: FontWeight.w700
                )
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 14,
                  fontWeight: FontWeight.w800
                )
              ),
            ],
          ),
        ],
      ),
    );
  }
}
