import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/auth/providers/user_provider.dart';

class PastorProfileScreen extends StatefulWidget {
  const PastorProfileScreen({super.key});

  @override
  State<PastorProfileScreen> createState() => _PastorProfileScreenState();
}

class _PastorProfileScreenState extends State<PastorProfileScreen> {
  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F9FE);
  static const Color textGrey = Color(0xFF7A7C92);

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<UserProvider>(context, listen: false).fetchPersonalData()
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Profil Pastor', style: GoogleFonts.montserrat(color: navy, fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          children: [
            _buildAvatarHeader(user?.fullName ?? 'Hamba Tuhan'),
            const SizedBox(height: 32),
            _buildInfoCard(user),
            const SizedBox(height: 24),
            _buildActionSection(context, auth),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarHeader(String name) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: gold, width: 2)),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: navy.withOpacity(0.1),
            child: const Icon(Icons.person_rounded, size: 50, color: navy),
          ),
        ),
        const SizedBox(height: 16),
        Text(name, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w800, color: navy)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: gold.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text('PELAYAN TUHAN / ADMIN', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w900, color: gold, letterSpacing: 1)),
        ),
      ],
    );
  }

  Widget _buildInfoCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)]),
      child: Column(
        children: [
          _buildInfoRow(Icons.email_outlined, 'Email', user?.email ?? '-'),
          const Divider(height: 30),
          _buildInfoRow(Icons.verified_user_outlined, 'ID Akun', user?.id.toString() ?? '-'),
          const Divider(height: 30),
          _buildInfoRow(Icons.security_rounded, 'Status', 'Administrator Sistem'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: textGrey, size: 20),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.montserrat(fontSize: 11, color: textGrey, fontWeight: FontWeight.w600)),
          Text(value, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
        ]),
      ],
    );
  }

  Widget _buildActionSection(BuildContext context, AuthProvider auth) {
    return Column(
      children: [
        _buildProfileButton(
          icon: Icons.lock_reset_rounded,
          label: 'Ganti Password',
          color: navy,
          onTap: () {
            // Logika ganti password bisa diarahkan ke modal atau screen khusus
          },
        ),
        const SizedBox(height: 12),
        _buildProfileButton(
          icon: Icons.logout_rounded,
          label: 'Keluar dari Akun',
          color: Colors.redAccent,
          onTap: () => _handleLogout(context, auth),
        ),
      ],
    );
  }

  Widget _buildProfileButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(border: Border.all(color: color.withOpacity(0.2)), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Text(label, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Konfirmasi', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: TextStyle(color: textGrey))),
          TextButton(onPressed: () async {
            await auth.logout();
            if (context.mounted) context.go('/home');
          }, child: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
