import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F4FC);
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
          content: Text(
            'Nomor Induk Jemaat/Email dan Tanggal Lahir wajib diisi.',
          ),
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
      final bool canOpen = await canLaunchUrl(whatsappUrl);

      if (!canOpen) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tidak dapat membuka WhatsApp. Pastikan WhatsApp terpasang.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka WhatsApp: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _backToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ForgotPasswordScreen.softBg,
      body: SafeArea(
        child: Column(
          children: [
            const _TopBrand(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                child: _ForgotPasswordCard(
                  identityController: identityController,
                  birthDateController: birthDateController,
                  onSubmit: _submitResetRequest,
                  onBackToLogin: _backToLogin,
                ),
              ),
            ),
            const _FooterSection(),
          ],
        ),
      ),
    );
  }
}

class _TopBrand extends StatelessWidget {
  const _TopBrand();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white,
      child: const Row(
        children: [
          Icon(
            Icons.church_outlined,
            color: ForgotPasswordScreen.navy,
            size: 26,
          ),
          SizedBox(width: 12),
          Text(
            'GPDI Sibulele',
            style: TextStyle(
              color: ForgotPasswordScreen.navy,
              fontSize: 19,
              fontWeight: FontWeight.w900,
              fontFamily: 'serif',
            ),
          ),
        ],
      ),
    );
  }
}

class _ForgotPasswordCard extends StatelessWidget {
  final TextEditingController identityController;
  final TextEditingController birthDateController;
  final VoidCallback onSubmit;
  final VoidCallback onBackToLogin;

  const _ForgotPasswordCard({
    required this.identityController,
    required this.birthDateController,
    required this.onSubmit,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 36, 32, 36),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lupa Password',
            style: TextStyle(
              color: ForgotPasswordScreen.navy,
              fontSize: 36,
              height: 1.1,
              fontWeight: FontWeight.w900,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Masukkan data Anda untuk\nmelakukan reset password',
            style: TextStyle(
              color: ForgotPasswordScreen.textGrey,
              fontSize: 17,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 40),
          const _InputLabel(text: 'NOMOR INDUK JEMAAT / EMAIL'),
          const SizedBox(height: 12),
          _ResetInput(
            controller: identityController,
            hintText: 'Contoh: 123456 atau\nemail@contoh.com',
            maxLines: 2,
          ),
          const SizedBox(height: 28),
          const _InputLabel(text: 'TANGGAL LAHIR'),
          const SizedBox(height: 12),
          _ResetInput(
            controller: birthDateController,
            hintText: 'mm/dd/yyyy',
            keyboardType: TextInputType.datetime,
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 17, 16, 17),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2FF),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: const Color(0xFFDADCF2),
                width: 1,
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: ForgotPasswordScreen.navy,
                  size: 21,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Data harus sesuai dengan yang\nterdaftar pada sistem',
                    style: TextStyle(
                      color: Color(0xFF626A94),
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: ForgotPasswordScreen.navy,
                elevation: 12,
                shadowColor: ForgotPasswordScreen.navy.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: const Text(
                'Kirim Permintaan Reset',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 34),
          Center(
            child: TextButton.icon(
              onPressed: onBackToLogin,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF626A94),
              ),
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 18,
              ),
              label: const Text(
                'KEMBALI KE HALAMAN LOGIN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String text;

  const _InputLabel({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: ForgotPasswordScreen.textDark,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.6,
      ),
    );
  }
}

class _ResetInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextInputType? keyboardType;

  const _ResetInput({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: maxLines > 1 ? 78.0 : 58.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: ForgotPasswordScreen.textDark,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF8D90A0),
            fontSize: 15,
            height: 1.4,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 17,
          ),
        ),
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      color: const Color(0xFFF6F7FA),
      child: const Column(
        children: [
          Text(
            'GPDI Sibulele',
            style: TextStyle(
              color: ForgotPasswordScreen.navy,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              fontFamily: 'serif',
            ),
          ),
          SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FooterLink(text: 'PRIVACY POLICY'),
              SizedBox(width: 24),
              _FooterLink(text: 'COMMUNITY GUIDE'),
              SizedBox(width: 24),
              _FooterLink(text: 'SUPPORT'),
            ],
          ),
          SizedBox(height: 30),
          Text(
            '© 2024 GPDI SIBULELE. ALL RIGHTS RESERVED.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFA5A9B9),
              fontSize: 10,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;

  const _FooterLink({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF6D7890),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}