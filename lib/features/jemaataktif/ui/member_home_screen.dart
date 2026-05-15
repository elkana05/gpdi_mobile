import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../jemaatpublik/providers/content_provider.dart';
import 'member_drawer.dart';
import 'member_bottom_navigation.dart';

class MemberHomeScreen extends StatefulWidget {
  const MemberHomeScreen({super.key});

  @override
  State<MemberHomeScreen> createState() => _MemberHomeScreenState();
}

class _MemberHomeScreenState extends State<MemberHomeScreen> {
  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFFFC326);
  static const Color softBg = Color(0xFFF8F4FC);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<UserProvider>(context, listen: false).fetchPersonalData();
      Provider.of<ContentProvider>(context, listen: false).fetchAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authUser = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      drawer: const MemberDrawer(activeMenu: MemberDrawerMenu.beranda),
      backgroundColor: softBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text('Dashboard Jemaat', style: TextStyle(color: navy, fontWeight: FontWeight.w800, fontSize: 17)),
        actions: [
          IconButton(
            onPressed: () => context.go('/member-profile'),
            icon: CircleAvatar(
              backgroundColor: gold.withOpacity(0.2),
              child: const Icon(Icons.person, color: navy),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Consumer2<UserProvider, ContentProvider>(
        builder: (context, userProv, contentProv, child) {
          final fullName = userProv.detailedProfile?.fullName ?? authUser?.fullName ?? 'Jemaat';

          return RefreshIndicator(
            onRefresh: () async {
              await userProv.fetchPersonalData();
              await contentProv.fetchAnnouncements();
            },
            color: navy,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Syalom,', style: TextStyle(color: navy.withOpacity(0.7), fontSize: 16)),
                  Text(fullName, style: const TextStyle(color: navy, fontSize: 28, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 24),

                  _buildWelcomeCard(userProv.detailedProfile?.rayonId),

                  const SizedBox(height: 28),
                  const _SectionTitle(title: 'Akses Cepat'),
                  const SizedBox(height: 14),
                  _QuickAccessCard(
                    icon: Icons.calendar_month,
                    title: 'Ibadah Rayon',
                    subtitle: 'Cek jadwal rayon Anda',
                    onTap: () => context.push('/jadwal-rayon'),
                  ),
                  const SizedBox(height: 12),
                  _QuickAccessCard(
                    icon: Icons.description,
                    title: 'Request Surat',
                    subtitle: 'Ajukan surat keterangan',
                    onTap: () => context.push('/request-surat'),
                  ),

                  const SizedBox(height: 32),
                  const _SectionTitle(title: 'Warta Terbaru'),
                  const SizedBox(height: 14),

                  if (contentProv.isLoading)
                    const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: navy)))
                  else if (contentProv.announcements.isEmpty)
                    const Text('Tidak ada pengumuman terbaru.', style: TextStyle(color: Colors.grey))
                  else
                    ...contentProv.announcements.take(3).map((a) => _AnnouncementSnippet(a)),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const MemberBottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildWelcomeCard(int? rayonId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [navy, Color(0xFF1E208F)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: navy.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: gold, size: 20),
              SizedBox(width: 8),
              Text('Status Keanggotaan', style: TextStyle(color: gold, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            rayonId != null ? 'Anda terdaftar aktif di Rayon $rayonId' : 'Status: Jemaat Aktif (Belum ada Rayon)',
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pastikan data profil dan keluarga Anda selalu diperbarui.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(color: Color(0xFF1E1E2F), fontSize: 18, fontWeight: FontWeight.w800));
  }
}

class _AnnouncementSnippet extends StatelessWidget {
  final dynamic data;
  const _AnnouncementSnippet(this.data);
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        onTap: () => context.push('/member-pengumuman'),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.campaign, color: Colors.orange),
        ),
        title: Text(data.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(data.date ?? 'Terbaru', style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const _QuickAccessCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFF05066F).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: const Color(0xFF05066F)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }
}
