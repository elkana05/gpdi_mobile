import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'public_drawer.dart';
import 'app_bottom_navigation.dart';

class PelayananGerejaScreen extends StatefulWidget {
  const PelayananGerejaScreen({super.key});

  @override
  State<PelayananGerejaScreen> createState() => _PelayananGerejaScreenState();
}

class _PelayananGerejaScreenState extends State<PelayananGerejaScreen> {
  static const Color navy = Color(0xFF0D1282);
  static const Color red = Color(0xFFD71313);
  static const Color softBg = Color(0xFFF8F9FA);

  // State untuk menyimpan pelayanan yang dipilih (Detail)
  Map<String, dynamic>? selectedItem;
  final String adminWhatsApp = "6281263299741";

  // Data Pelayanan (Sesuai struktur web)
  final List<Map<String, dynamic>> items = [
    {
      'id': 1,
      'nama': 'Sekolah Minggu',
      'deskripsiSingkat': 'Membina iman anak-anak melalui cerita Alkitab.',
      'deskripsiLengkap': 'Pelayanan kategorial yang berfokus pada pertumbuhan rohani anak-anak sejak usia dini dengan metode pengajaran yang kreatif, interaktif, dan sangat menyenangkan.',
      'gambar': 'https://images.unsplash.com/photo-1509062522246-3755977927d7?q=80&w=1000',
      'jadwal': 'Setiap Minggu, 08:00 WIB',
      'penanggungJawab': 'Pdt. Maria Sulastri',
      'syarat': ['Memiliki hati untuk anak-anak', 'Sabar dan kreatif', 'Sudah dibaptis air / Jemaat Aktif'],
    },
    {
      'id': 2,
      'nama': 'Pemuda & Remaja',
      'deskripsiSingkat': 'Wadah pertumbuhan rohani bagi generasi muda.',
      'deskripsiLengkap': 'Komunitas bagi kaum muda untuk bertumbuh bersama dalam iman, kepemimpinan, dan talenta. Kami fokus membangun generasi yang takut akan Tuhan.',
      'gambar': 'https://images.unsplash.com/photo-1529070538774-1843cb3265df?q=80&w=1000',
      'jadwal': 'Setiap Sabtu, 17:00 WIB',
      'penanggungJawab': 'Ev. Yohanes Pratama',
      'syarat': ['Usia 15 - 30 tahun', 'Bersemangat dalam komunitas', 'Aktif dalam kegiatan gereja'],
    },
    {
      'id': 3,
      'nama': 'Musik & Pujian',
      'deskripsiSingkat': 'Melayani Tuhan melalui talenta bermusik.',
      'deskripsiLengkap': 'Tim yang bertugas memimpin jemaat masuk dalam hadirat Tuhan melalui nyanyian pujian dan penyembahan yang diurapi setiap ibadah raya.',
      'gambar': 'https://images.unsplash.com/photo-1514525253361-b83f85dffa2b?q=80&w=1000',
      'jadwal': 'Latihan: Setiap Kamis, 19:00 WIB',
      'penanggungJawab': 'Bpk. David Simanjuntak',
      'syarat': ['Mampu bernyanyi/bermain alat musik', 'Setia dalam latihan rutin', 'Lulus audisi internal'],
    },
    {
      'id': 4,
      'nama': 'Multimedia',
      'deskripsiSingkat': 'Pengelolaan visual dan siaran digital.',
      'deskripsiLengkap': 'Mendukung pemberitaan Injil melalui teknologi visual, audio, dan dokumentasi digital untuk menjangkau jiwa-jiwa di platform digital.',
      'gambar': 'https://images.unsplash.com/photo-1516280440614-37939bb9edcc?q=80&w=1000',
      'jadwal': 'Setiap Ibadah Raya',
      'penanggungJawab': 'Sdr. Kevin Wijaya',
      'syarat': ['Menguasai alat kamera/OBS/Desain', 'Cekatan dan teliti', 'Mau belajar hal baru'],
    },
  ];

