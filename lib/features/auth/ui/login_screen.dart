import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Placeholder Logo GPdI dari Figma Anda
              const Icon(Icons.church, size: 80, color: Color(0xFF0D1282)),
              const SizedBox(height: 16),
              const Text(
                "GPdI SIBULELE",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D1282)),
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Kata Sandi",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (authProvider.status == AuthStatus.error)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(authProvider.errorMessage, style: const TextStyle(color: Colors.red)),
                ),

              authProvider.status == AuthStatus.authenticating
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () async {
                  final success = await context.read<AuthProvider>().login(
                    _emailController.text,
                    _passwordController.text,
                  );
                  // Navigasi otomatis diurus oleh GoRouter redirect
                },
                child: const Text("MASUK"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}