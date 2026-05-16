import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../features/jemaataktif/services/event_service.dart';

class PastorAgendaScreen extends StatefulWidget {
  const PastorAgendaScreen({super.key});

  @override
  State<PastorAgendaScreen> createState() => _PastorAgendaScreenState();
}

class _PastorAgendaScreenState extends State<PastorAgendaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EventService _eventService = EventService();

  bool _isLoading = false;
  List<dynamic> _dataList = [];
  List<dynamic> _rayonsList = [];
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {};
  String? _fotoBase64;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F9FE);
  static const Color textGrey = Color(0xFF7A7C92);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _fetchData();
    });
    _fetchRayonsDropdown();
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _fetchRayonsDropdown() async {
    try {
      final res = await _eventService.getRayons();
      if (mounted) setState(() => _rayonsList = res);
    } catch (e) {
      debugPrint("Gagal muat dropdown rayon: $e");
    }
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      List<dynamic> data = [];
      switch (_tabController.index) {
        case 0: data = await _eventService.getAdminWorship(); break;
        case 1: data = await _eventService.getAdminActivity(); break;
        case 2: data = await _eventService.getManageRayonSchedules(); break;
        case 3: data = await _eventService.getRayons(); break;
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
        'nama_rayon': item['nama_rayon'] ?? '',
        'keterangan': item['keterangan'] ?? '',
        'rayon_id': item['rayon_id']?.toString() ?? '',
        'title': item['title'] ?? '',
        'description': item['description'] ?? '',
        'location': item['location'] ?? '',
        'event_date': item['event_date'] != null ? item['event_date'].toString().split('T')[0] : '',
        'start_time': item['start_time'] ?? '',
        'end_time': item['end_time'] ?? '',
        'status_publish': item['status_publish'] ?? 'published',
        'category': item['category'] ?? 'Ibadah Raya Minggu',
        'day_of_week': item['day_of_week'] ?? 'Minggu',
      };
    } else {
      _formData = {
        'nama_rayon': '', 'keterangan': '', 'rayon_id': '', 'title': '', 'description': '', 'location': '',
        'event_date': '', 'start_time': '', 'end_time': '',
        'status_publish': 'published', 'category': 'Ibadah Raya Minggu', 'day_of_week': 'Minggu',
      };
    }
    _dateController.text = _formData['event_date'] ?? '';
    _startTimeController.text = _formData['start_time'] ?? '';
    _endTimeController.text = _formData['end_time'] ?? '';
    _showFormDialog();
  }

  Future<void> _pickImage(StateSetter setModalState) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setModalState(() {
        _fotoBase64 = 'data:image/png;base64,${base64Encode(bytes)}';
      });
    }
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
        _formData['event_date'] = _dateController.text;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller, String key, StateSetter setModalState) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setModalState(() {
        final now = DateTime.now();
        final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
        controller.text = DateFormat('HH:mm').format(dt);
        _formData[key] = controller.text;
      });
    }
  }

  Future<void> _handleSubmit(StateSetter setModalState) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setModalState(() => _isSubmitting = true);
    setState(() => _isSubmitting = true);

    try {
      Map<String, dynamic> payload = Map<String, dynamic>.from(_formData);
      if (_tabController.index == 1 && _fotoBase64 != null) payload['gambar'] = _fotoBase64;

      int? id = _formData['id'];
      switch (_tabController.index) {
        case 0: await _eventService.saveWorship(payload, id: id); break;
        case 1: await _eventService.saveActivity(payload, id: id); break;
        case 2: await _eventService.saveRayonSchedule(payload, id: id); break;
        case 3: await _eventService.saveRayon(payload, id: id); break;
      }
      if (mounted) { Navigator.pop(context); _fetchData(); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) {
        setModalState(() => _isSubmitting = false);
        setState(() => _isSubmitting = false);
      }
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Form ${_getTabTitle()}', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: navy)),
                const SizedBox(height: 20),
                Form(key: _formKey, child: Column(children: _buildFieldsByTab(setModalState))),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _handleSubmit(setModalState),
                    style: ElevatedButton.styleFrom(backgroundColor: navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('SIMPAN DATA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: textGrey))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFieldsByTab(StateSetter setModalState) {
    int idx = _tabController.index;
    if (idx == 3) {
      return [
        _buildInput('Nama Rayon', (v) => _formData['nama_rayon'] = v, Icons.groups, initialValue: _formData['nama_rayon'], required: true),
        _buildInput('Keterangan', (v) => _formData['keterangan'] = v, Icons.info, initialValue: _formData['keterangan'], maxLines: 3),
      ];
    }
    if (idx == 0) {
      return [
        _buildDropdown('Kategori Ibadah', _formData['category'], [
          'Ibadah Raya Minggu',
          'Ibadah Sekolah Minggu',
          'Ibadah Pemuda & Remaja',
          'Ibadah Wanita (Pelwap)',
          'Doa Malam Jemaat'
        ], (v) => setModalState(() => _formData['category'] = v)),
        _buildDropdown('Hari Pelaksanaan', _formData['day_of_week'], ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'], (v) => setModalState(() => _formData['day_of_week'] = v)),
        _buildInput('Judul Ibadah / Sesi', (v) => _formData['title'] = v, Icons.title, initialValue: _formData['title'], required: true),
        _buildPickerInput('Tanggal (Opsional)', _dateController, () => _selectDate(context, setModalState), required: false),
        Row(
          children: [
            Expanded(child: _buildPickerInput('Jam Mulai', _startTimeController, () => _selectTime(context, _startTimeController, 'start_time', setModalState))),
            const SizedBox(width: 12),
            Expanded(child: _buildPickerInput('Jam Selesai', _endTimeController, () => _selectTime(context, _endTimeController, 'end_time', setModalState), required: false)),
          ],
        ),
        _buildInput('Lokasi', (v) => _formData['location'] = v, Icons.location_on, initialValue: _formData['location'], required: true),
        _buildDropdown('Status Publish', _formData['status_publish'], ['published', 'draft'], (v) => setModalState(() => _formData['status_publish'] = v)),
        _buildInput('Keterangan Tambahan', (v) => _formData['description'] = v, Icons.info_outline, initialValue: _formData['description'], maxLines: 2),
      ];
    }
    if (idx == 1) {
      return [
        _buildInput('Judul Acara / Kegiatan', (v) => _formData['title'] = v, Icons.event_note, initialValue: _formData['title'], required: true),
        _buildPickerInput('Tanggal Kegiatan', _dateController, () => _selectDate(context, setModalState)),
        Row(
          children: [
            Expanded(child: _buildPickerInput('Jam Mulai', _startTimeController, () => _selectTime(context, _startTimeController, 'start_time', setModalState))),
            const SizedBox(width: 12),
            Expanded(child: _buildPickerInput('Jam Selesai', _endTimeController, () => _selectTime(context, _endTimeController, 'end_time', setModalState), required: false)),
          ],
        ),
        _buildInput('Lokasi', (v) => _formData['location'] = v, Icons.location_on, initialValue: _formData['location'], required: true),
        _buildInput('Deskripsi Kegiatan', (v) => _formData['description'] = v, Icons.description, initialValue: _formData['description'], maxLines: 3),
        const SizedBox(height: 12),
        _buildImagePicker(setModalState),
        _buildDropdown('Status Publish', _formData['status_publish'], ['published', 'draft'], (v) => setModalState(() => _formData['status_publish'] = v)),
      ];
    }
    return [
      _buildDropdown('Pilih Rayon Target', _formData['rayon_id'], _rayonsList.map((e) => e['id'].toString()).toList(), (v) => setModalState(() => _formData['rayon_id'] = v), labels: _rayonsList.map((e) => e['nama_rayon'].toString()).toList()),
      _buildInput('Judul Kegiatan Rayon', (v) => _formData['title'] = v, Icons.title, initialValue: _formData['title'], required: true),
      _buildPickerInput('Tanggal', _dateController, () => _selectDate(context, setModalState)),
      Row(
        children: [
          Expanded(child: _buildPickerInput('Jam Mulai', _startTimeController, () => _selectTime(context, _startTimeController, 'start_time', setModalState))),
          const SizedBox(width: 12),
          Expanded(child: _buildPickerInput('Jam Selesai', _endTimeController, () => _selectTime(context, _endTimeController, 'end_time', setModalState), required: false)),
        ],
      ),
      _buildInput('Lokasi / Alamat', (v) => _formData['location'] = v, Icons.location_on, initialValue: _formData['location']),
      _buildInput('Keterangan Tambahan', (v) => _formData['description'] = v, Icons.info_outline, initialValue: _formData['description'], maxLines: 2),
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

  Widget _buildPickerInput(String label, TextEditingController controller, VoidCallback onTap, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.calendar_today, color: navy), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        validator: required ? (v) => (v == null || v.isEmpty) ? 'Wajib' : null : null,
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
        validator: (v) => v == null ? 'Pilih salah satu' : null,
      ),
    );
  }

  Widget _buildImagePicker(StateSetter setModalState) {
    return GestureDetector(
      onTap: () => _pickImage(setModalState),
      child: Container(
        height: 120, width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: softBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
        child: _fotoBase64 != null
          ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(base64Decode(_fotoBase64!.split(',').last), fit: BoxFit.cover))
          : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, color: navy), Text('Pilih Foto Kegiatan', style: TextStyle(fontSize: 12))]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBg,
      appBar: AppBar(
        title: Text('Manajemen Agenda', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: navy, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: navy, unselectedLabelColor: textGrey,
          indicatorColor: gold,
          tabs: const [Tab(text: 'IBADAH'), Tab(text: 'KEGIATAN'), Tab(text: 'JADWAL RAYON'), Tab(text: 'RAYON')],
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
                        : ListView.builder(
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

  Widget _buildActionHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Daftar ${_getTabTitle()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: navy)),
            const Text('Kelola operasional gereja', style: TextStyle(fontSize: 12, color: textGrey)),
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

  Widget _buildDataCard(dynamic item) {
    String title = item['title'] ?? item['nama_rayon'] ?? '-';
    String sub = item['location'] ?? item['description'] ?? item['keterangan'] ?? '';
    if (_tabController.index == 0) sub = "${item['day_of_week'] ?? ''} - ${item['start_time'] ?? ''}";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: navy.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(_getTabIcon(), color: navy),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.edit_outlined, color: Colors.orange, size: 20), onPressed: () => _handleOpenModal(item)),
            IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => _handleDelete(item)),
          ],
        ),
      ),
    );
  }

  IconData _getTabIcon() {
    switch (_tabController.index) {
      case 0: return Icons.church;
      case 1: return Icons.event;
      case 2: return Icons.calendar_month;
      default: return Icons.groups;
    }
  }

  Future<void> _handleDelete(dynamic item) async {
    int id = item['id'];
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data?'),
        content: const Text('Data ini akan dihapus secara permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;
    if (confirm) {
      try {
        switch (_tabController.index) {
          case 0: await _eventService.deleteWorship(id); break;
          case 1: await _eventService.deleteActivity(id); break;
          case 2: await _eventService.deleteRayonSchedule(id); break;
          case 3: await _eventService.deleteRayon(id); break;
        }
        _fetchData();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal hapus: $e")));
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade300),
      const SizedBox(height: 10),
      Text('Belum ada data ${_getTabTitle()}', style: TextStyle(color: Colors.grey.shade500)),
    ]));
  }

  String _getTabTitle() {
    switch (_tabController.index) {
      case 0: return 'Ibadah';
      case 1: return 'Kegiatan';
      case 2: return 'Jadwal Rayon';
      default: return 'Rayon';
    }
  }
}