  Future<void> _openWhatsApp(String message) async {
    final Uri url = Uri.parse('https://wa.me/$adminWhatsApp?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      drawer: const PublicDrawer(activeMenu: DrawerMenu.pelayanan),
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
        title: Text(
          'PELAYANAN',
          style: GoogleFonts.montserrat(color: navy, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.5),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      // SECTION: HERO
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                        child: Column(
                          children: [
                            Text(
                              'Bidang Pelayanan',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.w900, color: navy, letterSpacing: 1.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Mari Melayani Tuhan Bersama Kami Melalui Berbagai Bidang Pelayanan yang Tersedia',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500, height: 1.5),
                            ),
                          ],
                        ),
                      ),

                      // SECTION: BANNER
                      Container(
                        margin: const EdgeInsets.all(24),
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                          image: const DecorationImage(
                            image: NetworkImage('https://images.unsplash.com/photo-1515162305285-0293e4767cc2?q=80&w=1000'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // SECTION: LIST CARDS
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: items.map((item) => _buildServiceCard(item)).toList(),
                        ),
                      ),

                      // SECTION: DETAIL (Muncul dinamis)
                      if (selectedItem != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: _buildDetailSection(),
                        ),

                      // SECTION: CTA BANNER
                      _buildCTASection(),

                      const SizedBox(height: 140),
                    ],
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

  Widget _buildServiceCard(Map<String, dynamic> item) {
    bool isSelected = selectedItem?['id'] == item['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isSelected ? navy : Colors.grey.shade100, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(item['gambar'], height: 70, width: 70, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Text(item['nama'], style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, color: navy, fontSize: 18)),
          const SizedBox(height: 8),
          Text(item['deskripsiSingkat'], textAlign: TextAlign.center, style: GoogleFonts.montserrat(color: Colors.grey[600], fontSize: 14, height: 1.5)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedItem = isSelected ? null : item;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.grey[200] : navy,
                foregroundColor: isSelected ? Colors.black87 : Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(isSelected ? 'TUTUP DETAIL' : 'LIHAT DETAIL', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 30)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Detail Pelayanan', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w900, color: navy)),
              IconButton(onPressed: () => setState(() => selectedItem = null), icon: const Icon(Icons.close_rounded, color: Colors.grey)),
            ],
          ),
          const Divider(height: 32),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(selectedItem!['gambar'], height: 200, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 24),
          Text(selectedItem!['nama'], style: GoogleFonts.montserrat(fontSize: 26, fontWeight: FontWeight.w900, color: red)),
          const SizedBox(height: 16),
          _detailRow('Jadwal:', selectedItem!['jadwal']),
          _detailRow('Penanggung Jawab:', selectedItem!['penanggungJawab']),
          const SizedBox(height: 20),
          Text(selectedItem!['deskripsiLengkap'], style: GoogleFonts.montserrat(fontSize: 16, height: 1.6, color: Colors.black54, fontStyle: FontStyle.italic)),
          const SizedBox(height: 24),
          Text('Syarat Bergabung', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: navy)),
          const SizedBox(height: 12),
          ... (selectedItem!['syarat'] as List).map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.check_circle, color: red, size: 20), const SizedBox(width: 10), Expanded(child: Text(s, style: GoogleFonts.montserrat(fontSize: 15)))]),
          )),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openWhatsApp('Shalom admin, saya ingin mengetahui lebih lanjut tentang ${selectedItem!['nama']}.'),
              icon: const Icon(Icons.message, size: 20),
              label: Text('HUBUNGI ADMIN', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, letterSpacing: 1)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(text: TextSpan(style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black87), children: [TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold, color: navy)), TextSpan(text: value)])),
    );
  }

  Widget _buildCTASection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 60, 24, 0),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: navy.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 15))],
      ),
      child: Column(
        children: [
          Text('Terlibat dalam Pelayanan', textAlign: TextAlign.center, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, height: 1.2)),
          const SizedBox(height: 20),
          Text(
            'Bergabunglah bersama kami untuk melayani Tuhan dan sesama melalui berbagai pelayanan yang tersedia.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(color: Colors.white.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.w500, height: 1.6),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => _openWhatsApp('Shalom admin, saya ingin mendaftar pelayanan di GPdI Jemaat Sibulele.'),
            style: ElevatedButton.styleFrom(
              backgroundColor: red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              elevation: 8,
              shadowColor: red.withOpacity(0.5),
            ),
            child: Text('DAFTAR PELAYANAN', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }
}
