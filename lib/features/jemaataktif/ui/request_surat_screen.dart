import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'member_drawer.dart';
import 'member_bottom_navigation.dart';

class RequestSuratScreen extends StatefulWidget {
  const RequestSuratScreen({super.key});

  @override
  State<RequestSuratScreen> createState() => _RequestSuratScreenState();
}

class _RequestSuratScreenState extends State<RequestSuratScreen> {
  // Mobile consistency colors
  static const Color navy = Color(0xFF05066F);
  static const Color redAccent = Color(0xFFD71313);
  static const Color softBg = Color(0xFFF7F4FB);
  static const Color sectionGray = Color(0xFFEEEDED);

  final _formKey = GlobalKey<FormState>();

  // Form Controllers (Sesuai React)
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final dateController = TextEditingController();
  final purposeController = TextEditingController();
  final noteController = TextEditingController();
  String? selectedType;

  final List<String> suratTypes = [
    'Surat Baptis',
    'Surat Nikah',
    'Surat Keterangan Jemaat',
    'Surat Pengantar',
  ];

  final String nomorAdmin = "6281263299741";

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    dateController.dispose();
    purposeController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: navy),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitToWhatsApp() async {
    if (!_formKey.currentState!.validate() || selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi semua field wajib.")),
      );
      return;
    }

    final rawPesan = "Halo Admin, saya ingin request surat.\n\n"
        "Nama: ${nameController.text}\n"
        "No HP: ${phoneController.text}\n"
        "Jenis Surat: $selectedType\n"
        "Keperluan: ${purposeController.text}\n"
        "Tanggal Pengambilan: ${dateController.text}\n"
        "Catatan Tambahan: ${noteController.text.isEmpty ? "-" : noteController.text}";

    final uri = Uri.parse("https://wa.me/$nomorAdmin?text=${Uri.encodeComponent(rawPesan)}");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal membuka WhatsApp.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MemberDrawer(activeMenu: MemberDrawerMenu.requestSurat),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: navy),
        title: const Text(
          'Request Surat',
          style: TextStyle(color: navy, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER (Identik React) ---
            const Text(
              'Request Surat',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: navy, height: 1.1),
            ),
            const SizedBox(height: 12),
            const Text(
              'Silakan isi formulir di bawah untuk mengajukan permohonan surat.',
              style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            const Text(
              'Setelah dikirim, Anda akan diarahkan otomatis ke WhatsApp Admin Gereja.',
              style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
            ),

            // --- FORM BOX (Identik React bg-EEEDED) ---
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 32),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: sectionGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Form Permohonan Surat',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: navy),
                    ),
                    const SizedBox(height: 24),

                    _buildLabel("Nama Lengkap"),
                    _buildInput(nameController, "Masukkan nama lengkap"),

                    _buildLabel("No. HP / WhatsApp"),
                    _buildInput(phoneController, "Contoh: 08123456789", keyboardType: TextInputType.phone),

                    _buildLabel("Jenis Surat"),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: _inputDecoration(),
                      hint: const Text("Pilih jenis surat", style: TextStyle(fontSize: 14)),
                      items: suratTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 14)))).toList(),
                      onChanged: (val) => setState(() => selectedType = val),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("Rencana Tanggal Pengambilan"),
                    TextFormField(
                      controller: dateController,
                      readOnly: true,
                      onTap: _selectDate,
                      decoration: _inputDecoration(hint: "Pilih tanggal"),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("Keperluan Penggunaan Surat"),
                    _buildInput(purposeController, "Contoh: Pendaftaran sekolah"),

                    _buildLabel("Catatan Tambahan (Opsional)"),
                    _buildInput(noteController, "Tuliskan detail tambahan...", maxLines: 4),

                    const SizedBox(height: 12),
                    const Text(
                      '* Pastikan data yang diisi sudah benar. WhatsApp akan terbuka otomatis dengan format pesan yang sudah tersusun.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF6E6E6E), fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitToWhatsApp,
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                        label: const Text("Kirim via WhatsApp", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MemberBottomNavigation(currentIndex: -1),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: navy),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, {TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14),
        decoration: _inputDecoration(hint: hint),
        validator: (val) => (val == null || val.isEmpty) ? "Field ini wajib diisi" : null,
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFC9C9C9))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFC9C9C9))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: navy, width: 2)),
    );
  }
}
