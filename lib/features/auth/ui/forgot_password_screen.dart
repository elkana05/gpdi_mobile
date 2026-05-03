import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const Color navy = Color(0xFF000066);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F9FE);
  static const Color softInput = Color(0xFFF1F4FF);
  static const Color textDark = Color(0xFF1E1E2F);
  static const Color textGrey = Color(0xFF6F7182);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController identityController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  @override
  void dispose() {
    identityController.dispose();
    birthDateController.dispose();
    super.dispose();
  }

  Future<void> _submitResetRequest() async {
    final identity = identityController.text.trim();
    final birthDate = birthDateController.text.trim();

    if (identity.isEmpty || birthDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor Induk Jemaat/Email dan Tanggal Lahir wajib diisi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    const String adminPhone = '6281263299741';

    final String message = '''
Shalom Admin GPDI Sibulele,

Saya ingin mengajukan permintaan reset password akun jemaat.

Nomor Induk Jemaat / Email:
$identity

Tanggal Lahir:
$birthDate

Mohon bantuan untuk proses reset password akun saya.
Terima kasih.
''';

    final Uri whatsappUrl = Uri.parse(
      'https://wa.me/$adminPhone?text=${Uri.encodeComponent(message)}',
    );

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Tidak dapat membuka WhatsApp';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka WhatsApp: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ForgotPasswordScreen.softBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              ForgotPasswordScreen.softBg,
              ForgotPasswordScreen.softBg.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 40),
                Text(
                  'Lupa Password',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    color: ForgotPasswordScreen.navy,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Masukkan data Anda untuk melakukan\nproses verifikasi reset password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ForgotPasswordScreen.textGrey,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                _buildForgotForm(),
                const SizedBox(height: 24),
                _buildInfoBox(),
                const SizedBox(height: 40),
                _buildFooter(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.church_outlined, color: ForgotPasswordScreen.navy, size: 28),
        const SizedBox(width: 8),
        Text(
          'GPDI Sibulele',
          style: GoogleFonts.merriweather(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: ForgotPasswordScreen.navy,
          ),
        ),
      ],
    );
  }

  Widget _buildForgotForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('NOMOR INDUK JEMAAT / EMAIL'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: identityController,
            hint: 'Masukkan ID atau Email',
            prefixIcon: Icons.badge_outlined,
          ),
          const SizedBox(height: 20),
          _buildLabel('TANGGAL LAHIR'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: birthDateController,
            hint: 'Contoh: 12-05-1990',
            prefixIcon: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _submitResetRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: ForgotPasswordScreen.navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                shadowColor: ForgotPasswordScreen.navy.withOpacity(0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Kirim ke WhatsApp',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.send_rounded, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () => context.pop(),
              child: const Text(
                'Kembali ke Login',
                style: TextStyle(
                  color: ForgotPasswordScreen.textGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: ForgotPasswordScreen.textGrey,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ForgotPasswordScreen.softInput,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(prefixIcon, color: Colors.grey, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ForgotPasswordScreen.softInput.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: ForgotPasswordScreen.gold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Data yang Anda masukkan akan diverifikasi oleh Admin. Pastikan data sesuai dengan yang terdaftar di database gereja.',
                style: TextStyle(color: ForgotPasswordScreen.textDark, fontSize: 13, height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'GPDI Sibulele',
          style: GoogleFonts.merriweather(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: ForgotPasswordScreen.navy,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '© 2024 GPDI SIBULELE. ALL RIGHTS RESERVED.',
          style: TextStyle(
            color: Colors.grey.withOpacity(0.8),
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
