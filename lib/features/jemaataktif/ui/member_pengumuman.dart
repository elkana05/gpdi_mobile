import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import 'member_drawer.dart';
import 'member_bottom_navigation.dart';

class MemberPengumumanScreen extends StatefulWidget {
  const MemberPengumumanScreen({super.key});

  @override
  State<MemberPengumumanScreen> createState() => _MemberPengumumanScreenState();
}

class _MemberPengumumanScreenState extends State<MemberPengumumanScreen> {
  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFFFC326);

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String category = "Semua Pengumuman";
  String keyword = "";
  bool loading = true;
  String errorMsg = '';
  int? expandedId;

  List<PengumumanItem> pengumumanData = [];

  final List<String> categories = const [
    "Semua Pengumuman",
    "Publik",
    "Internal Jemaat",
    "Rayon",
  ];

  @override
  void initState() {
    super.initState();
    fetchPengumuman();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchPengumuman() async {
    if (!mounted) return;
    setState(() {
      loading = true;
      errorMsg = '';
    });
    try {
      debugPrint("🚀 [API DEBUG] Memanggil: ${ApiConstants.baseUrl}${ApiConstants.announcements}");

      final response = await ApiClient().get(ApiConstants.announcements);

      // Log respon lengkap untuk pengecekan di console
      debugPrint("📦 [API RESPONSE]: $response");

      final List<dynamic> res = response is List ? response : (response['data'] ?? []);

      if (mounted) {
        setState(() {
          pengumumanData = res.map((item) => PengumumanItem.fromJson(item)).toList().reversed.toList();
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ [API ERROR]: $e");
      if (mounted) {
        setState(() {
          errorMsg = e.toString().contains('404')
              ? "Endpoint tidak ditemukan (404). Periksa rute API di backend."
              : e.toString();
          loading = false;
        });
      }
    }
  }

  List<PengumumanItem> get filteredData {
    return pengumumanData.where((item) {
      // Logic Filter Kategori
      bool matchCategory = true;
      if (category != "Semua Pengumuman") {
        String targetScope = category.toLowerCase().split(' ').last; // jemaat, publik, rayon
        matchCategory = item.category.toLowerCase().contains(targetScope);
      }

      final q = keyword.toLowerCase().trim();
      final matchSearch = q.isEmpty ||
          item.title.toLowerCase().contains(q) ||
          item.summary.toLowerCase().contains(q);

      return matchCategory && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FC),
      drawer: const MemberDrawer(activeMenu: MemberDrawerMenu.pengumuman),
      resizeToAvoidBottomInset: false,
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
          "Pengumuman Gereja",
          style: TextStyle(color: navy, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return RefreshIndicator(
                onRefresh: fetchPengumuman,
                color: navy,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSearchFilter(),
                          const SizedBox(height: 24),
                          if (loading)
                            const Center(child: Padding(
                              padding: EdgeInsets.only(top: 100),
                              child: CircularProgressIndicator(color: navy),
                            ))
                          else if (errorMsg.isNotEmpty)
                            _buildErrorState()
                          else if (filteredData.isEmpty)
                            _buildEmptyState()
                          else
                            ...filteredData.map((item) => _buildAnnouncementCard(item)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MemberBottomNavigation(currentIndex: -1),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(errorMsg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchPengumuman,
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
        padding: EdgeInsets.only(top: 80),
        child: Column(
          children: [
            Icon(Icons.announcement_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("Tidak ada pengumuman ditemukan", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: category,
            items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => category = v!),
            decoration: _inputDeco(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: _inputDeco(hint: "Cari kata kunci..."),
            onChanged: (v) => setState(() => keyword = v),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(PengumumanItem item) {
    final bool isExpanded = expandedId == item.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.category.toUpperCase(),
                  style: const TextStyle(color: Color(0xFF866B00), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Text(item.publishedAt, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navy),
          ),
          const SizedBox(height: 8),
          Text(
            item.summary,
            maxLines: isExpanded ? null : 3,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade800, height: 1.5, fontSize: 15),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => setState(() => expandedId = isExpanded ? null : item.id),
            child: Text(
              isExpanded ? "Tutup" : "Baca Selengkapnya",
              style: const TextStyle(color: navy, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF1EFFB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}

class PengumumanItem {
  final int id;
  final String title;
  final String category;
  final String publishedAt;
  final String summary;

  PengumumanItem({
    required this.id,
    required this.title,
    required this.category,
    required this.publishedAt,
    required this.summary,
  });

  factory PengumumanItem.fromJson(Map<String, dynamic> json) {
    return PengumumanItem(
      id: json['id'] ?? 0,
      title: json['judul'] ?? json['title'] ?? 'Tanpa Judul',
      category: json['scope'] ?? json['category'] ?? 'Umum',
      publishedAt: formatTanggalIndonesia(json['created_at']),
      summary: json['isi'] ?? json['content'] ?? '',
    );
  }
}

String formatTanggalIndonesia(dynamic value) {
  if (value == null) return "-";
  try {
    final date = DateTime.parse(value.toString());
    const bulan = ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"];
    return "${date.day} ${bulan[date.month - 1]} ${date.year}";
  } catch (_) {
    return value.toString();
  }
}
