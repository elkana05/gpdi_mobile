import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/api_constants.dart';
import '../providers/content_provider.dart';
import 'public_drawer.dart';
import 'app_bottom_navigation.dart';

class ProfilGerejaScreen extends StatefulWidget {
  const ProfilGerejaScreen({super.key});

  @override
  State<ProfilGerejaScreen> createState() => _ProfilGerejaScreenState();
}

class _ProfilGerejaScreenState extends State<ProfilGerejaScreen> {
  // Warna konsisten dengan tema Flutter (HomeScreen)
  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF7F4FB);
  static const Color textDark = Color(0xFF1E1E2F);
  static const Color textGrey = Color(0xFF85879A);

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ContentProvider>(context, listen: false).fetchChurchProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const PublicDrawer(activeMenu: DrawerMenu.profilGereja),
      backgroundColor: softBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: navy),
        title: const Text(
          'Profil Gereja',
          style: TextStyle(color: navy, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => Provider.of<ContentProvider>(context, listen: false).fetchChurchProfile(),
        child: Consumer<ContentProvider>(
          builder: (context, provider, child) {
            final profile = provider.profile;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER SECTION (Konten sesuai React)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PROFIL GEREJA',
                          style: TextStyle(color: gold, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2.2),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Mengenal Lebih Dekat\nGPdI Jemaat Sibulele',
                          style: TextStyle(color: navy, fontSize: 28, fontWeight: FontWeight.w800, height: 1.1),
                        ),
                      ],
                    ),
                  ),

                  // BANNER SECTION (Konten sesuai React)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: navy.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: profile?.image != null
                            ? Image.network(
                                ApiConstants.getImageUrl(profile!.image),
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Center(child: Icon(Icons.church, size: 50, color: navy)),
                              )
                            : const Center(child: Icon(Icons.church, size: 50, color: navy)),
                      ),
                    ),
                  ),

                  // SEJARAH GEREJA SECTION (Konten sesuai React)
                  _buildContentCard(
                    title: 'Sejarah Gereja',
                    content: profile?.history ?? 'Sejarah gereja belum tersedia.',
                    icon: Icons.auto_stories_rounded,
                  ),

                  // SEJARAH SINGKAT PENDETA SECTION (Teks statis sesuai React)
                  _buildContentCard(
                    title: 'Sejarah Singkat Pendeta',
                    content: 'Pelayanan pendeta di GPdI Jemaat Sibulele telah dimulai sejak awal berdirinya gereja, dengan tujuan utama menggembalakan jemaat dan membangun kehidupan rohani yang kuat berdasarkan firman Tuhan.\n\nDari waktu ke waktu, terjadi pergantian dan regenerasi pendeta yang membawa semangat baru dalam pelayanan, namun tetap mempertahankan nilai-nilai iman yang telah diajarkan sejak awal. Setiap pendeta memberikan kontribusi dalam pertumbuhan iman jemaat melalui khotbah, pelayanan pastoral, dan kegiatan sosial.\n\nHingga saat ini, para pendeta terus melayani dengan penuh dedikasi, menjadi teladan dalam kasih, serta membimbing jemaat untuk hidup sesuai dengan ajaran Kristus.',
                    icon: Icons.history_edu_rounded,
                  ),

                  // VISI MISI SECTION (Konten sesuai React)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Visi & Misi',
                          style: TextStyle(color: navy, fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 16),

                        // VISI (Gradasi Navy sesuai Flutter)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            gradient: const LinearGradient(colors: [navy, Color(0xFF15015F)]),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('VISI', style: TextStyle(color: Color(0xFFFFD34E), fontSize: 11, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 12),
                              Text(
                                profile?.vision != null ? '"${profile!.vision}"' : '"Visi gereja belum tersedia."',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, height: 1.5),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // MISI (Putih bersih sesuai Flutter)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('MISI', style: TextStyle(color: Color(0xFFD71313), fontSize: 11, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 16),
                              if (profile?.missions != null && profile!.missions.isNotEmpty)
                                ...profile.missions.map((m) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Padding(padding: EdgeInsets.only(top: 6), child: Icon(Icons.circle, size: 6, color: Color(0xFFD71313))),
                                          const SizedBox(width: 12),
                                          Expanded(child: Text(m, style: const TextStyle(color: textDark, fontSize: 14, fontWeight: FontWeight.w500, height: 1.4))),
                                        ],
                                      ),
                                    ))
                              else
                                const Text('Misi belum tersedia.', style: TextStyle(color: textGrey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: -1),
    );
  }

  Widget _buildContentCard({required String title, required String content, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: gold, size: 24),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(color: navy, fontSize: 16, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: const TextStyle(color: textDark, fontSize: 14, height: 1.6, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
