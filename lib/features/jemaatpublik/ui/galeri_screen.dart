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
  static const Color softBg = Color(0xFFF8F4FC);
  static const Color textDark = Color(0xFF1E1E2F);

  String selectedCategory = 'Semua';
  final List<String> categories = ['Semua', 'Ibadah', 'Kegiatan', 'Event'];

  @override
  void initState() {
    super.initState();
    // Tembak API Galeri dari Docker BE
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
        title: const Text(
          'Galeri',
          style: TextStyle(color: navy, fontSize: 20, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: Consumer<ContentProvider>(
        builder: (context, provider, child) {
          final items = selectedCategory == 'Semua'
              ? provider.gallery
              : provider.gallery.where((e) => (e.description ?? '').contains(selectedCategory)).toList();

          return RefreshIndicator(
            onRefresh: () => provider.fetchGallery(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
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

                  if (provider.isLoading)
                    const Center(child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: CircularProgressIndicator(),
                    ))
                  else if (provider.errorMessage.isNotEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Text('Gagal memuat galeri'),
                    ))
                  else if (items.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Text("Belum ada foto."),
                    ))
                  else
                    _buildGalleryGrid(items),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: -1),
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isActive ? navy : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(cat, style: TextStyle(color: isActive ? Colors.white : textDark, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGalleryGrid(List items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final imageUrl = ApiConstants.getImageUrl(item.image);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    )
                  : const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  item.title ?? 'Kegiatan',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: navy, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
