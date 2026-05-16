import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F9FE);
  static const Color softInput = Color(0xFFF1F4FF);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF7A7C92);

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
        SnackBar(
          content: const Text('Nomor Induk Jemaat/Email dan Tanggal Lahir wajib diisi.'),
          backgroundColor: const Color(0xFFD71313),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        SnackBar(
          content: Text('Gagal membuka WhatsApp: $e'),
          backgroundColor: const Color(0xFFD71313),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ForgotPasswordScreen.softBg,
      body: Stack(
        children: [
          // Background Decorative Elements
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: ForgotPasswordScreen.navy.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildLogoHeader(),
                  const SizedBox(height: 48),
                  _buildHeaderText(),
                  const SizedBox(height: 40),
                  _buildForgotForm(),
                  const SizedBox(height: 24),
                  _buildInfoBox(),
                  const SizedBox(height: 48),
                  _buildFooter(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ForgotPasswordScreen.navy.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset(
            'web/favicon.png',
            height: 48,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.church_rounded, color: ForgotPasswordScreen.navy, size: 40),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'GPdI SIBULELE',
          style: GoogleFonts.plusJakartaSans(
            color: ForgotPasswordScreen.navy,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderText() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFD71313).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'RESET PASSWORD',
            style: TextStyle(
              color: Color(0xFFD71313),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Lupa Kata Sandi?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ForgotPasswordScreen.navy,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Jangan khawatir, masukkan data Anda untuk\nverifikasi reset password oleh Admin',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ForgotPasswordScreen.textGrey,
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildForgotForm() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: ForgotPasswordScreen.navy.withOpacity(0.05),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('NOMOR INDUK JEMAAT / EMAIL'),
          const SizedBox(height: 10),
          _buildTextField(
            controller: identityController,
            hint: 'Masukkan ID atau Email',
            prefixIcon: Icons.badge_rounded,
          ),
          const SizedBox(height: 24),
          _buildLabel('TANGGAL LAHIR'),
          const SizedBox(height: 10),
          _buildTextField(
            controller: birthDateController,
            hint: 'Contoh: 12-05-1990',
            prefixIcon: Icons.calendar_today_rounded,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: _submitResetRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: ForgotPasswordScreen.navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Kirim ke WhatsApp',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.send_rounded, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () => context.pop(),
              style: TextButton.styleFrom(
                foregroundColor: ForgotPasswordScreen.textGrey,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back_rounded, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Kembali ke Login',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
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
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: ForgotPasswordScreen.textGrey,
        letterSpacing: 1.2,
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
        color: ForgotPasswordScreen.softBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ForgotPasswordScreen.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: ForgotPasswordScreen.textGrey.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.w500),
          prefixIcon: Icon(prefixIcon, color: ForgotPasswordScreen.navy.withOpacity(0.5), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ForgotPasswordScreen.gold.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ForgotPasswordScreen.gold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_rounded, color: ForgotPasswordScreen.gold, size: 20),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Proses Verifikasi',
                  style: TextStyle(
                    color: ForgotPasswordScreen.textDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 14
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Data Anda akan diverifikasi oleh Admin GPdI Sibulele sebelum instruksi reset password dikirimkan.',
                  style: TextStyle(
                    color: ForgotPasswordScreen.textGrey,
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Butuh bantuan lain?',
          style: TextStyle(
            color: ForgotPasswordScreen.textGrey.withOpacity(0.8),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'sekretariat@gpdisibulele.org',
          style: TextStyle(
            color: ForgotPasswordScreen.navy,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
