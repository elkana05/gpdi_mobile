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
  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F9FE);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF7A7C92);

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
          'Profil Gereja',
          style: TextStyle(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => Provider.of<ContentProvider>(context, listen: false).fetchChurchProfile(),
        child: Consumer<ContentProvider>(
          builder: (context, provider, child) {
            final profile = provider.profile;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildBanner(profile?.image),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Tentang Kami', 'Sejarah dan perjalanan iman kami'),
                  const SizedBox(height: 16),
                  _buildContentCard(
                    title: 'Sejarah Gereja',
                    content: profile?.history ?? 'Sejarah gereja belum tersedia.',
                    icon: Icons.auto_stories_rounded,
                    accentColor: gold,
                  ),
                  const SizedBox(height: 16),
                  _buildContentCard(
                    title: 'Pelayanan Pastoral',
                    content: 'Pelayanan pendeta di GPdI Jemaat Sibulele telah dimulai sejak awal berdirinya gereja, dengan tujuan utama menggembalakan jemaat dan membangun kehidupan rohani yang kuat berdasarkan firman Tuhan.\n\nSetiap pendeta memberikan kontribusi dalam pertumbuhan iman jemaat melalui khotbah, pelayanan pastoral, dan kegiatan sosial.',
                    icon: Icons.history_edu_rounded,
                    accentColor: navy,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Visi & Misi', 'Tujuan dan arah pelayanan kami'),
                  const SizedBox(height: 16),
                  _buildVisionCard(profile?.vision),
                  const SizedBox(height: 16),
                  _buildMissionCard(profile?.missions),
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
            'PROFIL GEREJA',
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
          'Mengenal Lebih Dekat\nGPdI Sibulele',
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

  Widget _buildBanner(String? imageUrl) {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 15)
          )
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: imageUrl != null
                ? Image.network(
                    ApiConstants.getImageUrl(imageUrl),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (c, e, s) => Container(
                      color: navy.withOpacity(0.05),
                      child: const Center(child: Icon(Icons.church_rounded, size: 60, color: navy)),
                    ),
                  )
                : Container(
                    color: navy.withOpacity(0.05),
                    child: const Center(child: Icon(Icons.church_rounded, size: 60, color: navy)),
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  navy.withOpacity(0.8),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: gold,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'GPdI SIBULELE',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Gereja Pantekosta di Indonesia',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard({
    required String title,
    required String content,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(color: navy, fontSize: 16, fontWeight: FontWeight.w800)
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            content,
            style: const TextStyle(
              color: textDark,
              fontSize: 14,
              height: 1.7,
              fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisionCard(String? vision) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [navy, Color(0xFF1A1B8C)],
        ),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.stars_rounded,
              size: 140,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFFFFD34E), size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'VISI KAMI',
                      style: TextStyle(
                        color: Color(0xFFFFD34E),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  vision != null ? '"$vision"' : '"Visi gereja belum tersedia."',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                    height: 1.5
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(List<String>? missions) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rocket_launch_rounded, color: Color(0xFFD71313), size: 18),
              const SizedBox(width: 8),
              const Text(
                'MISI KAMI',
                style: TextStyle(
                  color: Color(0xFFD71313),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                )
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (missions != null && missions.isNotEmpty)
            ...missions.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD71313).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, size: 12, color: Color(0xFFD71313)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          m,
                          style: const TextStyle(
                            color: textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.6
                          )
                        ),
                      ),
                    ],
                  ),
                ))
          else
            const Text(
              'Misi belum tersedia.',
              style: TextStyle(color: textGrey)
            ),
        ],
      ),
    );
  }
}
