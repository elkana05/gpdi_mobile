import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'public_drawer.dart';
import 'app_bottom_navigation.dart';

class PublicKontakScreen extends StatelessWidget {
  const PublicKontakScreen({super.key});

  // Warna konsisten mobile (Navy & Gold)
  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color redAccent = Color(0xFFD71313);
  static const Color softBg = Color(0xFFF7F4FB);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _openWhatsApp() {
    String phone = "081263299741";
    // Bersihkan nomor telepon agar hanya berisi angka untuk WA
    String cleanedPhone = phone.replaceAll(RegExp(r'\D'), '');
    _launchURL("https://wa.me/$cleanedPhone");
  }

  void _openMap() {
    // Sesuai query akurat di React
    _launchURL("https://www.google.com/maps/search/?api=1&query=GPdI+Sibulele+Balige");
  }

  void _openDirections() {
    // Sesuai query navigasi di React
    _launchURL("https://www.google.com/maps/dir/?api=1&destination=GPdI+Sibulele+Balige");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
      drawer: const PublicDrawer(activeMenu: DrawerMenu.kontak),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: navy),
        title: const Text(
          "Kontak & Lokasi",
          style: TextStyle(color: navy, fontWeight: FontWeight.w700, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            // 1. JUDUL (Sesuai React)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 34, 24, 0),
              child: Column(
                children: [
                  const Text(
                    "Kontak & Lokasi",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: navy,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Informasi Alamat dan Media Komunikasi Gereja",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // 2. BANNER (Sesuai React)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: NetworkImage(
                      "https://images.unsplash.com/photo-1544427920-c49ccfb85579?q=80&w=2000&auto=format&fit=crop",
                    ),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Divider(color: Color(0xFFE5E7EB)), // gray-200
            ),

            // 3. DETAIL KONTAK (Sesuai React)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Detail Kontak",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "GPdI Jemaat Sibulele",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: redAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Jl. Sibulele No. 123, Balige, Toba, Sumatera Utara",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF374151), // gray-700
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Telepon
                    _buildContactRow(
                      icon: Icons.phone_rounded,
                      label: "Telepon:",
                      value: "0812-6329-9741",
                      iconBg: const Color(0xFFEFF6FF), // blue-50
                      iconColor: Colors.blue.shade600,
                      onTap: () => _launchURL("tel:081263299741"),
                    ),

                    // WhatsApp
                    _buildContactRow(
                      icon: Icons.chat_rounded,
                      label: "WhatsApp:",
                      value: "Chat WhatsApp",
                      isWAButton: true,
                      iconBg: const Color(0xFFECFDF5), // green-50
                      iconColor: Colors.green.shade600,
                      onTap: _openWhatsApp,
                    ),

                    // Email
                    _buildContactRow(
                      icon: Icons.email_rounded,
                      label: "Email:",
                      value: "gpdisibulele@gmail.com",
                      iconBg: const Color(0xFFFEF2F2), // red-50
                      iconColor: Colors.red.shade600,
                      onTap: () => _launchURL("mailto:gpdisibulele@gmail.com"),
                    ),

                    // Facebook
                    _buildContactRow(
                      icon: Icons.facebook_rounded,
                      label: "Facebook:",
                      value: "GPdI Sibulele Official",
                      isLink: true,
                      iconBg: const Color(0xFFDBEAFE), // blue-100
                      iconColor: const Color(0xFF1E40AF), // blue-800
                      onTap: () => _launchURL("https://facebook.com/GPdISibulele"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 4. PETA LOKASI (Sesuai React)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Peta Lokasi",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Mobile Map Placeholder (Static map feel)
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      image: const DecorationImage(
                        image: NetworkImage(
                          "https://maps.googleapis.com/maps/api/staticmap?center=GPdI+Sibulele+Balige&zoom=15&size=600x400&maptype=roadmap&markers=color:red%7CGC8P+J5M,+Sibulele,+Balige,+Toba,+North+Sumatra&key=YOUR_API_KEY",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on, color: redAccent, size: 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Buttons (Sesuai React)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _openMap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: navy,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("Google Maps", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _openDirections,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: navy,
                            side: const BorderSide(color: navy, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("Dapatkan Arah", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: -1),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
    bool isWAButton = false,
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2937), fontSize: 16),
          ),
          const SizedBox(width: 8),
          if (isWAButton)
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Chat WhatsApp",
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            )
          else
            Expanded(
              child: GestureDetector(
                onTap: onTap,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: isLink ? Colors.blue.shade600 : const Color(0xFF4B5563),
                    fontWeight: isLink ? FontWeight.bold : FontWeight.normal,
                    decoration: isLink ? TextDecoration.underline : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
