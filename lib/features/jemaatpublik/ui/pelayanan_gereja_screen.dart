import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/api_constants.dart';
import 'public_drawer.dart';
import 'app_bottom_navigation.dart';

class PelayananGerejaScreen extends StatefulWidget {
  const PelayananGerejaScreen({super.key});

  @override
  State<PelayananGerejaScreen> createState() => _PelayananGerejaScreenState();
}

class _PelayananGerejaScreenState extends State<PelayananGerejaScreen> {
  // Mobile consistency colors
  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color redAccent = Color(0xFFD71313);
  static const Color softBg = Color(0xFFF7F4FB);

  final String adminWhatsApp = "6281263299741";

  // Data Pelayanan (Identik dengan React pelayananData)
  final List<Map<String, dynamic>> items = [
    {
      'id': 1,
      'nama': 'Praise & Worship',
      'deskripsiSingkat': 'Melayani Tuhan melalui puji-pujian dan musik dalam ibadah.',
      'deskripsiLengkap': 'Tim musik dan penyanyi yang bertugas memimpin jemaat dalam memuji Tuhan setiap ibadah raya dan kegiatan gereja lainnya.',
      'gambar': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?q=80&w=1000',
      'jadwal': 'Latihan: Sabtu, 17:00 WIB',
      'penanggungJawab': 'Bpk. Andre Siburian',
      'syarat': ['Jemaat aktif', 'Memiliki bakat musik/vokal', 'Komitmen latihan'],
    },
    {
      'id': 2,
      'nama': 'Sekolah Minggu',
      'deskripsiSingkat': 'Membimbing anak-anak untuk mengenal Tuhan sejak dini.',
      'deskripsiLengkap': 'Pelayanan kategorial untuk anak-anak dengan metode pengajaran yang menarik dan berbasis Alkitab.',
      'gambar': 'https://images.unsplash.com/photo-1503945438517-f65904a52ce6?q=80&w=1000',
      'jadwal': 'Minggu, 08:00 WIB',
      'penanggungJawab': 'Ibu Sari Nasution',
      'syarat': ['Hati yang mengasihi anak-anak', 'Sabar dan kreatif'],
    },
    {
      'id': 3,
      'nama': 'Multimedia & IT',
      'deskripsiSingkat': 'Mendukung ibadah melalui teknologi visual dan streaming.',
      'deskripsiLengkap': 'Bertugas dalam pengelolaan sound system, live streaming, dan penyajian visual selama ibadah berlangsung.',
      'gambar': 'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?q=80&w=1000',
      'jadwal': 'Standby: Saat Ibadah',
      'penanggungJawab': 'Sdr. Kevin Panjaitan',
      'syarat': ['Menguasai dasar komputer/kamera', 'Teliti dan sigap'],
    },
  ];

  Future<void> _launchWhatsApp(String text) async {
    final Uri url = Uri.parse('https://wa.me/$adminWhatsApp?text=${Uri.encodeComponent(text)}');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showServiceDetail(Map<String, dynamic> item) {
    // Agar "tidak capek scroll ke bawah", kita gunakan Modal Bottom Sheet
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
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: navy),
        title: Text(
          'PELAYANAN',
          style: GoogleFonts.montserrat(color: navy, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.5),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. JUDUL (Identik React)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
              child: Column(
                children: [
                  Text(
                    'Berbagai Bidang Pelayanan',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: navy,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Temukan wadah untuk bertumbuh dan melayani bersama di GPdI Jemaat Sibulele',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(fontSize: 15, color: textGrey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            // 2. BANNER (Identik React)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: navy.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1515162305285-0293e4767cc2?q=80&w=1000'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // 3. GRID PELAYANAN (Identik React Items)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1, // Di mobile lebih baik list ke bawah atau 2 kolom, kita buat list elegan
                  mainAxisExtent: 280,
                  mainAxisSpacing: 20,
                ),
                itemBuilder: (context, index) => _buildServiceCard(items[index]),
              ),
            ),

            // 4. CTA SECTION (Identik React)
            _buildCTASection(),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: -1),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
      ),
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(image: NetworkImage(item['gambar']), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            item['nama'],
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: navy, fontSize: 18),
          ),
          const SizedBox(height: 12),
          Text(
            item['deskripsiSingkat'],
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.montserrat(color: textGrey, fontSize: 13, height: 1.5),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showServiceDetail(item),
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Lihat Detail', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 60, 24, 20),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: navy.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Text(
            'Terlibat dalam Pelayanan',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1),
          ),
          const SizedBox(height: 20),
          Text(
            'Bergabunglah bersama kami untuk melayani Tuhan dan sesama melalui berbagai pelayanan yang tersedia.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(fontSize: 15, color: Colors.white70, height: 1.6),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => _launchWhatsApp("Shalom admin, saya ingin mendaftar pelayanan di GPdI Jemaat Sibulele."),
            style: ElevatedButton.styleFrom(
              backgroundColor: redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text('Daftar Pelayanan', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  static const Color textGrey = Color(0xFF64748B);
}

class _ServiceDetailModal extends StatelessWidget {
  final Map<String, dynamic> item;
  final String adminWhatsApp;
  final Function(String) onContact;

  const _ServiceDetailModal({required this.item, required this.adminWhatsApp, required this.onContact});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Detail Pelayanan', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF05066F), fontSize: 24)),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(item['gambar'], height: 220, width: double.infinity, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 24),
                  Text(item['nama'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFD71313))),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.event_note_rounded, 'Jadwal:', item['jadwal']),
                  _buildDetailRow(Icons.person_pin_rounded, 'Penanggung Jawab:', item['penanggungJawab']),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(),
                  ),
                  Text(
                    item['deskripsiLengkap'],
                    style: const TextStyle(fontSize: 15, color: Color(0xFF4B5563), fontStyle: FontStyle.italic, height: 1.8),
                  ),
                  const SizedBox(height: 32),
                  const Text('Syarat Bergabung', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF05066F))),
                  const SizedBox(height: 12),
                  ...item['syarat'].map<Widget>((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, size: 18, color: Color(0xFFD71313)),
                            const SizedBox(width: 12),
                            Text(s, style: const TextStyle(fontSize: 15, color: Color(0xFF374151))),
                          ],
                        ),
                      )),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => onContact("Shalom admin, saya ingin mengetahui lebih lanjut tentang ${item['nama']}"),
                      icon: const Icon(Icons.chat_bubble_rounded),
                      label: const Text('Hubungi Admin'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF05066F)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF05066F))),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(color: Color(0xFF374151)))),
        ],
      ),
    );
  }
}
