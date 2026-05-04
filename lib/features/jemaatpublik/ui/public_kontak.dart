import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'public_drawer.dart';
import 'app_bottom_navigation.dart';

class PublicKontakScreen extends StatelessWidget {
  const PublicKontakScreen({super.key});

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFFFC326);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _openWhatsApp() {
    // Nomor telepon gereja sesuai web
    _launchURL("https://wa.me/6281263299741");
  }

  void _openMap() {
    _launchURL("https://www.google.com/maps/search/?api=1&query=GPdI+Sibulele+Balige");
  }

  void _openDirections() {
    _launchURL("https://www.google.com/maps/dir/?api=1&destination=GPdI+Sibulele+Balige");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FC),
      drawer: const PublicDrawer(activeMenu: DrawerMenu.kontak),
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
          "Kontak & Lokasi",
          style: TextStyle(color: navy, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Center(
                  child: Column(
                    children: [
                      const Text(
                        "Kontak & Lokasi",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: navy,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Informasi Alamat dan Media Komunikasi Gereja",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Banner Image
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
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
                const SizedBox(height: 32),

                // Contact Detail Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: navy,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "GPdI Jemaat Sibulele",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD71313),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Jl. Sibulele No. 123, Balige, Toba, Sumatera Utara",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildContactItem(
                        icon: Icons.phone_rounded,
                        label: "Telepon",
                        value: "0812-6329-9741",
                        iconColor: Colors.blue,
                        onTap: () => _launchURL("tel:081263299741"),
                      ),
                      _buildContactItem(
                        icon: Icons.chat_rounded,
                        label: "WhatsApp",
                        value: "Chat WhatsApp",
                        isButton: true,
                        iconColor: Colors.green,
                        onTap: _openWhatsApp,
                      ),
                      _buildContactItem(
                        icon: Icons.email_rounded,
                        label: "Email",
                        value: "gpdisibulele@gmail.com",
                        iconColor: Colors.red,
                        onTap: () => _launchURL("mailto:gpdisibulele@gmail.com"),
                      ),
                      _buildContactItem(
                        icon: Icons.facebook_rounded,
                        label: "Facebook",
                        value: "GPdI Sibulele Official",
                        iconColor: Colors.blue.shade800,
                        isLink: true,
                        onTap: () => _launchURL("https://facebook.com/GPdISibulele"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Location Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Peta Lokasi",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: navy,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          image: const DecorationImage(
                            image: NetworkImage(
                              "https://maps.googleapis.com/maps/api/staticmap?center=GPdI+Sibulele+Balige&zoom=15&size=600x300&maptype=roadmap&markers=color:red%7CGC8P+J5M,+Sibulele,+Balige,+Toba,+North+Sumatra&key=YOUR_API_KEY",
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Center(
                          child: Icon(Icons.location_on, color: Colors.red.shade700, size: 40),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _openMap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: navy,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Google Maps", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _openDirections,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: navy,
                                side: const BorderSide(color: navy, width: 2),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Dapatkan Arah", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required VoidCallback onTap,
    bool isButton = false,
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
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
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                ),
                if (isButton)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: InkWell(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Chat WhatsApp",
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isLink ? Colors.blue : Colors.black87,
                        decoration: isLink ? TextDecoration.underline : null,
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
}
