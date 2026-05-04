import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

class PastorJemaatScreen extends StatefulWidget {
  const PastorJemaatScreen({super.key});

  @override
  State<PastorJemaatScreen> createState() => _PastorJemaatScreenState();
}

class _PastorJemaatScreenState extends State<PastorJemaatScreen> {
  List<dynamic> _jemaat = [];
  List<dynamic> _rayonList = [];
  String _searchTerm = '';
  bool _isLoading = true;
  String _errorMsg = '';

  // State untuk Modal Form
  bool _isSubmitting = false;
  int? _editId;

  // Form Data
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {
    'name': '',
    'email': '',
    'password': '',
    'role': 'jemaat',
    'id_rayon': ''
  };

  static const Color navy = Color(0xFF05066F);
  static const Color slate = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchRayon();
  }

<<<<<<< Updated upstream
  // Normalisasi role agar sesuai dengan dropdown UI (admin/pendeta dipetakan ke 'pendeta')
=======
  // Fungsi pembantu untuk memastikan role selalu valid bagi Dropdown
  // Mengonversi 'admin' dari database menjadi 'pendeta' agar sesuai dengan UI
>>>>>>> Stashed changes
  String _normalizeRole(String? role) {
    if (role == 'admin' || role == 'pendeta') return 'pendeta';
    if (role == 'ketua_rayon') return 'ketua_rayon';
    return 'jemaat';
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });
    try {
      final data = await ApiClient().get(ApiConstants.allUsers);
      if (mounted) {
        setState(() {
          _jemaat = data is List ? data : (data['data'] ?? []);
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMsg = "Gagal mengambil data jemaat.";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchRayon() async {
    try {
      final response = await ApiClient().get(ApiConstants.rayons);
      if (mounted) {
        setState(() {
          _rayonList = response is List ? response : (response['data'] ?? []);
        });
      }
    } catch (error) {
      debugPrint("Gagal memuat daftar rayon: $error");
    }
  }

  Future<void> _handleRoleChangeInline(dynamic item, String newRole) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: Text('Ubah peran ${item['name'] ?? 'pengguna'} menjadi ${newRole.replaceAll('_', ' ')}?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya, Ubah')),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await ApiClient().post('${ApiConstants.allUsers}/${item['id']}/role', body: {'role': newRole});
        _fetchData();
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal mengubah peran: $error")));
        }
      }
    }
  }

  void _handleOpenAddModal() {
    setState(() {
      _editId = null;
      _formData = {'name': '', 'email': '', 'password': '', 'role': 'jemaat', 'id_rayon': ''};
      _errorMsg = '';
    });
    _showFormDialog();
  }

  void _handleOpenEditModal(dynamic item) {
    setState(() {
      _editId = item['id'];
      _formData = {
        'name': item['name'] ?? '',
        'email': item['email'] ?? '',
        'password': '',
<<<<<<< Updated upstream
        'role': _normalizeRole(item['role']),
=======
        'role': _normalizeRole(item['role']), // Normalisasi saat load data edit
>>>>>>> Stashed changes
        'id_rayon': item['id_rayon']?.toString() ?? ''
      };
      _errorMsg = '';
    });
    _showFormDialog();
  }

  Future<void> _handleSubmitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if ((_formData['role'] == 'jemaat' || _formData['role'] == 'ketua_rayon') && (_formData['id_rayon'] == null || _formData['id_rayon'].isEmpty)) {
      setState(() => _errorMsg = "Silakan pilih Rayon untuk pengguna ini!");
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final finalPayload = Map<String, dynamic>.from(_formData);
      if (finalPayload['role'] == 'pendeta') {
        finalPayload['id_rayon'] = null;
      }

      if (_editId != null) {
        await ApiClient().post('${ApiConstants.allUsers}/$_editId/update', body: finalPayload);
      } else {
        await ApiClient().post(ApiConstants.allUsers, body: finalPayload);
      }

      if (mounted) {
        Navigator.pop(context);
        _fetchData();
      }
    } catch (error) {
      if (mounted) {
        setState(() => _errorMsg = error.toString());
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleDelete(dynamic item) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Jemaat'),
            content: Text('Apakah Anda yakin ingin menghapus jemaat: ${item['name']}?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await ApiClient().delete('${ApiConstants.allUsers}/${item['id']}');
        _fetchData();
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menghapus: $error")));
        }
      }
    }
  }

  String _getRayonName(dynamic id) {
    if (id == null) return "-";
    final rayon = _rayonList.firstWhere((r) => r['id'].toString() == id.toString(), orElse: () => null);
    return rayon != null ? rayon['nama_rayon'] : "-";
  }

  @override
  Widget build(BuildContext context) {
    final filteredJemaat = _jemaat.where((item) {
      final matchName = (item['name'] ?? '').toString().toLowerCase().contains(_searchTerm.toLowerCase());
      final matchEmail = (item['email'] ?? '').toString().toLowerCase().contains(_searchTerm.toLowerCase());
      return matchName || matchEmail;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manajemen Jemaat', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Kelola anggota, plotting rayon, dan hak akses', style: TextStyle(color: slate, fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _searchTerm = v),
                      decoration: const InputDecoration(
                        hintText: 'Cari nama atau email...',
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: slate, size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _handleOpenAddModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.all(12),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: navy))
                : filteredJemaat.isEmpty
                    ? const Center(child: Text('Tidak ada data jemaat.'))
                    : RefreshIndicator(
                        onRefresh: _fetchData,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredJemaat.length,
                          itemBuilder: (context, index) => _buildJemaatCard(filteredJemaat[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildJemaatCard(dynamic item) {
<<<<<<< Updated upstream
    String role = _normalizeRole(item['role']);
=======
    String role = _normalizeRole(item['role']); // Normalisasi role di kartu jemaat agar tidak crash
>>>>>>> Stashed changes
    Color roleColor = role == 'pendeta' ? Colors.purple : (role == 'ketua_rayon' ? Colors.green : Colors.blue);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: roleColor.withOpacity(0.1),
                  child: Text((item['name'] ?? '?')[0].toUpperCase(), style: TextStyle(color: roleColor, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'] ?? 'Tanpa Nama', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(item['email'] ?? '-', style: const TextStyle(color: slate, fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.amber, size: 20),
                  onPressed: () => _handleOpenEditModal(item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => _handleDelete(item),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('RAYON', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: slate, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                      child: Text(_getRayonName(item['id_rayon']), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('PERAN AKSES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: slate, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    DropdownButton<String>(
                      value: role,
                      isDense: true,
                      underline: const SizedBox(),
                      onChanged: (v) => _handleRoleChangeInline(item, v!),
                      items: const [
<<<<<<< Updated upstream
                        DropdownMenuItem(value: 'jemaat', child: Text('Jemaat', style: TextStyle(fontSize: 12, color: Colors.blue))),
                        DropdownMenuItem(value: 'ketua_rayon', child: Text('Ketua Rayon', style: TextStyle(fontSize: 12, color: Colors.green))),
                        DropdownMenuItem(value: 'pendeta', child: Text('Pendeta', style: TextStyle(fontSize: 12, color: Colors.purple))),
=======
                        DropdownMenuItem(value: 'jemaat', child: Text('Jemaat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue))),
                        DropdownMenuItem(value: 'ketua_rayon', child: Text('Ketua Rayon', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green))),
                        DropdownMenuItem(value: 'pendeta', child: Text('Pendeta', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.purple))),
>>>>>>> Stashed changes
                      ],
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showFormDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(_editId == null ? 'Buat Akun Jemaat Baru' : 'Edit Data & Peran', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: _formData['name'],
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      prefixIcon: const Icon(Icons.person_outline, color: navy),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
                    onSaved: (v) => _formData['name'] = v,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _formData['email'],
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined, color: navy),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Email wajib diisi' : null,
                    onSaved: (v) => _formData['email'] = v,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: _editId == null ? 'Password' : 'Password (Kosongkan jika tidak diubah)',
                      prefixIcon: const Icon(Icons.lock_outline, color: navy),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => (_editId == null && (v == null || v.isEmpty)) ? 'Password wajib diisi' : null,
                    onSaved: (v) => _formData['password'] = v,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _formData['role'],
                    decoration: InputDecoration(
                      labelText: 'Hak Akses',
                      prefixIcon: const Icon(Icons.security, color: navy),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'jemaat', child: Text('Jemaat')),
                      DropdownMenuItem(value: 'ketua_rayon', child: Text('Ketua Rayon')),
                      DropdownMenuItem(value: 'pendeta', child: Text('Pendeta')),
                    ],
                    onChanged: (v) {
                      setModalState(() {
                        _formData['role'] = v;
                        if (v == 'pendeta') _formData['id_rayon'] = '';
                      });
                    },
                  ),
                  if (_formData['role'] != 'pendeta') ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _formData['id_rayon'].toString().isEmpty ? null : _formData['id_rayon'].toString(),
                      decoration: InputDecoration(
                        labelText: 'Rayon',
                        prefixIcon: const Icon(Icons.map_outlined, color: navy),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _rayonList.map((r) {
                        return DropdownMenuItem<String>(
                          value: r['id'].toString(),
                          child: Text(r['nama_rayon'] ?? '-'),
                        );
                      }).toList(),
                      onChanged: (v) => setModalState(() => _formData['id_rayon'] = v),
                      validator: (v) => (v == null || v.isEmpty) ? 'Pilih rayon' : null,
                    ),
                  ],
                  if (_errorMsg.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(_errorMsg, style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isSubmitting ? null : () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: slate)),
            ),
            ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : () async {
<<<<<<< Updated upstream
                      setModalState(() => _isSubmitting = true);
                      await _handleSubmitForm();
                      if (mounted) setModalState(() => _isSubmitting = false);
                    },
              style: ElevatedButton.styleFrom(backgroundColor: navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
=======
                      // Trigger loading state in dialog
                      setModalState(() => _isSubmitting = true);
                      await _handleSubmitForm();
                      if (mounted) {
                        setModalState(() => _isSubmitting = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
>>>>>>> Stashed changes
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}