import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'public_drawer.dart';
import 'app_bottom_navigation.dart';

class PublicKontakScreen extends StatelessWidget {
  const PublicKontakScreen({super.key});

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F9FE);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF7A7C92);

  static const LatLng _churchLocation = LatLng(2.3331, 99.0625);

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
      drawer: const PublicDrawer(activeMenu: DrawerMenu.kontak),
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
        title: Text(
          "Kontak & Lokasi",
          style: GoogleFonts.montserrat(
            color: navy,
            fontWeight: FontWeight.w800,
            fontSize: 18,
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
            _buildSectionHeader('Media Komunikasi', 'Hubungi kami melalui platform berikut'),
            const SizedBox(height: 16),
            _buildContactGrid(),
            const SizedBox(height: 32),
            _buildSectionHeader('Lokasi Gereja', 'Mari kunjungi kami di Balige'),
            const SizedBox(height: 16),
            _buildMapCard(context),
            const SizedBox(height: 32),
            _buildAddressCard(),
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
          child: Text(
            'HUBUNGI KAMI',
            style: GoogleFonts.montserrat(
              color: gold,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Selalu Terhubung\ndengan Jemaat',
          style: GoogleFonts.montserrat(
            color: navy,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -1,
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
          style: GoogleFonts.montserrat(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.w800
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.montserrat(
            color: textGrey,
            fontSize: 13,
            fontWeight: FontWeight.w500
          ),
        ),
      ],
    );
  }

  Widget _buildContactGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildContactCard(
          icon: Icons.chat_rounded,
          title: 'WhatsApp',
          subtitle: '0812-6329-9741',
          color: const Color(0xFF25D366),
          onTap: () => _launchURL("https://wa.me/6281263299741"),
        ),
        _buildContactCard(
          icon: Icons.phone_rounded,
          title: 'Telepon',
          subtitle: 'Panggilan Suara',
          color: const Color(0xFF4A90E2),
          onTap: () => _launchURL("tel:081263299741"),
        ),
        _buildContactCard(
          icon: Icons.mail_rounded,
          title: 'Email',
          subtitle: 'Kirim Pesan',
          color: const Color(0xFFE53935),
          onTap: () => _launchURL("mailto:gpdisibulele@gmail.com"),
        ),
        _buildContactCard(
          icon: Icons.facebook_rounded,
          title: 'Facebook',
          subtitle: 'GPdI Sibulele',
          color: const Color(0xFF1877F2),
          onTap: () => _launchURL("https://facebook.com/GPdISibulele"),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    color: textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(
                    color: textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapCard(BuildContext context) {
    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            FlutterMap(
              options: const MapOptions(
                initialCenter: _churchLocation,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.gpdi.sibulele',
                ),
                const MarkerLayer(
                  markers: [
                    Marker(
                      point: _churchLocation,
                      width: 60,
                      height: 60,
                      child: Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFFD71313),
                        size: 45,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchURL("https://www.google.com/maps/search/?api=1&query=GPdI+Sibulele+Balige"),
                      icon: const Icon(Icons.map_rounded, size: 18),
                      label: const Text('Buka Maps'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => _churchLocation, // Just to show position again
                      icon: const Icon(Icons.my_location_rounded, color: navy),
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

  Widget _buildAddressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.church_rounded, color: gold, size: 22),
              ),
              const SizedBox(width: 16),
              Text(
                'GPdI Jemaat Sibulele',
                style: GoogleFonts.montserrat(
                  color: navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w800
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Jl. Sibulele No. 123, Balige, Kabupaten Toba, Sumatera Utara, 22312',
            style: GoogleFonts.montserrat(
              color: textDark,
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w600
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => _launchURL("https://www.google.com/maps/dir/?api=1&destination=GPdI+Sibulele+Balige"),
            icon: const Icon(Icons.directions_rounded, size: 18),
            label: const Text('Dapatkan Arah Perjalanan'),
            style: OutlinedButton.styleFrom(
              foregroundColor: navy,
              side: const BorderSide(color: navy, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}
