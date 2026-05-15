import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const Color navy = Color(0xFF000066);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F9FE);
  static const Color softInput = Color(0xFFF1F4FF);
  static const Color textDark = Color(0xFF1E1E2F);
  static const Color textGrey = Color(0xFF6F7182);

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

      // Arahkan berdasarkan role
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
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().status == AuthStatus.authenticating;

    return Scaffold(
      backgroundColor: LoginScreen.softBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              LoginScreen.softBg,
              LoginScreen.softBg.withOpacity(0.8),
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
                  'Sistem Informasi\nJemaat',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    color: LoginScreen.navy,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Silahkan Login untuk mengakses layanan\ninternal gereja',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: LoginScreen.textGrey,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                _buildLoginForm(isLoading),
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
        Image.asset(
          'web/favicon.png',
          height: 32,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.church_outlined, color: LoginScreen.navy, size: 28),
        ),
        const SizedBox(width: 8),
        Text(
          'GPDI Sibulele',
          style: GoogleFonts.merriweather(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: LoginScreen.navy,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(bool isLoading) {
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
          _buildLabel('MEMBER ID / PHONE'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: emailController,
            hint: 'Masukkan ID atau Nomor HP',
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 20),
          _buildLabel('PASSWORD'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: passwordController,
            hint: 'Masukkan Password Anda',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            obscureText: obscurePassword,
            onToggleVisibility: () => setState(() => obscurePassword = !obscurePassword),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: rememberMe,
                      onChanged: (val) => setState(() => rememberMe = val ?? false),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Remember Me',
                    style: TextStyle(color: LoginScreen.textGrey, fontSize: 13),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.push('/forgot-password'),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: LoginScreen.gold, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: LoginScreen.navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                shadowColor: LoginScreen.navy.withOpacity(0.5),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Masuk',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.logout_rounded, size: 18),
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
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: LoginScreen.textGrey,
        letterSpacing: 0.5,
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
        color: LoginScreen.softInput,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(prefixIcon, color: Colors.grey, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
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
        color: LoginScreen.softInput.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: LoginScreen.gold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: LoginScreen.textDark, fontSize: 13, height: 1.6),
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(Icons.info_outline, color: LoginScreen.gold, size: 16),
                      ),
                    ),
                    const TextSpan(
                      text: 'Pemberitahuan Internal: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text: 'Akun hanya tersedia bagi jemaat yang telah terdaftar oleh Admin atau Pendeta. Silahkan hubungi sekretariat jika Anda belum memiliki akses.',
                    ),
                  ],
                ),
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
            color: LoginScreen.navy,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFooterLink('PRIVACY POLICY'),
            _buildFooterDivider(),
            _buildFooterLink('COMMUNITY GUIDE'),
            _buildFooterDivider(),
            _buildFooterLink('SUPPORT'),
          ],
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

  Widget _buildFooterLink(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: LoginScreen.textGrey,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildFooterDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text('|', style: TextStyle(color: Colors.grey.withOpacity(0.3), fontSize: 10)),
    );
  }
}
