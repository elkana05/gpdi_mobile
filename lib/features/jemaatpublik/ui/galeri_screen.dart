import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';
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
  static const Color softBg = Color(0xFFF8F9FE);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF7A7C92);

  String selectedCategory = 'Semua Kegiatan';
  final List<String> categories = [
    'Semua Kegiatan',
    'Ibadah Raya',
    'Pemuda & Remaja',
    'Sekolah Minggu',
    'Wanita / Kaum Ibu',
    'Umum / Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ContentProvider>(context, listen: false).fetchGallery());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PublicDrawer(activeMenu: DrawerMenu.galeri),
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
        title: const Text(
          'Galeri Foto',
          style: TextStyle(
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
          // Filtering logic
          final items = selectedCategory == 'Semua Kegiatan'
              ? provider.gallery
              : provider.gallery.where((e) {
                  final desc = (e.description ?? '').toLowerCase();
                  final title = (e.title ?? '').toLowerCase();
                  final cat = selectedCategory.toLowerCase();
                  // Simple check if category name exists in title or description
                  return desc.contains(cat) || title.contains(cat);
                }).toList();

          return RefreshIndicator(
            onRefresh: () => provider.fetchGallery(),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildSectionHeader('Kategori Foto', 'Pilih kategori kegiatan gereja'),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildCategoryList(),
                ),
                if (provider.isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: navy)),
                  )
                else if (provider.errorMessage.isNotEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState("Gagal memuat galeri. Silakan coba lagi."),
                  )
                else if (items.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState("Belum ada foto untuk kategori ini."),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildGalleryCard(items[index]),
                        childCount: items.length,
                      ),
                    ),
                  ),
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
            color: gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'DOKUMENTASI',
            style: TextStyle(
              color: gold,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Momen Berharga\nKeluarga Allah',
          style: TextStyle(
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
          style: const TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.w800
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: textGrey,
            fontSize: 13,
            fontWeight: FontWeight.w500
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: categories.map((cat) {
          final isActive = selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => selectedCategory = cat),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? navy : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive ? navy : Colors.grey.withOpacity(0.1),
                  ),
                  boxShadow: isActive ? [
                    BoxShadow(
                      color: navy.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ] : null,
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isActive ? Colors.white : textDark,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 13,
                  )
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGalleryCard(dynamic item) {
    final imageUrl = ApiConstants.getImageUrl(item.image);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showImageDialog(imageUrl, item.title, item.description),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: navy.withOpacity(0.05),
                              child: const Center(child: Icon(Icons.broken_image, color: textGrey)),
                            ),
                          )
                        : Container(
                            color: navy.withOpacity(0.05),
                            child: const Center(child: Icon(Icons.image, color: textGrey)),
                          ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.zoom_in_rounded, size: 16, color: navy),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title ?? 'Kegiatan',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: textDark,
                          fontSize: 13
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.description ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textGrey,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImageDialog(String url, String? title, String? desc) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Image.network(
                        url,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withOpacity(0.3),
                            radius: 15,
                            child: const Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title ?? 'Kegiatan',
                          style: const TextStyle(
                            color: navy,
                            fontSize: 18,
                            fontWeight: FontWeight.w800
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          desc ?? '',
                          style: const TextStyle(
                            color: textGrey,
                            fontSize: 14,
                            height: 1.5
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            Icon(Icons.photo_library_outlined, size: 64, color: textGrey.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: textGrey, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
