import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../features/auth/providers/user_provider.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../features/auth/models/rayon_model.dart';

class PastorJemaatScreen extends StatefulWidget {
  const PastorJemaatScreen({super.key});

  @override
  State<PastorJemaatScreen> createState() => _PastorJemaatScreenState();
}

class _PastorJemaatScreenState extends State<PastorJemaatScreen> {
  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F9FE);

  String _searchQuery = '';
  String? _selectedRayonFilter;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchData());
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    final provider = Provider.of<UserProvider>(context, listen: false);
    await provider.fetchAdminUsers();
    await provider.fetchRayons();
  }

  void _showUserForm([UserModel? user]) {
    final provider = Provider.of<UserProvider>(context, listen: false);
    final nameController = TextEditingController(text: user?.fullName ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final passwordController = TextEditingController();
    String selectedRole = user?.roles.first ?? 'jemaat';
    String? selectedRayonId = user?.rayonId?.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user == null ? 'Tambah Akun Jemaat' : 'Edit Data Jemaat',
                    style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: navy)),
                  const SizedBox(height: 20),

                  _buildLabel('Nama Lengkap'),
                  TextFormField(
                    controller: nameController,
                    decoration: _inputDecoration('Masukkan nama'),
                    validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Email'),
                  TextFormField(
                    controller: emailController,
                    decoration: _inputDecoration('jemaat@gpdi.com'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.isEmpty ? 'Email wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Password ${user != null ? "(Kosongkan jika tidak diubah)" : ""}'),
                  TextFormField(
                    controller: passwordController,
                    decoration: _inputDecoration('Minimal 6 karakter'),
                    obscureText: true,
                    validator: (v) => (user == null && v!.isEmpty) ? 'Password wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Peran Akses'),
                            DropdownButtonFormField<String>(
                              value: selectedRole,
                              decoration: _inputDecoration(''),
                              items: const [
                                DropdownMenuItem(value: 'jemaat', child: Text('Jemaat')),
                                DropdownMenuItem(value: 'ketua_rayon', child: Text('Ketua Rayon')),
                                DropdownMenuItem(value: 'pendeta', child: Text('Pendeta')),
                              ],
                              onChanged: (v) => setModalState(() {
                                selectedRole = v!;
                                if (v == 'pendeta') selectedRayonId = null;
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Plotting Rayon'),
                            DropdownButtonFormField<String>(
                              value: selectedRayonId,
                              disabledHint: const Text('-'),
                              decoration: _inputDecoration(''),
                              items: provider.rayons.map((r) => DropdownMenuItem(
                                value: r.id.toString(),
                                child: Text(r.name, overflow: TextOverflow.ellipsis),
                              )).toList(),
                              onChanged: selectedRole == 'pendeta' ? null : (v) => setModalState(() => selectedRayonId = v),
                              validator: (v) => (selectedRole != 'pendeta' && v == null) ? 'Pilih Rayon' : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: provider.isLoading ? null : () async {
                        if (_formKey.currentState!.validate()) {
                          final payload = {
                            'name': nameController.text,
                            'email': emailController.text,
                            'role': selectedRole,
                            'id_rayon': selectedRayonId,
                          };
                          if (passwordController.text.isNotEmpty) {
                            payload['password'] = passwordController.text;
                          }

                          bool success;
                          if (user == null) {
                            success = await provider.createJemaat(payload);
                          } else {
                            success = await provider.updateJemaat(user.id, payload);
                          }

                          if (success && mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil menyimpan data')));
                          }
                        }
                      },
                      child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('SIMPAN AKUN', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: softBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Manajemen Jemaat', style: GoogleFonts.montserrat(color: navy, fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          IconButton(
            onPressed: () => _showUserForm(),
            icon: const Icon(Icons.person_add_alt_1, color: navy),
          )
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, _) {
          final users = provider.adminUsers.where((u) {
            final matchSearch = u.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                u.email.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchRayon = _selectedRayonFilter == null || u.rayonId?.toString() == _selectedRayonFilter;
            return matchSearch && matchRayon;
          }).toList();

          return Column(
            children: [
              _buildFilters(provider),
              Expanded(
                child: provider.isLoading && users.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: navy))
                  : RefreshIndicator(
                      onRefresh: _fetchData,
                      color: navy,
                      child: users.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: users.length,
                            itemBuilder: (context, index) => _buildUserCard(users[index]),
                          ),
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters(UserProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Cari nama atau email...',
              prefixIcon: const Icon(Icons.search, color: navy),
              filled: true,
              fillColor: softBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedRayonFilter,
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              filled: true,
              fillColor: softBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            hint: const Text('Filter Rayon'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Semua Rayon')),
              ...provider.rayons.map((r) => DropdownMenuItem(
                value: r.id.toString(),
                child: Text(r.name),
              )),
            ],
            onChanged: (v) => setState(() => _selectedRayonFilter = v),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    final provider = Provider.of<UserProvider>(context, listen: false);
    String roleName = user.roles.isEmpty ? 'Jemaat' : user.roles.first.replaceAll('_', ' ').toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: navy.withOpacity(0.1),
            child: const Icon(Icons.person, color: navy),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName, style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 15)),
                Text(user.email, style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: gold.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(roleName, style: GoogleFonts.montserrat(fontSize: 10, color: gold, fontWeight: FontWeight.bold)),
                    ),
                    if (user.rayonId != null) ...[
                      const SizedBox(width: 8),
                      Text('Rayon ${user.rayonId}', style: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey[600])),
                    ]
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (val) async {
              if (val == 'edit') {
                _showUserForm(user);
              } else if (val == 'delete') {
                final confirm = await _showDeleteConfirm(user.fullName);
                if (confirm) await provider.deleteJemaat(user.id);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))])),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirm(String name) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jemaat?'),
        content: Text('Apakah Anda yakin ingin menghapus data $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Tidak ada data jemaat', style: GoogleFonts.montserrat(color: Colors.grey)),
        ],
      ),
    );
  }
}
