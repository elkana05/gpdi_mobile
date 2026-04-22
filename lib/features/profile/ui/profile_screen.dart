import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text("Profil Saya")),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(user.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Center(
            child: Text(user.email, style: const TextStyle(color: Colors.grey)),
          ),
          const Divider(height: 40),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text("Peran / Role"),
            subtitle: Text(user.roles.join(', ').toUpperCase()),
          ),
          ListTile(
            leading: const Icon(Icons.phone_android),
            title: const Text("Nomor Telepon"),
            subtitle: Text(user.phoneNumber ?? "Belum diatur"),
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text("Alamat"),
            subtitle: Text(user.address ?? "Belum diatur"),
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () => context.read<AuthProvider>().logout(),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("KELUAR DARI APLIKASI"),
          ),
        ],
      ),
    );
  }
}