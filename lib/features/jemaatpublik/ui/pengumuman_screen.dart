import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
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
  static const Color softBg = Color(0xFFF8F4FC);

  bool isLoading = true;
  String errorMsg = '';
  List<dynamic> announcements = [];

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMsg = '';
    });

    try {
      debugPrint("🚀 [PUBLIC API] Fetching from: ${ApiConstants.baseUrl}${ApiConstants.announcements}");
      final response = await ApiClient().get(ApiConstants.announcements);

      // Log response untuk debugging di console
      debugPrint("📦 [PUBLIC API RESPONSE]: $response");

      // Handle response jika berupa Map { data: [...] } atau List [...]
      final List<dynamic> rawData = response is List ? response : (response['data'] ?? []);

      if (mounted) {
        setState(() {
          // Filter untuk publik: Tampilkan yang scope-nya 'publik'
          // atau jika field scope tidak ada (default publik)
          announcements = rawData.where((item) {
            final String scope = (item['scope'] ?? item['category'] ?? 'publik').toString().toLowerCase();
            return scope == 'publik' || scope == 'umum' || scope == 'info';
          }).toList().reversed.toList();

          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ [PUBLIC API ERROR]: $e");
      if (mounted) {
        setState(() {
          errorMsg = e.toString().contains('404')
              ? "Layanan pengumuman tidak ditemukan di server (404)."
              : "Gagal memuat pengumuman. Pastikan server aktif.";
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PublicDrawer(activeMenu: DrawerMenu.pengumuman),
      backgroundColor: softBg,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: navy, size: 27),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Pengumuman Gereja',
          style: TextStyle(color: navy, fontSize: 18, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return RefreshIndicator(
                onRefresh: _fetchAnnouncements,
                color: navy,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 130),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('WARTA TERBARU', 'Publik'),
                          const SizedBox(height: 20),

                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.only(top: 100),
                              child: Center(child: CircularProgressIndicator(color: navy)),
                            )
                          else if (errorMsg.isNotEmpty)
                            _buildErrorState()
                          else if (announcements.isEmpty)
                            _buildEmptyState()
                          else
                            ...announcements.map((item) => Column(
                              children: [
                                _AnnouncementCard(
                                  tag: (item['scope'] ?? item['category'] ?? 'INFO').toString().toUpperCase(),
                                  title: item['judul'] ?? item['title'] ?? 'Tanpa Judul',
                                  desc: item['isi'] ?? item['content'] ?? 'Tidak ada detail.',
                                  date: _formatDate(item['created_at']),
                                  isImportant: item['is_important'] == true || item['is_important'] == 1,
                                ),
                                const SizedBox(height: 16),
                              ],
                            )),
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
            child: AppBottomNavigation(currentIndex: -1),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String sub) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: gold.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
          child: Text(sub, style: const TextStyle(color: gold, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_rounded, color: Colors.grey, size: 48),
            const SizedBox(height: 16),
            Text(errorMsg, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchAnnouncements,
              style: ElevatedButton.styleFrom(backgroundColor: navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text("Coba Lagi", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          children: [
            Icon(Icons.campaign_outlined, color: Colors.grey.withOpacity(0.5), size: 64),
            const SizedBox(height: 16),
            const Text("Belum ada pengumuman publik.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return "-";
    try {
      final date = DateTime.parse(dateStr.toString());
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) return "${diff.inMinutes}m lalu";
      if (diff.inHours < 24) return "${diff.inHours}j lalu";

      const bulan = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des"];
      return "${date.day} ${bulan[date.month - 1]} ${date.year}";
    } catch (_) {
      return dateStr.toString();
    }
  }
}

class _AnnouncementCard extends StatelessWidget {
  final String tag, title, desc, date;
  final bool isImportant;
  const _AnnouncementCard({required this.tag, required this.title, required this.desc, required this.date, this.isImportant = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isImportant ? const Color(0xFF05066F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isImportant ? const Color(0xFFC5A327) : const Color(0xFFF1F0FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: isImportant ? Colors.black : const Color(0xFF05066F),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  color: isImportant ? Colors.white70 : Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              color: isImportant ? Colors.white : const Color(0xFF1E1E2F),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(
              color: isImportant ? Colors.white70 : const Color(0xFF7D7F91),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
