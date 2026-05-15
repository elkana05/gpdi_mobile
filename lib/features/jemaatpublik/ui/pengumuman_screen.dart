import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';
import '../models/content_model.dart';
import 'public_drawer.dart';
import 'app_bottom_navigation.dart';

class PengumumanScreen extends StatefulWidget {
  const PengumumanScreen({super.key});

  @override
  State<PengumumanScreen> createState() => _PengumumanScreenState();
}

class _PengumumanScreenState extends State<PengumumanScreen> {
  // Mobile consistency colors
  static const Color navy = Color(0xFF05066F);
  static const Color redAccent = Color(0xFFD71313);
  static const Color softBg = Color(0xFFF7F4FB);
  static const Color textDark = Color(0xFF1E1E2F);
  static const Color textGrey = Color(0xFF85879A);

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ContentProvider>(context, listen: false).fetchAnnouncements());
  }

  String _formatTanggal(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _getBadgeLabel(String? category) {
    final cat = category?.toLowerCase() ?? '';
    if (cat == 'publik') return "Pengumuman Publik";
    if (cat == 'jemaat') return "Internal Jemaat";
    if (cat == 'rayon') return "Khusus Rayon";
    return "Warta Jemaat";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PublicDrawer(activeMenu: DrawerMenu.pengumuman),
      backgroundColor: softBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: navy),
        title: const Text(
          'Pengumuman',
          style: TextStyle(color: navy, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Consumer<ContentProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () => provider.fetchAnnouncements(),
            color: navy,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // 1. HEADING (Identik React)
                  _buildHeader(),

                  // 2. BANNER (Identik React dengan Ayat/Quote)
                  _buildBanner(),

                  const SizedBox(height: 40),

                  // 3. LIST PENGUMUMAN
                  if (provider.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: CircularProgressIndicator(color: navy),
                    )
                  else if (provider.announcements.isEmpty)
                    _buildEmptyState()
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.announcements.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          final item = provider.announcements[index];
                          return _buildAnnouncementCard(item);
                        },
                      ),
                    ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: -1),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 34, 24, 0),
      child: Column(
        children: [
          Text(
            'Pengumuman',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: navy,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Warta dan Informasi Terbaru Jemaat GPdI Sibulele',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: navy,
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: const NetworkImage(
              "https://images.unsplash.com/photo-1455849318743-b2233052fcff?q=80&w=2069&auto=format&fit=crop",
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(navy.withOpacity(0.6), BlendMode.darken),
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "\"Sebab Aku ini mengetahui rancangan-rancangan apa yang ada pada-Ku mengenai kamu, demikianlah firman TUHAN, yaitu rancangan damai sejahtera dan bukan rancangan kecelakaan, untuk memberikan kepadamu hari depan yang penuh harapan.\"",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "— Yeremia 29:11",
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
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
          // Header Card
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getBadgeLabel(item.category),
                        style: const TextStyle(
                          color: redAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatTanggal(item.date),
                style: const TextStyle(color: textGrey, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          // Deskripsi
          Text(
            item.content,
            style: const TextStyle(
              color: Color(0xFF4B5563), // gray-700
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200, width: 2),
              ),
              child: const Icon(Icons.campaign_outlined, color: Colors.grey, size: 48),
            ),
            const SizedBox(height: 20),
            const Text(
              "Belum ada pengumuman terbaru saat ini.",
              style: TextStyle(color: textGrey, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
