import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color redAccent = Color(0xFFD71313);
  static const Color softBg = Color(0xFFF8F9FE);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF7A7C92);

  @override
  void initState() {
    super.initState();
    // Menggunakan addPostFrameCallback untuk menghindari async gap warning
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ContentProvider>(context, listen: false).fetchAnnouncements();
      }
    });
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
    if (cat == 'publik') return "PENGUMUMAN PUBLIK";
    if (cat == 'jemaat') return "INTERNAL JEMAAT";
    if (cat == 'rayon') return "KHUSUS RAYON";
    return "WARTA JEMAAT";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PublicDrawer(activeMenu: DrawerMenu.pengumuman),
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
                  color: navy.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu_rounded, color: navy, size: 22),
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: Text(
          'Warta Jemaat',
          style: GoogleFonts.montserrat(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<ContentProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () => provider.fetchAnnouncements(),
            color: navy,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        const _QuoteCard(),
                        const SizedBox(height: 32),
                        _buildSectionHeader('Info & Pengumuman', 'Warta terbaru dari gereja kami'),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                if (provider.isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: navy)),
                  )
                else if (provider.announcements.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = provider.announcements[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _buildAnnouncementCard(item),
                          );
                        },
                        childCount: provider.announcements.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          );
        },
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
            color: gold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'WARTA & INFO',
            style: GoogleFonts.montserrat(
              color: gold,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Pengumuman\nJemaat Sibulele',
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
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.montserrat(
            color: textGrey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getBadgeLabel(item.category),
                    style: GoogleFonts.montserrat(
                      color: redAccent,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Text(
                  _formatTanggal(item.date),
                  style: GoogleFonts.montserrat(
                    color: textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.montserrat(
                    color: navy,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),
                Text(
                  item.content,
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF4B5563),
                    fontSize: 14,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20),
                ],
              ), // Perbaikan kurung di sini: sebelumnya ],
              child: Icon(Icons.campaign_rounded, color: textGrey.withValues(alpha: 0.3), size: 64),
            ),
            const SizedBox(height: 24),
            Text(
              "Belum Ada Pengumuman",
              style: GoogleFonts.montserrat(color: textDark, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              "Warta jemaat terbaru akan muncul di sini segera setelah tersedia.",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(color: textGrey, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF05066F), Color(0xFF1A1B8C)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF05066F).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.auto_awesome,
              size: 100,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.format_quote_rounded, color: Colors.white.withValues(alpha: 0.5), size: 32),
                const SizedBox(height: 12),
                Text(
                  "Sebab Aku ini mengetahui rancangan-rancangan apa yang ada pada-Ku mengenai kamu, demikianlah firman TUHAN, yaitu rancangan damai sejahtera...",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "— Yeremia 29:11",
                    style: GoogleFonts.montserrat(color: const Color(0xFFFFD34E), fontSize: 12, fontWeight: FontWeight.w800),
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
