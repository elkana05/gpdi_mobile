import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../jemaatpublik/providers/content_provider.dart';
import '../../jemaatpublik/models/content_model.dart';
import 'member_drawer.dart';
import 'member_bottom_navigation.dart';

class MemberPengumumanScreen extends StatefulWidget {
  const MemberPengumumanScreen({super.key});

  @override
  State<MemberPengumumanScreen> createState() => _MemberPengumumanScreenState();
}

class _MemberPengumumanScreenState extends State<MemberPengumumanScreen> {
  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color redAccent = Color(0xFFD71313);
  static const Color softBg = Color(0xFFF8F9FE);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF7A7C92);

  final TextEditingController _searchController = TextEditingController();
  String _keyword = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ContentProvider>(context, listen: false).fetchAnnouncements();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<AnnouncementModel> _getFilteredAnnouncements(List<AnnouncementModel> items) {
    if (_keyword.isEmpty) return items;
    return items.where((item) {
      return item.title.toLowerCase().contains(_keyword.toLowerCase()) ||
          item.content.toLowerCase().contains(_keyword.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MemberDrawer(activeMenu: MemberDrawerMenu.pengumuman),
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
          final filteredItems = _getFilteredAnnouncements(provider.announcements);

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
                        _buildSearchField(),
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
                else if (filteredItems.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(_keyword.isEmpty ? "Belum Ada Pengumuman" : "Pencarian Tidak Ditemukan"),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = filteredItems[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _buildAnnouncementCard(item),
                          );
                        },
                        childCount: filteredItems.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
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
          'Pengumuman\nKhusus Jemaat',
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

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _keyword = value),
        decoration: InputDecoration(
          hintText: "Cari warta...",
          hintStyle: GoogleFonts.montserrat(color: textGrey, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: textGrey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
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
            color: Colors.black.withOpacity(0.03),
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
                    color: redAccent.withOpacity(0.1),
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

  Widget _buildEmptyState(String message) {
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
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
                ],
              ),
              child: Icon(Icons.campaign_rounded, color: textGrey.withOpacity(0.3), size: 64),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: GoogleFonts.montserrat(color: textDark, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            if (_keyword.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Warta jemaat terbaru akan muncul di sini segera setelah tersedia.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(color: textGrey, fontSize: 14, fontWeight: FontWeight.w500),
                ),
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
            color: const Color(0xFF05066F).withOpacity(0.3),
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
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.format_quote_rounded, color: Colors.white.withOpacity(0.5), size: 32),
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
                    color: Colors.white.withOpacity(0.1),
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
