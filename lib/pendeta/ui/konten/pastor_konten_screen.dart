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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);
    try {
      Map<String, dynamic> payload = Map<String, dynamic>.from(_formData);
      int? id = _formData['id'];

      if (_tabController.index == 2) {
        if (_fotoBase64 != null) payload['foto'] = _fotoBase64;
      }

      switch (_tabController.index) {
        case 0: await _contentService.saveAnnouncement(payload, id: id); break;
        case 1: await _contentService.saveDevotional(payload, id: id); break;
        case 2: await _contentService.saveGallery(payload, id: id); break;
      }
      if (mounted) { Navigator.pop(context); _fetchData(); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red));
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 24),
                  Text('Kelola ${_getTabTitle()}', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w800, color: navy)),
                  const SizedBox(height: 24),
                  ..._buildFormFields(setModalState),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(backgroundColor: navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                      child: _isSubmitting
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('PUBLIKASIKAN SEKARANG', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                    ),
                  ),
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
        _buildDropdown('Kategori Galeri', _formData['kategori'], ['Umum', 'Ibadah', 'Pemuda', 'Sekolah Minggu', 'Wanita'], (v) => setModalState(() => _formData['kategori'] = v)),
        _buildInput('Judul Foto', (v) => _formData['judul'] = v, Icons.title_rounded, initialValue: _formData['judul'], required: true),
        _buildPickerInput('Tanggal Dokumentasi', _dateController, () => _selectDate(context, setModalState)),
        const SizedBox(height: 8),
        _buildImagePicker(setModalState),
        const SizedBox(height: 16),
        _buildInput('Deskripsi Singkat', (v) => _formData['deskripsi'] = v, Icons.notes_rounded, initialValue: _formData['deskripsi'], maxLines: 3),
      ];
    }
    return [
      if (idx == 0) ...[
        _buildInput('Judul Pengumuman', (v) => _formData['judul'] = v, Icons.campaign_rounded, initialValue: _formData['judul'], required: true),
        Row(
          children: [
            Expanded(child: _buildDropdown('Target Jangkauan', _formData['scope'], ['publik', 'jemaat', 'rayon'], (v) => setModalState(() => _formData['scope'] = v))),
            if (_formData['scope'] == 'rayon') ...[
              const SizedBox(width: 12),
              Expanded(child: _buildDropdown('Pilih Rayon', _formData['id_rayon'], _rayonList.map((e) => e['id'].toString()).toList(), (v) => setModalState(() => _formData['id_rayon'] = v), labels: _rayonList.map((e) => e['nama_rayon'].toString()).toList())),
            ]
          ],
        ),
      ] else ...[
        _buildInput('Tema Renungan', (v) => _formData['tema'] = v, Icons.auto_stories_rounded, initialValue: _formData['tema'], required: true),
        _buildInput('Ayat Pokok Alkitab', (v) => _formData['ayat_pokok'] = v, Icons.menu_book_rounded, initialValue: _formData['ayat_pokok'], required: true),
      ],
      _buildInput('Isi Konten / Pesan Utama', (v) => _formData['isi'] = v, Icons.article_rounded, initialValue: _formData['isi'], maxLines: 6, required: true),
      _buildDropdown('Status Publikasi', _formData['status'], ['Aktif', 'Tidak Aktif'], (v) => setModalState(() => _formData['status'] = v)),
    ];
  }

  Widget _buildInput(String label, Function(String?) onSaved, IconData icon, {String? initialValue, bool required = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w800, color: textGrey)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: initialValue,
            maxLines: maxLines,
            style: GoogleFonts.montserrat(fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: navy, size: 20),
              filled: true, fillColor: softBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            validator: required ? (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null : null,
            onSaved: onSaved,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, Function(String?) onChanged, {List<String>? labels}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w800, color: textGrey)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: (value == null || value.isEmpty || !items.contains(value)) ? null : value,
            isExpanded: true,
            style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black),
            decoration: InputDecoration(filled: true, fillColor: softBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            items: List.generate(items.length, (i) => DropdownMenuItem(value: items[i], child: Text(labels != null ? labels[i] : items[i]))),
            onChanged: onChanged,
            validator: (v) => v == null ? 'Pilih satu' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(StateSetter setModalState) {
    return GestureDetector(
      onTap: () => _pickImage(setModalState),
      child: Container(
        height: 160, width: double.infinity,
        decoration: BoxDecoration(color: softBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid)),
        child: _fotoBase64 != null
          ? ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.memory(base64Decode(_fotoBase64!), fit: BoxFit.cover))
          : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_photo_alternate_rounded, color: navy.withOpacity(0.5), size: 48), const SizedBox(height: 8), Text('Unggah Foto Galeri', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: textGrey))]),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, StateSetter setModalState) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2101));
    if (picked != null) setModalState(() { _dateController.text = DateFormat('yyyy-MM-dd').format(picked); _formData['tanggal_kegiatan'] = _dateController.text; });
  }

  Widget _buildPickerInput(String label, TextEditingController controller, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w800, color: textGrey)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller, readOnly: true, onTap: onTap,
            style: GoogleFonts.montserrat(fontSize: 14),
            decoration: InputDecoration(prefixIcon: const Icon(Icons.calendar_today_rounded, color: navy, size: 20), filled: true, fillColor: softBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(StateSetter setModalState) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) { final bytes = await pickedFile.readAsBytes(); setModalState(() { _fotoBase64 = base64Encode(bytes); }); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        title: Text('Konten Publikasi', style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: navy, fontSize: 18)),
        backgroundColor: Colors.white, elevation: 0, scrolledUnderElevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: navy, unselectedLabelColor: textGrey,
          indicatorColor: gold, indicatorWeight: 3,
          labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 13),
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
                    onRefresh: _fetchData, color: navy,
                    child: _dataList.isEmpty ? _buildEmptyState() : (_tabController.index == 2 ? _buildGalleryGrid() : _buildContentList()),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionHeader() {
    return Container(
      padding: const EdgeInsets.all(20), color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Manajemen ${_getTabTitle()}', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w800, color: navy)),
            Text('Terakhir diperbarui: ${DateFormat('dd MMM').format(DateTime.now())}', style: GoogleFonts.montserrat(fontSize: 11, color: textGrey, fontWeight: FontWeight.w500)),
          ]),
          ElevatedButton.icon(
            onPressed: () => _handleOpenModal(),
            icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Buat Konten'),
            style: ElevatedButton.styleFrom(backgroundColor: navy, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ],
      ),
    );
  }

  Widget _buildContentList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _dataList.length,
      itemBuilder: (context, index) {
        final item = _dataList[index];
        bool isActive = item['status'] == 'Aktif';
        String title = item['judul'] ?? item['tema'] ?? '-';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 14, color: navy)),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 8),
              Text(item['isi'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.montserrat(fontSize: 12, color: Colors.black54, height: 1.5)),
              const SizedBox(height: 12),
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: (item['scope'] == 'publik' ? Colors.blue : gold).withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(item['scope']?.toUpperCase() ?? 'PUBLIK', style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.w900, color: item['scope'] == 'publik' ? Colors.blue : gold))),
                const SizedBox(width: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(isActive ? 'AKTIF' : 'NONAKTIF', style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.w900, color: isActive ? Colors.green : Colors.red))),
              ]),
            ]),
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert_rounded, color: textGrey),
              onSelected: (v) { if (v == 'edit') _handleOpenModal(item); if (v == 'delete') _handleDelete(item); },
              itemBuilder: (c) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_rounded, size: 18, color: Colors.orange), SizedBox(width: 12), Text('Edit')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red), SizedBox(width: 12), Text('Hapus', style: TextStyle(color: Colors.red))])),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGalleryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.75),
      itemCount: _dataList.length,
      itemBuilder: (context, index) {
        final item = _dataList[index];
        return Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: Image.network(ApiConstants.getImageUrl(item['path_foto'] ?? ''), width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: softBg, child: const Icon(Icons.image_not_supported_rounded, color: textGrey))))),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item['judul'] ?? '-', style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 12, color: navy), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(item['kategori'] ?? 'Umum', style: GoogleFonts.montserrat(fontSize: 10, color: gold, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  GestureDetector(onTap: () => _handleOpenModal(item), child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.edit_rounded, size: 14, color: Colors.orange))),
                  GestureDetector(onTap: () => _handleDelete(item), child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.delete_outline_rounded, size: 14, color: Colors.red))),
                ])
              ]),
            )
          ]),
        );
      },
    );
  }

  Future<void> _handleDelete(dynamic item) async {
    bool confirm = await showDialog(context: context, builder: (context) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: Text('Hapus Konten?', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: navy)), content: const Text('Data akan dihapus permanen dari aplikasi jemaat.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal', style: GoogleFonts.montserrat(color: textGrey, fontWeight: FontWeight.bold))), TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Hapus', style: GoogleFonts.montserrat(color: Colors.red, fontWeight: FontWeight.bold)))])) ?? false;
    if (confirm) {
      try {
        int id = item['id'];
        switch (_tabController.index) {
          case 0: await _contentService.deleteAnnouncement(id); break;
          case 1: await _contentService.deleteDevotional(id); break;
          case 2: await _contentService.deleteGallery(id); break;
        }
        _fetchData();
      } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e"))); }
    }
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.auto_awesome_motion_rounded, size: 64, color: textGrey.withOpacity(0.2)), const SizedBox(height: 16), Text('Belum ada konten ${_getTabTitle()}', style: GoogleFonts.montserrat(color: textGrey, fontWeight: FontWeight.w600))]));
  }

  String _getTabTitle() {
    if (_tabController.index == 0) return 'Pengumuman';
    if (_tabController.index == 1) return 'Renungan';
    return 'Galeri Foto';
  }
}
