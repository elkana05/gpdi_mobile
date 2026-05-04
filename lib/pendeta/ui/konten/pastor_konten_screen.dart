import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

class PastorKontenScreen extends StatefulWidget {
  const PastorKontenScreen({super.key});

  @override
  State<PastorKontenScreen> createState() => _PastorKontenScreenState();
}

class _PastorKontenScreenState extends State<PastorKontenScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<dynamic> _dataList = [];
  List<dynamic> _rayonList = [];
  String _errorMsg = '';

  // Form States
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {};
  String? _fotoBase64;

  static const Color navy = Color(0xFF05066F);
  static const Color slate = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fetchData();
      }
    });
    _fetchRayons();
    _fetchData();
  }

  Future<void> _fetchRayons() async {
    try {
      final res = await ApiClient().get(ApiConstants.rayons);
      if (mounted) {
        setState(() {
          _rayonList = res is List ? res : (res['data'] ?? []);
        });
      }
    } catch (e) {
      debugPrint("Gagal memuat rayon: $e");
    }
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });
    try {
      String endpoint = '';
      switch (_tabController.index) {
        case 0: endpoint = ApiConstants.announcements; break;
        case 1: endpoint = ApiConstants.devotionals; break;
        case 2: endpoint = ApiConstants.gallery; break;
      }

      final res = await ApiClient().get(endpoint);
      if (mounted) {
        setState(() {
          _dataList = res is List ? res : (res['data'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = "Gagal memuat data konten.";
          _isLoading = false;
        });
      }
    }
  }

  void _handleOpenModal([dynamic item]) {
    _fotoBase64 = null;
    if (item != null) {
      _formData = {
        'id': item['id'],
        'judul': item['judul'] ?? '',
        'scope': item['scope'] ?? 'publik',
        'id_rayon': item['id_rayon']?.toString() ?? '',
        'tema': item['tema'] ?? '',
        'ayat_pokok': item['ayat_pokok'] ?? '',
        'deskripsi': item['deskripsi'] ?? '',
        'tanggal_kegiatan': item['tanggal_kegiatan']?.toString().split('T')[0] ?? '',
        'kategori': item['kategori'] ?? 'Umum',
        'isi': item['isi'] ?? '',
        'status': item['status'] ?? 'Aktif',
      };
    } else {
      _formData = {
        'judul': '',
        'scope': 'publik',
        'id_rayon': '',
        'tema': '',
        'ayat_pokok': '',
        'deskripsi': '',
        'tanggal_kegiatan': '',
        'kategori': 'Umum',
        'isi': '',
        'status': 'Aktif',
      };
    }
    _showFormDialog();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Validasi Pengumuman Rayon
    if (_tabController.index == 0 && _formData['scope'] == 'rayon' && (_formData['id_rayon'] == null || _formData['id_rayon'].isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan pilih rayon target!')));
      return;
    }

    // Validasi Galeri Baru (Wajib Foto)
    if (_tabController.index == 2 && _formData['id'] == null && _fotoBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wajib mengunggah foto untuk galeri baru!')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      String endpoint = '';
      switch (_tabController.index) {
        case 0: endpoint = ApiConstants.announcements; break;
        case 1: endpoint = ApiConstants.devotionals; break;
        case 2: endpoint = ApiConstants.gallery; break;
      }

      final payload = Map<String, dynamic>.from(_formData);
      if (_fotoBase64 != null) {
        payload['foto'] = _fotoBase64;
      }

      if (_formData['id'] != null) {
        await ApiClient().post('$endpoint/${_formData['id']}/update', body: payload);
      } else {
        await ApiClient().post(endpoint, body: payload);
      }

      if (mounted) {
        Navigator.pop(context);
        _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Konten berhasil disimpan')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleDelete(dynamic item) async {
    String label = item['judul'] ?? item['tema'] ?? 'konten ini';
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Hapus data "$label" secara permanen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        String endpoint = '';
        switch (_tabController.index) {
          case 0: endpoint = ApiConstants.announcements; break;
          case 1: endpoint = ApiConstants.devotionals; break;
          case 2: endpoint = ApiConstants.gallery; break;
        }
        await ApiClient().delete('$endpoint/${item['id']}');
        _fetchData();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _pickImage(StateSetter setModalState) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 80);
    if (image != null) {
      final bytes = await image.readAsBytes();
      final String base64Image = 'data:image/${image.path.split('.').last};base64,${base64Encode(bytes)}';
      setModalState(() {
        _fotoBase64 = base64Image;
      });
    }
  }

  void _showFormDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            _formData['id'] == null ? 'Buat ${_getTabTitle()}' : 'Edit ${_getTabTitle()}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: navy),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _buildFormFields(setModalState),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: _isSubmitting ? null : () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(backgroundColor: navy),
              child: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan Data'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormFields(StateSetter setModalState) {
    int activeIdx = _tabController.index;

    if (activeIdx == 2) { // Galeri
      return [
        DropdownButtonFormField<String>(
          value: _formData['kategori'],
          decoration: const InputDecoration(labelText: 'Kategori Kegiatan'),
          items: ['Umum', 'Ibadah', 'Pemuda', 'Sekolah Minggu', 'Wanita']
              .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setModalState(() => _formData['kategori'] = v),
        ),
        _buildTextField('Judul Foto/Kegiatan', (v) => _formData['judul'] = v, initialValue: _formData['judul'], required: true),
        _buildTextField('Tanggal Kegiatan', (v) => _formData['tanggal_kegiatan'] = v, initialValue: _formData['tanggal_kegiatan'], hint: 'YYYY-MM-DD', required: true),
        const SizedBox(height: 12),
        _buildImagePicker(setModalState),
        _buildTextField('Deskripsi Singkat', (v) => _formData['deskripsi'] = v, initialValue: _formData['deskripsi'], maxLines: 3),
      ];
    }

    return [
      if (activeIdx == 0) ...[
        _buildTextField('Judul Pengumuman', (v) => _formData['judul'] = v, initialValue: _formData['judul'], required: true),
      ] else ...[
        _buildTextField('Tema Renungan', (v) => _formData['tema'] = v, initialValue: _formData['tema'], required: true),
        _buildTextField('Ayat Pokok', (v) => _formData['ayat_pokok'] = v, initialValue: _formData['ayat_pokok'], required: true),
      ],
      _buildTextField('Isi Konten', (v) => _formData['isi'] = v, initialValue: _formData['isi'], maxLines: 5, required: true),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _formData['status'],
              decoration: const InputDecoration(labelText: 'Status'),
              items: ['Aktif', 'Tidak Aktif'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setModalState(() => _formData['status'] = v),
            ),
          ),
          if (activeIdx == 0) ...[
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _formData['scope'],
                decoration: const InputDecoration(labelText: 'Audiens'),
                items: ['publik', 'jemaat', 'rayon'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setModalState(() => _formData['scope'] = v),
              ),
            ),
          ]
        ],
      ),
      if (activeIdx == 0 && _formData['scope'] == 'rayon') ...[
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _rayonList.any((r) => r['id'].toString() == _formData['id_rayon']) ? _formData['id_rayon'] : null,
          decoration: const InputDecoration(labelText: 'Pilih Rayon'),
          items: _rayonList.map((r) => DropdownMenuItem(value: r['id'].toString(), child: Text(r['nama_rayon']))).toList(),
          onChanged: (v) => setModalState(() => _formData['id_rayon'] = v),
        ),
      ]
    ];
  }

  Widget _buildTextField(String label, Function(String?) onSaved, {String? initialValue, String? hint, bool required = false, int maxLines = 1}) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(labelText: label, hintText: hint),
      maxLines: maxLines,
      validator: required ? (v) => v!.isEmpty ? 'Wajib diisi' : null : null,
      onSaved: onSaved,
    );
  }

  Widget _buildImagePicker(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('File Foto', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: slate)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickImage(setModalState),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: _fotoBase64 != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(base64Decode(_fotoBase64!.split(',').last), fit: BoxFit.cover),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_rounded, color: Colors.blue, size: 32),
                      Text('Pilih Gambar', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
          ),
        ),
        if (_formData['id'] != null && _fotoBase64 == null)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('*Biarkan kosong jika tidak diganti', style: TextStyle(fontSize: 10, color: slate)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Konten & Publikasi', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Kelola informasi, spiritualitas, dan dokumentasi', style: TextStyle(color: slate, fontSize: 12)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: navy,
          unselectedLabelColor: slate,
          indicatorColor: navy,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'PENGUMUMAN'),
            Tab(text: 'RENUNGAN'),
            Tab(text: 'GALERI'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Daftar ${_getTabTitle()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () => _handleOpenModal(),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('Tambah ${_getTabTitle()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: navy))
                : _errorMsg.isNotEmpty
                    ? Center(child: Text(_errorMsg, style: const TextStyle(color: Colors.red)))
                    : RefreshIndicator(
                        onRefresh: _fetchData,
                        child: _tabController.index == 2 ? _buildGaleriGrid() : _buildContentList(),
                      ),
          ),
        ],
      ),
    );
  }

  String _getTabTitle() {
    switch (_tabController.index) {
      case 0: return 'Pengumuman';
      case 1: return 'Renungan';
      case 2: return 'Galeri';
      default: return '';
    }
  }

  Widget _buildContentList() {
    if (_dataList.isEmpty) return const Center(child: Text('Belum ada data.'));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _dataList.length,
      itemBuilder: (context, index) {
        final item = _dataList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(item['judul'] ?? item['tema'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, color: navy)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item['ayat_pokok'] != null) Text(item['ayat_pokok'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(item['isi'] ?? '-', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (item['scope'] != null)
                      _buildChip(item['scope'].toString().toUpperCase(), Colors.blue),
                    _buildChip(item['status']?.toString().toUpperCase() ?? 'AKTIF',
                      item['status'] == 'Aktif' ? Colors.green : Colors.red),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  onPressed: () => _handleOpenModal(item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  onPressed: () => _handleDelete(item),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGaleriGrid() {
    if (_dataList.isEmpty) return const Center(child: Text('Belum ada data.'));
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: _dataList.length,
      itemBuilder: (context, index) {
        final item = _dataList[index];
        final imageUrl = item['foto'] != null ? '${ApiConstants.host}${item['foto']}' : null;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: imageUrl != null
                      ? Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey[100], child: const Icon(Icons.broken_image_outlined)))
                      : Container(color: Colors.grey[100], child: const Icon(Icons.image_outlined)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['judul'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: navy), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(item['kategori'] ?? 'Umum', style: const TextStyle(fontSize: 11, color: slate)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () => _handleOpenModal(item),
                          child: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () => _handleDelete(item),
                          child: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
