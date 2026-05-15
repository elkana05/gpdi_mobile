import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  // Theme Colors
  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color redAccent = Color(0xFFD71313);
  static const Color softBg = Color(0xFFF7F4FB);

  final TextEditingController _searchController = TextEditingController();

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
    super.dispose();
  }

  Future<void> fetchPengumuman() async {
    if (!mounted) return;
    setState(() {
      loading = true;
      errorMsg = '';
    });
    try {
      final response = await ApiClient().get(ApiConstants.announcements);
      final List<dynamic> res = response is List ? response : (response['data'] ?? []);

      if (mounted) {
        setState(() {
          // Filter status "Aktif" & Reverse (Newest first) sesuai React
          pengumumanData = res
              .where((item) => item['status'] == "Aktif")
              .map((item) => PengumumanItem.fromJson(item))
              .toList()
              .reversed
              .toList();
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMsg = "Gagal memuat pengumuman.";
          loading = false;
        });
      }
    }
  }

  List<PengumumanItem> get filteredData {
    return pengumumanData.where((item) {
      // Logic Kategori sesuai React
      bool matchCategory = category == "Semua Pengumuman" ||
          item.category.toLowerCase() == category.toLowerCase();

      // Logic Search sesuai React
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
      backgroundColor: Colors.white,
      drawer: const MemberDrawer(activeMenu: MemberDrawerMenu.pengumuman),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: navy),
        title: const Text(
          "Pengumuman",
          style: TextStyle(color: navy, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchPengumuman,
        color: navy,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // ══ HEADING (Identik React) ══
              _buildHeader(),

              // ══ HERO BANNER (Identik React) ══
              _buildHeroBanner(),

              // ══ SEARCH & FILTER FORM ══
              _buildSearchFilter(),

              // ══ LIST PENGUMUMAN ══
              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: CircularProgressIndicator(color: navy),
                )
              else if (errorMsg.isNotEmpty)
                _buildErrorState()
              else if (filteredData.isEmpty)
                _buildEmptyState()
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredData.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 20),
                    itemBuilder: (context, index) => _buildAnnouncementCard(filteredData[index]),
                  ),
                ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MemberBottomNavigation(currentIndex: -1),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 32, 20, 16),
      child: Column(
        children: [
          Text(
            'Pengumuman Gereja',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: navy),
          ),
          SizedBox(height: 8),
          Text(
            'Informasi Resmi untuk Jemaat',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF374151), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: navy,
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: const NetworkImage(
              "https://images.unsplash.com/photo-1438232992991-995b7058bbb3?q=80&w=2073&auto=format&fit=crop",
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
                "\"Memperhatikan setiap informasi adalah bentuk partisipasi aktif kita dalam persekutuan.\"",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        children: [
          // Dropdown Kategori
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: category,
                isExpanded: true,
                onChanged: (v) => setState(() {
                  category = v!;
                  expandedId = null;
                }),
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14)))).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Search Field
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() {
              keyword = v;
              expandedId = null;
            }),
            decoration: InputDecoration(
              hintText: "Cari kata kunci pengumuman...",
              hintStyle: const TextStyle(fontSize: 14),
              prefixIcon: const Icon(Icons.search, size: 20),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: navy)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(PengumumanItem item) {
    final bool isExpanded = expandedId == item.id;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: navy, height: 1.2),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: redAccent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.category.toUpperCase(),
                  style: const TextStyle(color: redAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
              const SizedBox(width: 12),
              Text("📅 ${item.publishedAt}", style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(6)),
            child: Text("Oleh: ${item.author}", style: const TextStyle(color: Color(0xFF4B5563), fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          Text(
            item.summary,
            maxLines: isExpanded ? null : 3,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF374151), height: 1.6, fontSize: 15),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => expandedId = isExpanded ? null : item.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                isExpanded ? "Tutup Pengumuman" : "Baca Selengkapnya",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Text(errorMsg, style: const TextStyle(color: redAccent, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Icon(Icons.announcement_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("Tidak ada pengumuman yang sesuai pencarian.", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class PengumumanItem {
  final int id;
  final String title;
  final String category;
  final String publishedAt;
  final String summary;
  final String author;

  PengumumanItem({
    required this.id,
    required this.title,
    required this.category,
    required this.publishedAt,
    required this.summary,
    this.author = "Pengurus Gereja",
  });

  factory PengumumanItem.fromJson(Map<String, dynamic> json) {
    String catLabel = "Umum";
    final scope = json['scope']?.toString().toLowerCase();
    if (scope == "publik") catLabel = "Publik";
    if (scope == "jemaat") catLabel = "Internal Jemaat";
    if (scope == "rayon") catLabel = "Rayon";

    return PengumumanItem(
      id: json['id'] ?? 0,
      title: json['judul'] ?? json['title'] ?? 'Tanpa Judul',
      category: catLabel,
      publishedAt: formatTanggalIndonesia(json['created_at']),
      summary: json['isi'] ?? json['content'] ?? '',
    );
  }
}

String formatTanggalIndonesia(dynamic value) {
  if (value == null) return "-";
  try {
    final date = DateTime.parse(value.toString());
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  } catch (_) {
    return value.toString();
  }
}
