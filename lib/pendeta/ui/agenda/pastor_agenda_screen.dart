import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  // Form States
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {};

  static const Color navy = Color(0xFF05066F);
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

  Future<void> _fetchRayonsDropdown() async {
    try {
      final res = await ApiClient().get(ApiConstants.rayons);
      if (mounted) {
        setState(() {
          _rayonsList = res is List ? res : (res['data'] ?? []);
        });
      }
    } catch (e) {
      debugPrint("Gagal memuat dropdown rayon: $e");
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
        case 0: endpoint = ApiConstants.worshipSchedules; break;
        case 1: endpoint = ApiConstants.activitySchedules; break;
        case 2: endpoint = ApiConstants.rayonSchedules; break;
        case 3: endpoint = ApiConstants.rayons; break;
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
          _errorMsg = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _handleOpenModal([dynamic item]) {
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
        'gambar': null,
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
        'gambar': null,
      };
    }
    _showFormDialog();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);
    try {
      String endpoint = '';
      int? editId = _formData['id'];

      switch (_tabController.index) {
        case 0: endpoint = ApiConstants.worshipSchedules; break;
        case 1: endpoint = ApiConstants.activitySchedules; break;
        case 2: endpoint = ApiConstants.rayonSchedules; break;
        case 3: endpoint = ApiConstants.rayons; break;
      }

      if (editId != null) {
        await ApiClient().post('$endpoint/$editId/update', body: _formData);
      } else {
        await ApiClient().post(endpoint, body: _formData);
      }

      if (_tabController.index == 3) _fetchRayonsDropdown();
      if (mounted) {
        Navigator.pop(context);
        _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil disimpan')));
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
    String label = item['nama_rayon'] ?? item['title'] ?? 'data';
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

    if (confirm == true) {
      try {
        String endpoint = '';
        switch (_tabController.index) {
          case 0: endpoint = ApiConstants.worshipSchedules; break;
          case 1: endpoint = ApiConstants.activitySchedules; break;
          case 2: endpoint = ApiConstants.rayonSchedules; break;
          case 3: endpoint = ApiConstants.rayons; break;
        }
        await ApiClient().delete('$endpoint/${item['id']}');
        _fetchData();
        if (_tabController.index == 3) _fetchRayonsDropdown();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
        }
      }
    }
  }

  Future<void> _handleImageUpload(StateSetter setModalState) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (image != null) {
      final bytes = await image.readAsBytes();
      final String base64Image = 'data:image/${image.path.split('.').last};base64,${base64Encode(bytes)}';
      setModalState(() {
        _formData['gambar'] = base64Image;
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600]),
              child: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan Data'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormFields(StateSetter setModalState) {
    int activeIdx = _tabController.index;
    if (activeIdx == 3) { // Rayon
      return [
        _buildTextField('Nama Rayon', (v) => _formData['nama_rayon'] = v, initialValue: _formData['nama_rayon'], required: true),
        const SizedBox(height: 12),
        _buildTextField('Keterangan', (v) => _formData['keterangan'] = v, initialValue: _formData['keterangan'], maxLines: 3),
      ];
    }

    return [
      if (activeIdx == 2) ...[ // Jadwal Rayon
        DropdownButtonFormField<String>(
          value: _rayonsList.any((r) => r['id'].toString() == _formData['rayon_id']) ? _formData['rayon_id'] : null,
          decoration: const InputDecoration(labelText: 'Pilih Rayon'),
          items: _rayonsList.map((r) => DropdownMenuItem(value: r['id'].toString(), child: Text(r['nama_rayon']))).toList(),
          onChanged: (v) => setModalState(() => _formData['rayon_id'] = v),
          validator: (v) => v == null ? 'Wajib pilih rayon' : null,
        ),
        const SizedBox(height: 12),
      ],
      if (activeIdx == 0) ...[ // Ibadah
        DropdownButtonFormField<String>(
          value: _formData['category'],
          decoration: const InputDecoration(labelText: 'Kategori'),
          items: ['Ibadah Raya Minggu', 'Ibadah Sekolah Minggu', 'Ibadah Pemuda & Remaja', 'Ibadah Wanita (Pelwap)', 'Doa Malam Jemaat']
              .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setModalState(() => _formData['category'] = v),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _formData['day_of_week'],
          decoration: const InputDecoration(labelText: 'Hari Pelaksanaan'),
          items: ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu']
              .map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
          onChanged: (v) => setModalState(() => _formData['day_of_week'] = v),
        ),
        const SizedBox(height: 12),
      ],
      _buildTextField('Judul / Sesi Acara', (v) => _formData['title'] = v, initialValue: _formData['title'], required: true),
      if (activeIdx == 1) ...[ // Kegiatan
        const SizedBox(height: 12),
        _buildImagePicker(setModalState),
      ],
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(child: _buildTextField(activeIdx == 0 ? 'Tanggal (Opsional)' : 'Tanggal', (v) => _formData['event_date'] = v, initialValue: _formData['event_date'], hint: 'YYYY-MM-DD', required: activeIdx != 0)),
          const SizedBox(width: 12),
          Expanded(child: _buildTextField('Lokasi', (v) => _formData['location'] = v, initialValue: _formData['location'], required: true)),
        ],
      ),
      Row(
        children: [
          Expanded(child: _buildTextField('Mulai', (v) => _formData['start_time'] = v, initialValue: _formData['start_time'], hint: 'HH:MM', required: true)),
          const SizedBox(width: 12),
          Expanded(child: _buildTextField('Selesai', (v) => _formData['end_time'] = v, initialValue: _formData['end_time'], hint: 'HH:MM')),
        ],
      ),
      if (activeIdx != 2) ...[
        DropdownButtonFormField<String>(
          value: _formData['status_publish'],
          decoration: const InputDecoration(labelText: 'Status'),
          items: const [DropdownMenuItem(value: 'published', child: Text('Diterbitkan')), DropdownMenuItem(value: 'draft', child: Text('Draft'))],
          onChanged: (v) => setModalState(() => _formData['status_publish'] = v),
        ),
        const SizedBox(height: 12),
      ],
      _buildTextField('Keterangan Tambahan', (v) => _formData['description'] = v, initialValue: _formData['description'], maxLines: 2),
    ];
  }

  Widget _buildTextField(String label, Function(String?) onSaved, {String? initialValue, String? hint, bool required = false, int maxLines = 1}) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(labelText: label, hintText: hint, contentPadding: const EdgeInsets.symmetric(vertical: 8)),
      maxLines: maxLines,
      validator: required ? (v) => v!.isEmpty ? 'Wajib diisi' : null : null,
      onSaved: onSaved,
    );
  }

  Widget _buildImagePicker(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Foto Kegiatan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: slate)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _handleImageUpload(setModalState),
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue[100]!)),
            child: _formData['gambar'] != null
                ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(base64Decode(_formData['gambar'].split(',').last), fit: BoxFit.cover))
                : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_rounded, color: Colors.blue), Text('Upload Foto', style: TextStyle(color: Colors.blue, fontSize: 12))]),
          ),
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
            Text('Manajemen Event & Rayon', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Kelola seluruh agenda gereja secara terpusat.', style: TextStyle(color: slate, fontSize: 12)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: navy,
          unselectedLabelColor: slate,
          indicatorColor: navy,
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
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah Data', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600], minimumSize: const Size(0, 40), padding: const EdgeInsets.symmetric(horizontal: 16)),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: navy))
                : _dataList.isEmpty
                    ? Center(child: Text('Belum ada data.', style: const TextStyle(color: slate)))
                    : RefreshIndicator(
                        onRefresh: _fetchData,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _dataList.length,
                          itemBuilder: (context, index) => _buildDataCard(_dataList[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
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

  Widget _buildDataCard(dynamic item) {
    int activeIdx = _tabController.index;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: activeIdx == 3
            ? Text(item['nama_rayon'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (activeIdx == 0 && item['category'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        item['category'],
                        style: TextStyle(color: Colors.blue[800], fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  Text(item['title'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (activeIdx == 3) Text(item['keterangan'] ?? '-', maxLines: 2, overflow: TextOverflow.ellipsis),
              if (activeIdx != 3) ...[
                Row(children: [const Icon(Icons.calendar_today, size: 12, color: slate), const SizedBox(width: 4), Text(item['event_date'] ?? item['day_of_week'] ?? '-', style: const TextStyle(fontSize: 12))]),
                const SizedBox(height: 4),
                Row(children: [const Icon(Icons.access_time, size: 12, color: slate), const SizedBox(width: 4), Text('${item['start_time']} - ${item['end_time'] ?? 'Selesai'}', style: const TextStyle(fontSize: 12))]),
                const SizedBox(height: 4),
                Row(children: [const Icon(Icons.location_on_outlined, size: 12, color: slate), const SizedBox(width: 4), Expanded(child: Text(item['location'] ?? '-', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))]),
                if (activeIdx != 2) ...[
                  const SizedBox(height: 4),
                  Text(item['status_publish']?.toString().toUpperCase() ?? '', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: navy)),
                ],
              ],
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.amber, size: 20),
              onPressed: () => _handleOpenModal(item),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: () => _handleDelete(item),
            ),
          ],
        ),
      ),
    );
  }
}
