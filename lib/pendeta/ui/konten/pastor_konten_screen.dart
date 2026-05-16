import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/api_constants.dart';
import '../../../features/jemaatpublik/services/content_service.dart';
import '../../../features/jemaataktif/services/event_service.dart';

class PastorKontenScreen extends StatefulWidget {
  const PastorKontenScreen({super.key});

  @override
  State<PastorKontenScreen> createState() => _PastorKontenScreenState();
}

class _PastorKontenScreenState extends State<PastorKontenScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ContentService _contentService = ContentService();
  final EventService _eventService = EventService();

  bool _isLoading = false;
  List<dynamic> _dataList = [];
  List<dynamic> _rayonList = [];
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {};
  String? _fotoBase64;

  final TextEditingController _dateController = TextEditingController();

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F9FE);
  static const Color textGrey = Color(0xFF7A7C92);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _fetchData();
    });
    _fetchRayons();
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _fetchRayons() async {
    try {
      final res = await _eventService.getRayons();
      if (mounted) setState(() => _rayonList = res);
    } catch (e) {
      debugPrint("Gagal muat rayon: $e");
    }
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      List<dynamic> data = [];
      switch (_tabController.index) {
        case 0: data = await _contentService.getAdminAnnouncements(); break;
        case 1: data = await _contentService.getAdminDevotionals(); break;
        case 2: data = await _contentService.getAdminGallery(); break;
      }
      if (mounted) setState(() { _dataList = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
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
        'tanggal_kegiatan': item['tanggal_kegiatan'] != null ? item['tanggal_kegiatan'].toString().split('T')[0] : '',
        'kategori': item['kategori'] ?? 'Umum',
        'isi': item['isi'] ?? '',
        'status': item['status'] ?? 'Aktif',
      };
    } else {
      _formData = {
        'judul': '', 'scope': 'publik', 'id_rayon': '', 'tema': '', 'ayat_pokok': '',
        'deskripsi': '', 'tanggal_kegiatan': '', 'kategori': 'Umum', 'isi': '', 'status': 'Aktif'
      };
    }
    _dateController.text = _formData['tanggal_kegiatan'] ?? '';
    _showFormDialog();
  }

  Future<void> _selectDate(BuildContext context, StateSetter setModalState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setModalState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
        _formData['tanggal_kegiatan'] = _dateController.text;
      });
    }
  }

  Future<void> _pickImage(StateSetter setModalState) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setModalState(() {
        _fotoBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_tabController.index == 0 && _formData['scope'] == 'rayon' && (_formData['id_rayon'] == null || _formData['id_rayon'].isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih rayon target!')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      Map<String, dynamic> payload = Map<String, dynamic>.from(_formData);
      int? id = _formData['id'];

      if (_tabController.index == 2) {
        if (_fotoBase64 != null) payload['foto'] = _fotoBase64;
        if (id == null && _fotoBase64 == null) throw "Wajib mengunggah foto untuk galeri baru!";
      }

      switch (_tabController.index) {
        case 0: await _contentService.saveAnnouncement(payload, id: id); break;
        case 1: await _contentService.saveDevotional(payload, id: id); break;
        case 2: await _contentService.saveGallery(payload, id: id); break;
      }
      if (mounted) { Navigator.pop(context); _fetchData(); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showFormDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Form ${_getTabTitle()}', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: navy)),
                  const SizedBox(height: 20),
                  ..._buildFormFields(setModalState),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(backgroundColor: navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('SIMPAN KONTEN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: textGrey))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields(StateSetter setModalState) {
    int idx = _tabController.index;
    if (idx == 2) { // GALERI
      return [
        _buildDropdown('Kategori Kegiatan', _formData['kategori'], ['Umum', 'Ibadah', 'Pemuda', 'Sekolah Minggu', 'Wanita'], (v) => setModalState(() => _formData['kategori'] = v)),
        _buildInput('Judul Foto', (v) => _formData['judul'] = v, Icons.title, initialValue: _formData['judul'], required: true),
        _buildPickerInput('Tanggal Kegiatan', _dateController, () => _selectDate(context, setModalState)),
        const SizedBox(height: 12),
        _buildImagePicker(setModalState),
        _buildInput('Deskripsi Singkat', (v) => _formData['deskripsi'] = v, Icons.description, initialValue: _formData['deskripsi'], maxLines: 3),
      ];
    }
    return [
      if (idx == 0) ...[
        _buildInput('Judul Pengumuman', (v) => _formData['judul'] = v, Icons.campaign, initialValue: _formData['judul'], required: true),
        Row(
          children: [
            Expanded(child: _buildDropdown('Target Audiens', _formData['scope'], ['publik', 'jemaat', 'rayon'], (v) => setModalState(() => _formData['scope'] = v))),
            if (_formData['scope'] == 'rayon') ...[
              const SizedBox(width: 12),
              Expanded(child: _buildDropdown('Pilih Rayon', _formData['id_rayon'], _rayonList.map((e) => e['id'].toString()).toList(), (v) => setModalState(() => _formData['id_rayon'] = v), labels: _rayonList.map((e) => e['nama_rayon'].toString()).toList())),
            ]
          ],
        ),
      ] else ...[
        _buildInput('Tema Renungan', (v) => _formData['tema'] = v, Icons.book, initialValue: _formData['tema'], required: true),
        _buildInput('Ayat Pokok', (v) => _formData['ayat_pokok'] = v, Icons.menu_book, initialValue: _formData['ayat_pokok'], required: true),
      ],
      _buildInput('Isi Konten', (v) => _formData['isi'] = v, Icons.article, initialValue: _formData['isi'], maxLines: 5, required: true),
      _buildDropdown('Status Visibilitas', _formData['status'], ['Aktif', 'Tidak Aktif'], (v) => setModalState(() => _formData['status'] = v)),
    ];
  }

  Widget _buildInput(String label, Function(String?) onSaved, IconData icon, {String? initialValue, bool required = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: navy), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        validator: required ? (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null : null,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildPickerInput(String label, TextEditingController controller, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.calendar_today, color: navy), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        validator: (v) => (v == null || v.isEmpty) ? 'Wajib' : null,
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged, {List<String>? labels}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: (value == null || value.isEmpty || !items.contains(value)) ? null : value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        items: List.generate(items.length, (i) => DropdownMenuItem(value: items[i], child: Text(labels != null ? labels[i] : items[i]))),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Wajib' : null,
      ),
    );
  }

  Widget _buildImagePicker(StateSetter setModalState) {
    return GestureDetector(
      onTap: () => _pickImage(setModalState),
      child: Container(
        height: 140, width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: softBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
        child: _fotoBase64 != null
          ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(base64Decode(_fotoBase64!), fit: BoxFit.cover))
          : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, color: navy, size: 32), Text('Pilih Foto Galeri', style: TextStyle(fontSize: 12))]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        title: Text('Konten & Publikasi', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: navy, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: navy, unselectedLabelColor: textGrey,
          indicatorColor: gold,
          tabs: const [Tab(text: 'PENGUMUMAN'), Tab(text: 'RENUNGAN'), Tab(text: 'GALERI')],
        ),
      ),
      body: Column(
        children: [
          _buildActionHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: navy))
                : RefreshIndicator(
                    onRefresh: _fetchData,
                    color: navy,
                    child: _dataList.isEmpty
                        ? _buildEmptyState()
                        : (_tabController.index == 2 ? _buildGalleryGrid() : _buildContentList()),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Daftar ${_getTabTitle()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navy)),
            const Text('Media komunikasi jemaat', style: TextStyle(fontSize: 12, color: textGrey)),
          ]),
          ElevatedButton.icon(
            onPressed: () => _handleOpenModal(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Tambah'),
            style: ElevatedButton.styleFrom(backgroundColor: navy, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ],
      ),
    );
  }

  Widget _buildContentList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _dataList.length,
      itemBuilder: (context, index) {
        final item = _dataList[index];
        bool isActive = item['status'] == 'Aktif';
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              children: [
                Expanded(child: Text(item['judul'] ?? item['tema'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                  child: Text(item['status'] ?? 'Aktif', style: TextStyle(fontSize: 10, color: isActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(item['isi'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                if (item['scope'] != null) ...[
                  const SizedBox(height: 8),
                  Text('Audiens: ${item['scope'].toString().toUpperCase()}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: gold)),
                ]
              ],
            ),
            trailing: PopupMenuButton(
              onSelected: (v) {
                if (v == 'edit') _handleOpenModal(item);
                if (v == 'delete') _handleDelete(item);
              },
              itemBuilder: (c) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))])),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGalleryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.8),
      itemCount: _dataList.length,
      itemBuilder: (context, index) {
        final item = _dataList[index];
        return Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    ApiConstants.getImageUrl(item['path_foto'] ?? ''),
                    width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['judul'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(item['kategori'] ?? 'Umum', style: const TextStyle(fontSize: 10, color: gold, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(onTap: () => _handleOpenModal(item), child: const Icon(Icons.edit, size: 16, color: Colors.orange)),
                        const SizedBox(width: 12),
                        GestureDetector(onTap: () => _handleDelete(item), child: const Icon(Icons.delete, size: 16, color: Colors.red)),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleDelete(dynamic item) async {
    int id = item['id'];
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Konten?'),
        content: const Text('Data ini akan dihapus permanen dari publikasi.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;
    if (confirm) {
      try {
        switch (_tabController.index) {
          case 0: await _contentService.deleteAnnouncement(id); break;
          case 1: await _contentService.deleteDevotional(id); break;
          case 2: await _contentService.deleteGallery(id); break;
        }
        _fetchData();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.auto_stories_outlined, size: 60, color: Colors.grey.shade300),
      const SizedBox(height: 10),
      Text('Belum ada konten ${_getTabTitle()}', style: TextStyle(color: Colors.grey.shade500)),
    ]));
  }

  String _getTabTitle() {
    if (_tabController.index == 0) return 'Pengumuman';
    if (_tabController.index == 1) return 'Renungan';
    return 'Galeri';
  }
}
