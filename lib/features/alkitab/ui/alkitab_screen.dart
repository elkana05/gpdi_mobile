import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/auth_provider.dart';
import '../../jemaataktif/ui/member_drawer.dart';
import '../../jemaataktif/ui/member_bottom_navigation.dart';
import '../../jemaatpublik/ui/public_drawer.dart';
import '../../jemaatpublik/ui/app_bottom_navigation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

class AlkitabScreen extends StatefulWidget {
  const AlkitabScreen({super.key});

  @override
  State<AlkitabScreen> createState() => _AlkitabScreenState();
}

class _AlkitabScreenState extends State<AlkitabScreen> {
  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color redAccent = Color(0xFFD71313);
  static const Color softBg = Color(0xFFF8F9FE);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF7A7C92);

  bool isLoading = true;
  String errorMsg = '';
  List<RenunganItem> renunganData = [];
  int? expandedId;

  @override
  void initState() {
    super.initState();
    _fetchRenungan();
  }

  Future<void> _fetchRenungan() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMsg = '';
    });

    try {
      final response = await ApiClient().get(ApiConstants.devotionals);
      final List<dynamic> rawData = response is List ? response : (response['data'] ?? []);

      if (mounted) {
        setState(() {
          final items = rawData.map((item) => RenunganItem.fromJson(item)).toList();
          items.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
          renunganData = items;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMsg = "Gagal memuat renungan harian.";
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
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isMember = authProvider.status == AuthStatus.authenticated;

    return Scaffold(
      backgroundColor: softBg,
      drawer: isMember
          ? const MemberDrawer(activeMenu: MemberDrawerMenu.none)
          : const PublicDrawer(activeMenu: DrawerMenu.none),
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
          'Renungan Harian',
          style: GoogleFonts.montserrat(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRenungan,
        color: navy,
        child: isLoading
          ? const Center(child: CircularProgressIndicator(color: navy))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 32),
                        if (errorMsg.isNotEmpty)
                          _buildErrorState()
                        else if (renunganData.isEmpty)
                          _buildEmptyState()
                        else ...[
                          _buildSectionHeader('Renungan Hari Ini', _today),
                          const SizedBox(height: 16),
                          _buildFeaturedCard(renunganData.first),
                          const SizedBox(height: 40),
                          if (renunganData.length > 1) ...[
                            _buildSectionHeader('Arsip Renungan', 'Pelajari firman Tuhan lebih dalam'),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                if (renunganData.length > 1)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildArchiveCard(renunganData[index + 1]),
                          );
                        },
                        childCount: renunganData.length - 1,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
      ),
      bottomNavigationBar: isMember
          ? const MemberBottomNavigation(currentIndex: 1)
          : const AppBottomNavigation(currentIndex: 1),
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
            'SPIRITUAL GROWTH',
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
          'Firman Tuhan\nSetiap Hari',
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

  Widget _buildFeaturedCard(RenunganItem item) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [navy, Color(0xFF1A1B8C)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_stories_rounded, color: Color(0xFFFFD34E), size: 18),
                    const SizedBox(width: 10),
                    Text(
                      'TEMA HARI INI',
                      style: GoogleFonts.montserrat(
                        color: const Color(0xFFFFD34E),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  item.tema,
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.2
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.book_rounded, color: Colors.white70, size: 14),
                      const SizedBox(width: 8),
                      Text(
                        item.ayatPokok,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.isi,
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    color: const Color(0xFF374151),
                    height: 1.8,
                    fontWeight: FontWeight.w500
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Divider(),
                ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: navy.withOpacity(0.1),
                      child: const Icon(Icons.person_rounded, color: navy, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Oleh: Pengurus GPdI Sibulele",
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: textDark,
                            fontWeight: FontWeight.w800
                          ),
                        ),
                        Text(
                          _formatDate(item.publishedAt),
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: textGrey,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveCard(RenunganItem item) {
    final bool isExpanded = expandedId == item.id;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 5)
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => expandedId = isExpanded ? null : item.id),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatDate(item.publishedAt).toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: redAccent,
                          letterSpacing: 0.5
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: textGrey,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.tema,
                  style: GoogleFonts.montserrat(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: navy
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.isi,
                  maxLines: isExpanded ? null : 2,
                  overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: const Color(0xFF4B5563),
                    height: 1.6,
                    fontWeight: FontWeight.w500
                  ),
                ),
                if (isExpanded) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.book_rounded, size: 14, color: gold),
                      const SizedBox(width: 8),
                      Text(
                        item.ayatPokok,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textDark
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: redAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded, color: redAccent, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              errorMsg,
              style: GoogleFonts.montserrat(color: redAccent, fontWeight: FontWeight.w700)
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchRenungan,
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Coba Lagi"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.auto_stories_outlined, size: 64, color: textGrey.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              "Belum ada renungan.",
              style: GoogleFonts.montserrat(color: textGrey, fontWeight: FontWeight.w600)
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return "-";
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return dateString;
    }
  }
}

class RenunganItem {
  final int id;
  final String tema;
  final String ayatPokok;
  final String isi;
  final String publishedAt;

  RenunganItem({
    required this.id,
    required this.tema,
    required this.ayatPokok,
    required this.isi,
    required this.publishedAt,
  });

  factory RenunganItem.fromJson(Map<String, dynamic> json) {
    return RenunganItem(
      id: json['id'] ?? 0,
      tema: json['tema'] ?? json['title'] ?? 'Tanpa Judul',
      ayatPokok: json['ayat_pokok'] ?? json['reference'] ?? 'Alkitab',
      isi: json['isi'] ?? json['content'] ?? '',
      publishedAt: json['published_at'] ?? json['created_at'] ?? '',
    );
  }
}
