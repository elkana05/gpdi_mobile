import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F9FE);
  static const Color softInput = Color(0xFFF1F4FF);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF7A7C92);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;
  bool rememberMe = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Email/ID dan kata sandi wajib diisi.');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(email, password);

    if (!mounted) return;

    if (success) {
      final user = authProvider.user;
      final role = (user?.roles != null && user!.roles.isNotEmpty)
          ? user.roles.first.toLowerCase()
          : '';

      if (role.contains('pendeta') || role.contains('admin')) {
        context.go('/pastor-home');
      } else {
        context.go('/member-home');
      }
    } else {
      _showError(authProvider.errorMessage.isNotEmpty
          ? authProvider.errorMessage
          : 'Login Gagal. Periksa kembali email dan password.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFD71313),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().status == AuthStatus.authenticating;

    return Scaffold(
      backgroundColor: LoginScreen.softBg,
      body: Stack(
        children: [
          // Background Decorative Elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: LoginScreen.navy.withOpacity(0.03),
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
                  _buildWelcomeText(),
                  const SizedBox(height: 40),
                  _buildLoginForm(isLoading),
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
                color: LoginScreen.navy.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset(
            'web/favicon.png',
            height: 48,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.church_rounded, color: LoginScreen.navy, size: 40),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'GPdI SIBULELE',
          style: GoogleFonts.plusJakartaSans(
            color: LoginScreen.navy,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: LoginScreen.gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'LOGIN INTERNAL',
            style: TextStyle(
              color: LoginScreen.gold,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Selamat Datang\nKembali',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: LoginScreen.navy,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Silahkan masuk untuk mengakses layanan\nkhusus jemaat dan pengurus',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: LoginScreen.textGrey,
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: LoginScreen.navy.withOpacity(0.05),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('MEMBER ID / PHONE'),
          const SizedBox(height: 10),
          _buildTextField(
            controller: emailController,
            hint: 'Masukkan ID atau Nomor HP',
            prefixIcon: Icons.person_rounded,
          ),
          const SizedBox(height: 24),
          _buildLabel('PASSWORD'),
          const SizedBox(height: 10),
          _buildTextField(
            controller: passwordController,
            hint: 'Masukkan Password',
            prefixIcon: Icons.lock_rounded,
            isPassword: true,
            obscureText: obscurePassword,
            onToggleVisibility: () => setState(() => obscurePassword = !obscurePassword),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => setState(() => rememberMe = !rememberMe),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: rememberMe,
                        onChanged: (val) => setState(() => rememberMe = val ?? false),
                        activeColor: LoginScreen.navy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Ingat Saya',
                      style: TextStyle(
                        color: LoginScreen.textGrey,
                        fontSize: 13,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.push('/forgot-password'),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: const Text(
                  'Lupa Password?',
                  style: TextStyle(
                    color: LoginScreen.gold,
                    fontSize: 13,
                    fontWeight: FontWeight.w700
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: LoginScreen.navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Masuk Sekarang',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
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
        color: LoginScreen.textGrey,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: LoginScreen.softBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: LoginScreen.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: LoginScreen.textGrey.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.w500),
          prefixIcon: Icon(prefixIcon, color: LoginScreen.navy.withOpacity(0.5), size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    color: LoginScreen.textGrey.withOpacity(0.5),
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
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
        border: Border.all(color: LoginScreen.gold.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: LoginScreen.gold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline_rounded, color: LoginScreen.gold, size: 20),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Akses Terbatas',
                  style: TextStyle(
                    color: LoginScreen.textDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 14
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Akun hanya tersedia bagi jemaat yang telah terdaftar. Hubungi sekretariat jika Anda belum memiliki akses.',
                  style: TextStyle(
                    color: LoginScreen.textGrey,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFooterLink('Bantuan'),
            _buildFooterDivider(),
            _buildFooterLink('Privasi'),
            _buildFooterDivider(),
            _buildFooterLink('Syarat'),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          '© 2024 GPdI Sibulele. Versi 2.0',
          style: TextStyle(
            color: LoginScreen.textGrey.withOpacity(0.6),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLink(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: LoginScreen.textGrey,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildFooterDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: LoginScreen.textGrey.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
    );
  }
}
