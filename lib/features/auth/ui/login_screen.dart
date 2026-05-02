import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'forgot_password_screen.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../member/ui/member_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F4FC);
  static const Color softInput = Color(0xFFF1EFFB);
  static const Color textDark = Color(0xFF1E1E2F);
  static const Color textGrey = Color(0xFF6F7182);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  bool obscurePassword = true;
  bool isLoading = false;

  final TextEditingController memberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void dispose() {
    memberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final identity = memberController.text.trim();
    final password = passwordController.text.trim();

    if (identity.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Member ID/Phone dan password wajib diisi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiClient().post(
        ApiConstants.login,
        body: {
          'identifier': identity,
          'login': identity,
          'email': identity,
          'phone': identity,
          'member_id': identity,
          'password': password,
        },
      );

      debugPrint('LOGIN RESPONSE: $response');

      final token = _extractToken(response);
      final role = _extractRole(response);

      if (token != null) {
        await secureStorage.write(
          key: 'access_token',
          value: token,
        );
      }

      if (role != null) {
        await secureStorage.write(
          key: 'user_role',
          value: role,
        );
      }

      if (!mounted) return;

      final normalizedRole = role?.toLowerCase() ?? '';

      if (_isMemberRole(normalizedRole)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MemberHomeScreen(),
          ),
        );
      } else if (normalizedRole.contains('rayon')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Login berhasil sebagai Ketua Rayon. Halaman belum dibuat.'),
            backgroundColor: LoginScreen.navy,
          ),
        );
      } else if (normalizedRole.contains('admin') ||
          normalizedRole.contains('pendeta')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Login berhasil sebagai Admin/Pendeta. Halaman belum dibuat.'),
            backgroundColor: LoginScreen.navy,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login berhasil, tetapi role belum ditemukan: ${role ?? "null"}',
            ),
            backgroundColor: LoginScreen.navy,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String? _extractToken(dynamic response) {
    if (response is! Map) return null;

    return response['token']?.toString() ??
        response['access_token']?.toString() ??
        response['accessToken']?.toString() ??
        response['data']?['token']?.toString() ??
        response['data']?['access_token']?.toString() ??
        response['authorization']?['token']?.toString();
  }

  String? _extractRole(dynamic response) {
    if (response is! Map) return null;

    final user =
        response['user'] ?? response['data']?['user'] ?? response['data'];

    if (user is Map) {
      if (user['role'] != null) {
        return user['role'].toString();
      }

      if (user['role_name'] != null) {
        return user['role_name'].toString();
      }

      if (user['roleName'] != null) {
        return user['roleName'].toString();
      }

      if (user['roles'] is List && (user['roles'] as List).isNotEmpty) {
        final firstRole = (user['roles'] as List).first;

        if (firstRole is Map && firstRole['name'] != null) {
          return firstRole['name'].toString();
        }

        return firstRole.toString();
      }
    }

    if (response['role'] != null) {
      return response['role'].toString();
    }

    return null;
  }

  bool _isMemberRole(String role) {
    if (role.isEmpty) return false;

    return role.contains('jemaat') ||
        role.contains('jamaat') ||
        role.contains('member');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginScreen.softBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
          child: Column(
            children: [
              const _TopBrand(),
              const SizedBox(height: 42),
              const Text(
                'Sistem Informasi\nJemaat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: LoginScreen.navy,
                  fontSize: 34,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Silahkan Login untuk mengakses layanan\ninternal gereja',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: LoginScreen.textGrey,
                  fontSize: 17,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 34),
              _LoginCard(
                memberController: memberController,
                passwordController: passwordController,
                rememberMe: rememberMe,
                obscurePassword: obscurePassword,
                isLoading: isLoading,
                onRememberChanged: (value) {
                  setState(() {
                    rememberMe = value ?? false;
                  });
                },
                onTogglePassword: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
                onLogin: _handleLogin,
              ),
              const SizedBox(height: 34),
              const _InternalNotice(),
              const SizedBox(height: 84),
              const Text(
                'GPDI Sibulele',
                style: TextStyle(
                  color: LoginScreen.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 28),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FooterLink(text: 'PRIVACY POLICY'),
                  SizedBox(width: 24),
                  _FooterLink(text: 'COMMUNITY GUIDE'),
                  SizedBox(width: 24),
                  _FooterLink(text: 'SUPPORT'),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                '© 2024 GPDI SIBULELE. ALL RIGHTS RESERVED.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFA5A9B9),
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.church_outlined,
            color: LoginScreen.navy,
            size: 30,
          ),
          SizedBox(width: 12),
          Text(
            'GPDI Sibulele',
            style: TextStyle(
              color: LoginScreen.navy,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              fontFamily: 'serif',
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  final TextEditingController memberController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool obscurePassword;
  final bool isLoading;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  const _LoginCard({
    required this.memberController,
    required this.passwordController,
    required this.rememberMe,
    required this.obscurePassword,
    required this.isLoading,
    required this.onRememberChanged,
    required this.onTogglePassword,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 34),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _InputLabel(text: 'MEMBER ID / PHONE'),
          const SizedBox(height: 10),
          _LoginInput(
            controller: memberController,
            hintText: 'Masukkan ID atau Nomor HP',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 26),
          const _InputLabel(text: 'PASSWORD'),
          const SizedBox(height: 10),
          _LoginInput(
            controller: passwordController,
            hintText: 'Masukkan Password Anda',
            icon: Icons.lock_outline_rounded,
            obscureText: obscurePassword,
            suffix: IconButton(
              onPressed: onTogglePassword,
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF77798C),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: rememberMe,
                  onChanged: onRememberChanged,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: const BorderSide(
                    color: Color(0xFFBFC2D1),
                    width: 1.2,
                  ),
                  activeColor: LoginScreen.navy,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Remember Me',
                style: TextStyle(
                  color: LoginScreen.textGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Color(0xFF866B00),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: LoginScreen.navy,
                disabledBackgroundColor: LoginScreen.navy.withOpacity(0.6),
                elevation: 12,
                shadowColor: LoginScreen.navy.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.4,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Masuk',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.login_rounded,
                          color: Colors.white,
                          size: 21,
                        ),
                      ],
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
        color: LoginScreen.textDark,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _LoginInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffix;

  const _LoginInput({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: LoginScreen.softInput,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          color: LoginScreen.textDark,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF77798C),
            size: 23,
          ),
          suffixIcon: suffix,
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFFB7B5C5),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
        ),
      ),
    );
  }
}

class _InternalNotice extends StatelessWidget {
  const _InternalNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EFFB),
        borderRadius: BorderRadius.circular(13),
        border: const Border(
          left: BorderSide(
            color: LoginScreen.gold,
            width: 4,
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF866B00),
            size: 23,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Pemberitahuan Internal: Akun hanya tersedia bagi jemaat yang telah terdaftar oleh Admin atau Pendeta. Silahkan hubungi sekretariat jika Anda belum memiliki akses.',
              style: TextStyle(
                color: Color(0xFF565873),
                fontSize: 14,
                height: 1.55,
                fontWeight: FontWeight.w700,
              ),
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
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
