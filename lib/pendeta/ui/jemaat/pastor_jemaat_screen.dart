import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../features/auth/services/user_service.dart';

class PastorJemaatScreen extends StatefulWidget {
  const PastorJemaatScreen({super.key});

  @override
  State<PastorJemaatScreen> createState() => _PastorJemaatScreenState();
}

class _PastorJemaatScreenState extends State<PastorJemaatScreen> {
  final UserService _userService = UserService();
  final ApiClient _apiClient = ApiClient();

  List<dynamic> _allJemaat = [];
  List<dynamic> _filteredJemaat = [];
  List<dynamic> _rayonList = [];
  bool _isLoading = true;
  String _searchTerm = "";
  Timer? _debounce;

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color redAccent = Color(0xFFD71313);
  static const Color softBg = Color(0xFFF7F4FB);
  static const Color textDark = Color(0xFF1E1E2F);
  static const Color textGrey = Color(0xFF85879A);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _fetchRayon(),
        _fetchData(),
      ]);
    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchData() async {
    try {
      final response = await _apiClient.get(ApiConstants.adminUsers);
      _allJemaat = response is List ? response : (response['data'] ?? []);
      _runFilter(_searchTerm);
    } catch (e) {
      debugPrint("Fetch User Error: $e");
    }
  }

  Future<void> _fetchRayon() async {
    try {
      final response = await _apiClient.get(ApiConstants.rayons);
      _rayonList = response is List ? response : (response['data'] ?? []);
    } catch (e) {
      debugPrint("Fetch Rayon Error: $e");
    }
  }

  void _onSearchChanged(String query) {
    _searchTerm = query;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _runFilter(query);
    });
  }

  void _runFilter(String query) {
    if (!mounted) return;
    setState(() {
      if (query.isEmpty) {
        _filteredJemaat = _allJemaat;
      } else {
        final q = query.toLowerCase();
        _filteredJemaat = _allJemaat.where((item) {
          final name = (item['name'] ?? '').toString().toLowerCase();
          final email = (item['email'] ?? '').toString().toLowerCase();
          return name.contains(q) || email.contains(q);
        }).toList();
      }
    });
  }

  String _getRayonName(dynamic id) {
    if (id == null) return "-";
    final rayon = _rayonList.firstWhere(
      (r) => r['id'].toString() == id.toString(),
      orElse: () => null,
    );
    return rayon != null ? (rayon['nama_rayon'] ?? rayon['name'] ?? "-") : "-";
  }

  Future<void> _handleRoleChange(dynamic item, String newRole) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ubah Peran"),
        content: Text("Ubah peran ${item['name']} menjadi ${newRole.replaceAll('_', ' ')}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Ya, Ubah")),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _userService.updateUserRole(item['id'].toString(), newRole);
        _fetchData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Peran berhasil diperbarui"), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal: $e"), backgroundColor: redAccent),
          );
        }
      }
    }
  }

  Future<void> _handleDelete(dynamic item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Akun"),
        content: Text("Yakin ingin menghapus data jemaat: ${item['name']}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _userService.deleteJemaat(item['id'].toString());
        _fetchData();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: redAccent));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text('Manajemen Jemaat', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            onPressed: () => _openAddEditModal(),
            icon: const Icon(Icons.person_add_alt_1_rounded, color: navy),
            tooltip: "Tambah Akun Jemaat",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daftar Jemaat',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: navy),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kelola data anggota, ploting rayon, dan hak akses.',
                  style: TextStyle(fontSize: 13, color: textGrey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari nama atau email...',
                hintStyle: const TextStyle(fontSize: 14),
                prefixIcon: const Icon(Icons.search, size: 20),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: navy))
                : RefreshIndicator(
                    onRefresh: _fetchData,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                      itemCount: _filteredJemaat.length,
                      itemBuilder: (context, index) {
                        final item = _filteredJemaat[index];
                        return _buildJemaatCard(item);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildJemaatCard(dynamic item) {
    final String currentRole = item['role'] ?? 'jemaat';
    final String rayonName = _getRayonName(item['id_rayon']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: navy.withOpacity(0.05),
                  child: Text(item['name']?[0]?.toUpperCase() ?? '?', style: const TextStyle(color: navy, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] ?? 'Tanpa Nama',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: navy),
                      ),
                      Text(
                        item['email'] ?? '-',
                        style: const TextStyle(fontSize: 12, color: textGrey),
                      ),
                    ],
                  ),
                ),
                _buildActionButtons(item),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Rayon Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    "Rayon: $rayonName",
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                ),
                // Role Picker Dropdown
                _buildRoleDropdown(item, currentRole),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleDropdown(dynamic item, String currentRole) {
    Color roleColor;
    if (currentRole == 'pendeta') {
      roleColor = Colors.purple;
    } else if (currentRole == 'ketua_rayon') {
      roleColor = Colors.teal;
    } else {
      roleColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 32,
      decoration: BoxDecoration(
        color: roleColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: roleColor.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentRole,
          icon: Icon(Icons.arrow_drop_down, color: roleColor, size: 18),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: roleColor),
          onChanged: (String? newValue) {
            if (newValue != null && newValue != currentRole) {
              _handleRoleChange(item, newValue);
            }
          },
          items: const [
            DropdownMenuItem(value: 'jemaat', child: Text('JEMAAT')),
            DropdownMenuItem(value: 'ketua_rayon', child: Text('KETUA RAYON')),
            DropdownMenuItem(value: 'pendeta', child: Text('PENDETA/ADMIN')),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(dynamic item) {
    return Row(
      children: [
        IconButton(
          onPressed: () => _openAddEditModal(item),
          icon: const Icon(Icons.edit_rounded, color: Colors.amber, size: 20),
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(8),
        ),
        IconButton(
          onPressed: () => _handleDelete(item),
          icon: const Icon(Icons.delete_outline_rounded, color: redAccent, size: 20),
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(8),
        ),
      ],
    );
  }

  void _openAddEditModal([dynamic item]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddEditJemaatModal(
        item: item,
        rayonList: _rayonList,
        onSave: () => _fetchData(),
      ),
    );
  }
}

class _AddEditJemaatModal extends StatefulWidget {
  final dynamic item;
  final List<dynamic> rayonList;
  final VoidCallback onSave;

  const _AddEditJemaatModal({this.item, required this.rayonList, required this.onSave});

  @override
  State<_AddEditJemaatModal> createState() => _AddEditJemaatModalState();
}

class _AddEditJemaatModalState extends State<_AddEditJemaatModal> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passController;
  String? selectedRole;
  String? selectedRayonId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    nameController = TextEditingController(text: item?['name'] ?? "");
    emailController = TextEditingController(text: item?['email'] ?? "");
    passController = TextEditingController();
    selectedRole = item?['role'] ?? 'jemaat';
    selectedRayonId = item?['id_rayon']?.toString();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if ((selectedRole == 'jemaat' || selectedRole == 'ketua_rayon') && selectedRayonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Silakan pilih Rayon!")));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final payload = {
        'name': nameController.text,
        'email': emailController.text,
        'role': selectedRole,
        'id_rayon': selectedRole == 'pendeta' ? null : selectedRayonId,
      };
      if (passController.text.isNotEmpty) {
        payload['password'] = passController.text;
      }

      if (widget.item != null) {
        await _userService.updateJemaat(widget.item['id'].toString(), payload);
        // Also update role if changed (matching React logic)
        await _userService.updateUserRole(widget.item['id'].toString(), selectedRole!);
      } else {
        await _userService.createJemaat(payload);
      }

      widget.onSave();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item != null ? 'Edit Data & Peran' : 'Buat Akun Jemaat Baru',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF05066F)),
              ),
              const SizedBox(height: 24),

              _buildLabel("Nama Lengkap"),
              _buildInput(nameController, "Masukkan nama lengkap"),

              _buildLabel("Alamat Email"),
              _buildInput(emailController, "jemaat@gpdi.com", keyboardType: TextInputType.emailAddress),

              _buildLabel("Kata Sandi ${widget.item != null ? '(Kosongkan jika tidak diubah)' : ''}"),
              _buildInput(passController, "Minimal 6 karakter", isPassword: true, required: widget.item == null),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Peran Akses"),
                        DropdownButtonFormField<String>(
                          value: selectedRole,
                          items: const [
                            DropdownMenuItem(value: 'jemaat', child: Text('Jemaat Biasa', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'ketua_rayon', child: Text('Ketua Rayon', style: TextStyle(fontSize: 13))),
                            DropdownMenuItem(value: 'pendeta', child: Text('Pendeta / Admin', style: TextStyle(fontSize: 13))),
                          ],
                          onChanged: (v) => setState(() => selectedRole = v),
                          decoration: _inputDeco(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Plotting Rayon"),
                        DropdownButtonFormField<String>(
                          value: selectedRayonId,
                          disabledHint: const Text("-", style: TextStyle(fontSize: 13)),
                          items: selectedRole == 'pendeta'
                            ? null
                            : widget.rayonList.map((r) => DropdownMenuItem(value: r['id'].toString(), child: Text(r['nama_rayon'] ?? r['name'] ?? "-", style: const TextStyle(fontSize: 13)))).toList(),
                          onChanged: selectedRole == 'pendeta' ? null : (v) => setState(() => selectedRayonId = v),
                          decoration: _inputDeco(),
                          hint: const Text("-- Pilih --", style: TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF05066F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(_isSubmitting ? "Menyimpan..." : "Simpan Akun", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF05066F))),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, {bool isPassword = false, bool required = true, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        decoration: _inputDeco(hint: hint),
        validator: required ? (v) => (v == null || v.isEmpty) ? "Wajib diisi" : null : null,
      ),
    );
  }

  InputDecoration _inputDeco({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
    );
  }
}
