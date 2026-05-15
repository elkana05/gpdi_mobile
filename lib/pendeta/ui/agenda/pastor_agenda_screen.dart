import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

class PastorAgendaScreen extends StatefulWidget {
  const PastorAgendaScreen({super.key});

  @override
  State<PastorAgendaScreen> createState() => _PastorAgendaScreenState();
}

class _PastorAgendaScreenState extends State<PastorAgendaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<dynamic> _dataList = [];
  List<dynamic> _rayonsList = [];
  String _errorMsg = '';

  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {};
  String? _fotoBase64;

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color redAccent = Color(0xFFD71313);
  static const Color slate = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _fetchData();
      }
    });
    _fetchRayonsDropdown();
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchRayonsDropdown() async {
    try {
      final res = await ApiClient().get(ApiConstants.rayons);
      if (mounted) {
        setState(() {
          _rayonsList = res is List ? res : (res['data'] ?? []);
        });
      }
    } catch (e) {
      debugPrint("Gagal muat rayon: $e");
    }
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });
    try {
      String endpoint = _getEndpoint();
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
          _errorMsg = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _getEndpoint() {
    switch (_tabController.index) {
      case 0: return ApiConstants.adminWorship; // Diubah ke endpoint admin
      case 1: return ApiConstants.adminActivity; // Diubah ke endpoint admin
      case 2: return ApiConstants.manageRayonSchedules;
      case 3: return ApiConstants.rayons;
      default: return '';
    }
  }

  String _getTabTitle() {
    switch (_tabController.index) {
      case 0: return 'Ibadah';
      case 1: return 'Kegiatan';
      case 2: return 'Jadwal Rayon';
      case 3: return 'Rayon';
      default: return '';
    }
  }

  void _handleOpenModal([dynamic item]) {
    _fotoBase64 = null;
    if (item != null) {
      _formData = {
        'id': item['id'],
        'nama_rayon': item['nama_rayon'] ?? '',
        'keterangan': item['keterangan'] ?? '',
        'rayon_id': item['rayon_id']?.toString() ?? '',
        'title': item['title'] ?? '',
        'description': item['description'] ?? '',
        'location': item['location'] ?? '',
        'event_date': item['event_date']?.toString().split('T')[0] ?? '',
        'start_time': item['start_time'] ?? '',
        'end_time': item['end_time'] ?? '',
        'status_publish': item['status_publish'] ?? 'published',
        'category': item['category'] ?? 'Ibadah Raya Minggu',
        'day_of_week': item['day_of_week'] ?? 'Minggu',
      };
    } else {
      _formData = {
        'nama_rayon': '',
        'keterangan': '',
        'rayon_id': '',
        'title': '',
        'description': '',
        'location': '',
        'event_date': '',
        'start_time': '',
        'end_time': '',
        'status_publish': 'published',
        'category': 'Ibadah Raya Minggu',
        'day_of_week': 'Minggu',
      };
    }
    _showFormDialog();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);
    try {
      String endpoint = _getEndpoint();
      Map<String, dynamic> payload = Map<String, dynamic>.from(_formData);

      if (_tabController.index == 1 && _fotoBase64 != null) {
        payload['gambar'] = _fotoBase64;
      }

      if (_formData['id'] != null) {
        await ApiClient().post('$endpoint/${_formData['id']}/update', body: {
          ...payload,
          '_method': 'PUT'
        });
      } else {
        await ApiClient().post(endpoint, body: payload);
      }

      if (mounted) {
        Navigator.pop(context);
        _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil disimpan'), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: redAccent)
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleDelete(dynamic item) async {
    String label = item['title'] ?? item['nama_rayon'] ?? 'data ini';
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Hapus data "$label" secara permanen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: redAccent))
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        await ApiClient().delete('${_getEndpoint()}/${item['id']}');
        _fetchData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil dihapus'), backgroundColor: Colors.green));
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menghapus: $e"), backgroundColor: redAccent));
      }
    }
  }

  Future<void> _pickImage(StateSetter setModalState) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
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
            _formData['id'] == null ? 'Tambah ${_getTabTitle()}' : 'Edit ${_getTabTitle()}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: navy)
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildFieldsByTab(setModalState),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: _isSubmitting ? null : () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(backgroundColor: navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan Data', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFieldsByTab(StateSetter setModalState) {
    int idx = _tabController.index;

    if (idx == 3) { // Rayon
      return [
        _buildTextField('Nama Rayon', (v) => _formData['nama_rayon'] = v, initialValue: _formData['nama_rayon'], required: true),
        const SizedBox(height: 12),
        _buildTextField('Keterangan', (v) => _formData['keterangan'] = v, initialValue: _formData['keterangan'], maxLines: 2),
      ];
    }

    return [
      if (idx == 2) ...[ // Jadwal Rayon
        DropdownButtonFormField<String>(
          value: _rayonsList.any((r) => r['id'].toString() == _formData['rayon_id'].toString()) ? _formData['rayon_id'].toString() : null,
          decoration: const InputDecoration(labelText: 'Pilih Rayon', border: OutlineInputBorder()),
          items: _rayonsList.map((r) => DropdownMenuItem(value: r['id'].toString(), child: Text(r['nama_rayon'] ?? '-'))).toList(),
          onChanged: (v) => setModalState(() => _formData['rayon_id'] = v),
          validator: (v) => (v == null || v.isEmpty) ? 'Pilih rayon target' : null,
        ),
        const SizedBox(height: 12),
      ],
      if (idx == 0) ...[ // Ibadah
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _formData['category'],
                decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                items: ['Ibadah Raya Minggu', 'Ibadah Sekolah Minggu', 'Ibadah Pemuda & Remaja', 'Ibadah Wanita (Pelwap)', 'Doa Malam Jemaat']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 11)))).toList(),
                onChanged: (v) => setModalState(() => _formData['category'] = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _formData['day_of_week'],
                decoration: const InputDecoration(labelText: 'Hari', border: OutlineInputBorder()),
                items: ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu']
                    .map((h) => DropdownMenuItem(value: h, child: Text(h, style: const TextStyle(fontSize: 11)))).toList(),
                onChanged: (v) => setModalState(() => _formData['day_of_week'] = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
      _buildTextField('Judul / Sesi Acara', (v) => _formData['title'] = v, initialValue: _formData['title'], required: true),
      const SizedBox(height: 12),
      if (idx == 1) ...[ // Kegiatan (Tambah Upload Gambar)
        _buildImagePicker(setModalState),
        const SizedBox(height: 12),
      ],
      Row(
        children: [
          Expanded(
            child: _buildTextField(
              idx == 0 ? 'Tanggal (Opsional)' : 'Tanggal',
              (v) => _formData['event_date'] = v,
              initialValue: _formData['event_date'],
              hint: 'YYYY-MM-DD',
              required: idx != 0
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTextField('Lokasi', (v) => _formData['location'] = v, initialValue: _formData['location'], required: true),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(child: _buildTextField('Jam Mulai', (v) => _formData['start_time'] = v, initialValue: _formData['start_time'], hint: 'HH:MM', required: true)),
          const SizedBox(width: 12),
          Expanded(child: _buildTextField('Jam Selesai', (v) => _formData['end_time'] = v, initialValue: _formData['end_time'], hint: 'HH:MM')),
        ],
      ),
      if (idx != 2) ...[
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _formData['status_publish'],
          decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 'published', child: Text('Diterbitkan')),
            DropdownMenuItem(value: 'draft', child: Text('Draft')),
          ],
          onChanged: (v) => setModalState(() => _formData['status_publish'] = v),
        ),
      ],
      const SizedBox(height: 12),
      _buildTextField('Keterangan Tambahan', (v) => _formData['description'] = v, initialValue: _formData['description'], maxLines: 3),
    ];
  }

  Widget _buildTextField(String label, Function(String?) onSaved, {String? initialValue, String? hint, bool required = false, int maxLines = 1}) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.all(12),
        labelStyle: const TextStyle(fontSize: 12),
      ),
      maxLines: maxLines,
      onSaved: onSaved,
      validator: required ? (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null : null,
    );
  }

  Widget _buildImagePicker(StateSetter setModalState) {
    return InkWell(
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
                  Text('Unggah Gambar Kegiatan', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('*Maksimal 2MB', style: TextStyle(color: Colors.blueGrey, fontSize: 10)),
                ],
              ),
      ),
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
        title: const Text('Manajemen Agenda', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: navy,
          unselectedLabelColor: slate,
          indicatorColor: navy,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [Tab(text: 'IBADAH'), Tab(text: 'KEGIATAN'), Tab(text: 'JADWAL RAYON'), Tab(text: 'RAYON')],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Daftar ${_getTabTitle()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                ElevatedButton.icon(
                  onPressed: () => _handleOpenModal(),
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text('Tambah', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: navy))
                : _errorMsg.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: redAccent, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                _errorMsg,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: redAccent, fontSize: 13),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchData,
                                child: const Text('Coba Lagi'),
                              )
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchData,
                        child: _dataList.isEmpty
                            ? const Center(child: Text("Belum ada data."))
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: _dataList.length,
                                itemBuilder: (context, index) => _buildDataCard(_dataList[index]),
                              ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(dynamic item) {
    int activeIdx = _tabController.index;
    String title = activeIdx == 3 ? (item['nama_rayon'] ?? '-') : (item['title'] ?? '-');
    String sub = '-';

    try {
      if (activeIdx == 3) {
        sub = item['keterangan'] ?? '-';
      } else if (item['event_date'] != null) {
        sub = DateFormat('d MMM yyyy', 'id').format(DateTime.parse(item['event_date'].toString()));
      } else {
        sub = item['day_of_week'] ?? '-';
      }
    } catch (e) {
      sub = item['day_of_week'] ?? '-';
    }

    if (activeIdx == 0) {
      sub = "${item['category'] ?? '-'} | ${item['day_of_week']}";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: navy), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(sub, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
            if (activeIdx != 3) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 12, color: slate),
                  const SizedBox(width: 4),
                  Expanded(child: Text(item['location'] ?? '-', style: const TextStyle(fontSize: 12, color: slate), maxLines: 1)),
                ],
              ),
              if (item['status_publish'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: item['status_publish'] == 'published' ? navy.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4)
                    ),
                    child: Text(
                      item['status_publish'].toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: item['status_publish'] == 'published' ? navy : Colors.orange
                      )
                    ),
                  ),
                ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.amber, size: 22), onPressed: () => _handleOpenModal(item)),
            IconButton(icon: const Icon(Icons.delete_outline_rounded, color: redAccent, size: 22), onPressed: () => _handleDelete(item)),
          ],
        ),
      ),
    );
  }
}
