import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import 'public_drawer.dart';
import 'app_bottom_navigation.dart';

class GaleriScreen extends StatefulWidget {
  const GaleriScreen({super.key});

  @override
  State<GaleriScreen> createState() => _GaleriScreenState();
}

class _GaleriScreenState extends State<GaleriScreen> {
  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F4FC);
  static const Color softCard = Color(0xFFF1EFFB);
  static const Color textDark = Color(0xFF1E1E2F);

  bool isLoading = true;
  String errorMsg = '';
  List<dynamic> galleryItems = [];
  String selectedCategory = 'Semua';

  final List<String> categories = ['Semua', 'Ibadah', 'Kegiatan', 'Event'];

  @override
  void initState() {
    super.initState();
    _fetchGallery();
  }

  Future<void> _fetchGallery() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMsg = '';
    });

    try {
      final response = await ApiClient().get(ApiConstants.gallery);
      final List<dynamic> data = response is List ? response : (response['data'] ?? []);

      if (mounted) {
        setState(() {
          galleryItems = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMsg = "Gagal memuat galeri kegiatan.";
          isLoading = false;
        });
      }
    }
  }

  List<dynamic> get filteredItems {
    if (selectedCategory == 'Semua') return galleryItems;
    return galleryItems.where((item) {
      final cat = (item['kategori'] ?? item['category'] ?? '').toString().toLowerCase();
      return cat.contains(selectedCategory.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PublicDrawer(activeMenu: DrawerMenu.galeri),
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
          'Galeri',
          style: TextStyle(color: navy, fontSize: 20, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return RefreshIndicator(
                onRefresh: _fetchGallery,
                color: navy,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 130),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EKSPLORASI KEGIATAN',
                            style: TextStyle(color: gold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
                          ),
                          const SizedBox(height: 16),
                          _buildCategoryList(),
                          const SizedBox(height: 32),

                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.only(top: 100),
                              child: Center(child: CircularProgressIndicator(color: navy)),
                            )
                          else if (errorMsg.isNotEmpty)
                            _buildErrorState()
                          else if (filteredItems.isEmpty)
                            _buildEmptyState()
                          else
                            _buildGalleryGrid(),
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

  Widget _buildCategoryList() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isActive = selectedCategory == cat;
          return InkWell(
            onTap: () => setState(() => selectedCategory = cat),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isActive ? navy : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isActive ? navy : Colors.grey.shade200),
              ),
              alignment: Alignment.center,
              child: Text(
                cat,
                style: TextStyle(
                  color: isActive ? Colors.white : textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGalleryGrid() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: _buildColumnItems(0),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 30),
              ..._buildColumnItems(1),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildColumnItems(int remainder) {
    List<Widget> widgets = [];
    final items = filteredItems;
    for (int i = 0; i < items.length; i++) {
      if (i % 2 == remainder) {
        widgets.add(_GalleryCard(
          title: items[i]['judul'] ?? items[i]['title'] ?? 'Kegiatan',
          category: items[i]['kategori'] ?? items[i]['category'] ?? 'Umum',
          imageUrl: items[i]['image_url'] ?? items[i]['url'],
          height: (i % 3 == 0) ? 240 : 200,
        ));
        widgets.add(const SizedBox(height: 16));
      }
    }
    return widgets;
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.cloud_off, color: Colors.grey, size: 50),
          const SizedBox(height: 12),
          Text(errorMsg, style: const TextStyle(color: Colors.grey)),
          TextButton(onPressed: _fetchGallery, child: const Text("Coba Lagi")),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 100),
        child: Text("Belum ada foto dalam kategori ini.", style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final String title;
  final String category;
  final String? imageUrl;
  final double height;

  const _GalleryCard({
    required this.title,
    required this.category,
    this.imageUrl,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFFF1EFFB),
              child: imageUrl != null && imageUrl!.startsWith('http')
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: Colors.black12, size: 30),
                  )
                : const Icon(Icons.image_outlined, color: Colors.black12, size: 40),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF05066F)),
                ),
                const SizedBox(height: 2),
                Text(
                  category.toUpperCase(),
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
