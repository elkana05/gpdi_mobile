import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
  // Mobile consistency colors
  static const Color navy = Color(0xFF05066F);
  static const Color redAccent = Color(0xFFD71313);
  static const Color softBg = Color(0xFFF7F4FB);
  static const Color textDark = Color(0xFF1E1E2F);
  static const Color textGrey = Color(0xFF85879A);

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
          // Sort newest first
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
      backgroundColor: Colors.white,
      drawer: isMember
          ? const MemberDrawer(activeMenu: MemberDrawerMenu.none)
          : const PublicDrawer(activeMenu: DrawerMenu.none),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: navy),
        title: const Text(
          'Renungan',
          style: TextStyle(color: navy, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRenungan,
        color: navy,
        child: isLoading
          ? const Center(child: CircularProgressIndicator(color: navy))
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 100),
              child: Column(
                children: [
                  // 1. HEADING (Identik React)
                  _buildHeader(),

                  const SizedBox(height: 48),

                  if (errorMsg.isNotEmpty)
                    _buildErrorState()
                  else if (renunganData.isEmpty)
                    _buildEmptyState()
                  else ...[
                    // 2. FEATURED CARD (Newest)
                    _buildFeaturedCard(renunganData.first),

                    const SizedBox(height: 48),

                    // 3. ARCHIVE LIST
                    if (renunganData.length > 1) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Arsip Renungan",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: navy),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      ...renunganData.skip(1).map((item) => _buildArchiveCard(item)),
                    ],
                  ],
                ],
              ),
            ),
      ),
      bottomNavigationBar: isMember
          ? const MemberBottomNavigation(currentIndex: 1)
          : const AppBottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          "Renungan Harian",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: navy),
        ),
        const SizedBox(height: 8),
        const Text(
          "“Firman Tuhan untuk Pertumbuhan Rohani”",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Text(
          _today,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: redAccent),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(RenunganItem item) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: const Border(top: BorderSide(color: navy, width: 6)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.tema,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: navy, height: 1.2),
          ),
          const SizedBox(height: 12),
          Text(
            "📖 ${item.ayatPokok}",
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: redAccent),
          ),
          const SizedBox(height: 32),
          Text(
            item.isi,
            style: const TextStyle(fontSize: 16, color: Color(0xFF374151), height: 1.8),
          ),
          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 20),
          Text(
            "Oleh: Pengurus GPdI Sibulele — ${_formatDate(item.publishedAt)}",
            style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveCard(RenunganItem item) {
    final bool isExpanded = expandedId == item.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDate(item.publishedAt).toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: redAccent, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Text(
            item.tema,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: navy),
          ),
          const SizedBox(height: 12),
          Text(
            item.isi,
            maxLines: isExpanded ? null : 3,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, color: Color(0xFF4B5563), height: 1.6),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => setState(() => expandedId = isExpanded ? null : item.id),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isExpanded ? "Tutup Tulisan ↑" : "Baca Selengkapnya →",
                  style: const TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_rounded, color: redAccent, size: 48),
            const SizedBox(height: 16),
            Text(errorMsg, style: const TextStyle(color: redAccent, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchRenungan,
              style: ElevatedButton.styleFrom(backgroundColor: navy),
              child: const Text("Coba Lagi", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Icon(Icons.auto_stories_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text("Belum ada renungan yang diterbitkan.", style: TextStyle(color: Colors.grey)),
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
