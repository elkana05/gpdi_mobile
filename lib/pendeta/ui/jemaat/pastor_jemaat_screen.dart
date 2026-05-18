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
  static const Color textGrey = Color(0xFF7A7C92);

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
    String selectedRole = user?.roles.isNotEmpty == true ? user!.roles.first : 'jemaat';
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
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 20),
                  Text(user == null ? 'Tambah Akun Jemaat' : 'Edit Data Jemaat',
                    style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: navy)),
                  const SizedBox(height: 24),

                  _buildLabel('Nama Lengkap'),
                  TextFormField(
                    controller: nameController,
                    style: GoogleFonts.montserrat(fontSize: 14),
                    decoration: _inputDecoration('Contoh: Budi Santoso', Icons.person_outline),
                    validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Email Akun'),
                  TextFormField(
                    controller: emailController,
                    style: GoogleFonts.montserrat(fontSize: 14),
                    decoration: _inputDecoration('jemaat@email.com', Icons.alternate_email),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.isEmpty ? 'Email wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Password ${user != null ? "(Kosongkan jika tidak ganti)" : ""}'),
                  TextFormField(
                    controller: passwordController,
                    style: GoogleFonts.montserrat(fontSize: 14),
                    decoration: _inputDecoration('Minimal 6 karakter', Icons.lock_outline),
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
                            _buildLabel('Akses'),
                            DropdownButtonFormField<String>(
                              value: selectedRole,
                              style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black),
                              decoration: _inputDecoration('', null),
                              items: const [
                                DropdownMenuItem(value: 'jemaat', child: Text('Jemaat')),
                                DropdownMenuItem(value: 'ketua_rayon', child: Text('Ketua')),
                                DropdownMenuItem(value: 'pendeta', child: Text('Pastor')),
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
                              style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black),
                              decoration: _inputDecoration('', null),
                              items: provider.rayons.map((r) => DropdownMenuItem(
                                value: r.id.toString(),
                                child: Text(r.name, overflow: TextOverflow.ellipsis),
                              )).toList(),
                              onChanged: selectedRole == 'pendeta' ? null : (v) => setModalState(() => selectedRayonId = v),
                              validator: (v) => (selectedRole != 'pendeta' && v == null) ? 'Pilih' : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: navy,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                      ),
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
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil disimpan'), backgroundColor: Colors.green));
                          }
                        }
                      },
                      child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('SIMPAN PERUBAHAN', style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(text, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w800, color: textGrey)),
  );

  InputDecoration _inputDecoration(String hint, IconData? icon) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.montserrat(fontSize: 13, color: textGrey.withOpacity(0.5)),
    prefixIcon: icon != null ? Icon(icon, color: navy, size: 20) : null,
    filled: true,
    fillColor: softBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: navy, width: 1)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Data Jemaat', style: GoogleFonts.montserrat(color: navy, fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          IconButton(
            onPressed: () => _showUserForm(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: navy.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.person_add_rounded, color: navy, size: 20),
            ),
          ),
          const SizedBox(width: 8),
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
              _buildFilterSection(provider),
              Expanded(
                child: provider.isLoading && users.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: navy))
                  : RefreshIndicator(
                      onRefresh: _fetchData,
                      color: navy,
                      child: users.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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

  Widget _buildFilterSection(UserProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            style: GoogleFonts.montserrat(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Cari nama atau email...',
              prefixIcon: const Icon(Icons.search_rounded, color: textGrey),
              filled: true,
              fillColor: softBg,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(null, 'Semua'),
                ...provider.rayons.map((r) => _buildFilterChip(r.id.toString(), r.name)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String? value, String label) {
    bool isSelected = _selectedRayonFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedRayonFilter = value),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? navy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? navy : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : textGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    final provider = Provider.of<UserProvider>(context, listen: false);
    String roleName = user.roles.isEmpty ? 'JEMAAT' : user.roles.first.replaceAll('_', ' ').toUpperCase();

    Color roleColor = navy;
    if (roleName.contains('PASTOR')) roleColor = Colors.purple;
    if (roleName.contains('KETUA')) roleColor = gold;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: roleColor.withOpacity(0.1),
            child: Icon(Icons.person_rounded, color: roleColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName, style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 14, color: navy)),
                Text(user.email, style: GoogleFonts.montserrat(fontSize: 11, color: textGrey, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: roleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(roleName, style: GoogleFonts.montserrat(fontSize: 9, color: roleColor, fontWeight: FontWeight.w900)),
                    ),
                    if (user.rayonId != null) ...[
                      const SizedBox(width: 8),
                      Text('Rayon ${user.rayonId}', style: GoogleFonts.montserrat(fontSize: 10, color: textGrey, fontWeight: FontWeight.w600)),
                    ]
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: textGrey),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onSelected: (val) async {
              if (val == 'edit') {
                _showUserForm(user);
              } else if (val == 'delete') {
                final confirm = await _showDeleteConfirm(user.fullName);
                if (confirm) await provider.deleteJemaat(user.id);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit', child: Row(children: [const Icon(Icons.edit_rounded, size: 18, color: Colors.orange), const SizedBox(width: 12), Text('Edit', style: GoogleFonts.montserrat(fontSize: 13))])),
              PopupMenuItem(value: 'delete', child: Row(children: [const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red), const SizedBox(width: 12), Text('Hapus', style: GoogleFonts.montserrat(fontSize: 13, color: Colors.red))])),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Jemaat?', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: navy)),
        content: Text('Apakah Anda yakin ingin menghapus data $name?', style: GoogleFonts.montserrat(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal', style: GoogleFonts.montserrat(color: textGrey, fontWeight: FontWeight.bold))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Hapus', style: GoogleFonts.montserrat(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    ) ?? false;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text('Tidak ada data jemaat', style: GoogleFonts.montserrat(color: textGrey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
