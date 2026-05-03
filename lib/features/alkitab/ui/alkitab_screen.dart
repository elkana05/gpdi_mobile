import 'package:flutter/material.dart';
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
  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F4FC);

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
          renunganData = rawData.map((item) => RenunganItem.fromJson(item)).toList().reversed.toList();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Gagal memuat renungan: $e");
      if (mounted) {
        setState(() {
          errorMsg = "Gagal memuat renungan harian.";
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isMember = authProvider.status == AuthStatus.authenticated;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: softBg,
      drawer: isMember
          ? const MemberDrawer(activeMenu: MemberDrawerMenu.none)
          : const PublicDrawer(activeMenu: DrawerMenu.none),
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
          'Alkitab & Renungan',
          style: TextStyle(color: navy, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return RefreshIndicator(
                onRefresh: _fetchRenungan,
                color: navy,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 24),

                          if (isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 100),
                                child: CircularProgressIndicator(color: navy),
                              ),
                            )
                          else if (errorMsg.isNotEmpty)
                            _buildErrorState()
                          else if (renunganData.isEmpty)
                            _buildEmptyState()
                          else
                            ...renunganData.map((item) => _buildRenunganCard(item)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: isMember
                ? const MemberBottomNavigation(currentIndex: 1)
                : const AppBottomNavigation(currentIndex: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Renungan Harian",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: navy),
        ),
        SizedBox(height: 4),
        Text(
          "Firman Tuhan untuk Pertumbuhan Rohani",
          style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(errorMsg, style: const TextStyle(color: Colors.red)),
          TextButton(onPressed: _fetchRenungan, child: const Text("Coba Lagi")),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 100),
        child: Column(
          children: [
            Icon(Icons.auto_stories_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text("Belum ada renungan hari ini.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildRenunganCard(RenunganItem item) {
    final bool isExpanded = expandedId == item.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bookmark_added, color: gold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(item.publishedAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.tema,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: navy),
                ),
                const SizedBox(height: 12),
                Text(
                  item.isi,
                  maxLines: isExpanded ? null : 3,
                  overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, color: Color(0xFF4A4A68), height: 1.5),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => setState(() => expandedId = isExpanded ? null : item.id),
                  child: Row(
                    children: [
                      Text(
                        isExpanded ? "Tutup Tulisan" : "Baca Selengkapnya",
                        style: const TextStyle(color: navy, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: navy,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return "-";
    try {
      final date = DateTime.parse(dateString);
      final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
      return "${date.day} ${months[date.month - 1]} ${date.year}";
    } catch (_) {
      return dateString;
    }
  }
}

class RenunganItem {
  final int id;
  final String tema;
  final String isi;
  final String publishedAt;

  RenunganItem({required this.id, required this.tema, required this.isi, required this.publishedAt});

  factory RenunganItem.fromJson(Map<String, dynamic> json) {
    return RenunganItem(
      id: json['id'] ?? 0,
      tema: json['tema'] ?? json['title'] ?? 'Tanpa Judul',
      isi: json['isi'] ?? json['content'] ?? '',
      publishedAt: json['published_at'] ?? json['created_at'] ?? '',
    );
  }
}
