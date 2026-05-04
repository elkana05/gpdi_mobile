import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../auth/providers/auth_provider.dart';
import 'member_drawer.dart';
import 'member_bottom_navigation.dart';

class RequestSuratScreen extends StatefulWidget {
  const RequestSuratScreen({super.key});

  @override
  State<RequestSuratScreen> createState() => _RequestSuratScreenState();
}

class _RequestSuratScreenState extends State<RequestSuratScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController nameController;
  late TextEditingController phoneController;
  final TextEditingController keperluanController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();

  String? selectedJenisSurat;
  final String nomorAdmin = "6281263299741"; // Nomor Admin (Tanpa tanda +)

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    nameController = TextEditingController(text: user?.fullName);
    phoneController = TextEditingController(text: user?.phoneNumber);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    keperluanController.dispose();
    tanggalController.dispose();
    catatanController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Catat ke Backend terlebih dahulu
      await ApiClient().post(ApiConstants.requestSurat, body: {
        'jenis_surat': selectedJenisSurat,
        'keperluan': keperluanController.text,
        'tanggal_pengambilan': tanggalController.text,
        'catatan': catatanController.text,
        'phone_number': phoneController.text, // Pastikan nomor hp juga dikirim
      });

      // 2. Siapkan Pesan WhatsApp
      String rawPesan = '''
Halo Admin GPdI Sibulele, saya ingin request surat.

Nama: ${nameController.text}
No HP: ${phoneController.text}
Jenis Surat: $selectedJenisSurat
Keperluan: ${keperluanController.text}
Tanggal Pengambilan: ${tanggalController.text}
Catatan Tambahan: ${catatanController.text.isEmpty ? '-' : catatanController.text}

(Permohonan ini juga telah tercatat di sistem aplikasi)
''';

      final String encodedPesan = Uri.encodeComponent(rawPesan);
      final Uri waUri = Uri.parse("whatsapp://send?phone=$nomorAdmin&text=$encodedPesan");
      final Uri fallbackUri = Uri.parse("https://wa.me/$nomorAdmin?text=$encodedPesan");

      // 3. Buka WhatsApp
      bool launched = await launchUrl(waUri);
      if (!launched) {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim ke sistem: $e\nTetap arahkan ke WhatsApp...'),
          backgroundColor: Colors.orange,
        ),
      );
      _openWhatsAppManual();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openWhatsAppManual() async {
    String rawPesan = "Halo Admin GPdI Sibulele, saya ingin request surat $selectedJenisSurat.";
    final Uri fallbackUri = Uri.parse("https://wa.me/$nomorAdmin?text=${Uri.encodeComponent(rawPesan)}");
    await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    const Color navy = Color(0xFF05066F);

    return Scaffold(
      drawer: const MemberDrawer(activeMenu: MemberDrawerMenu.requestSurat),
      backgroundColor: const Color(0xFFF8F4FC),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: navy, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Request Surat',
          style: TextStyle(color: navy, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 150),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Layanan Surat',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: navy),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Isi formulir untuk mengirim permohonan ke sistem dan WhatsApp Sekretariat.',
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                          const SizedBox(height: 32),

                          _buildSectionTitle('IDENTITAS JEMAAT'),
                          // Nama tetap readOnly untuk validasi identitas asli
                          _buildTextField('Nama Lengkap', nameController, Icons.person_outline, readOnly: true),
                          // Nomor HP sekarang bisa diubah jika perlu (readOnly: false)
                          _buildTextField('No. HP / WhatsApp', phoneController, Icons.phone_android_outlined, readOnly: false, keyboardType: TextInputType.phone),

                          const SizedBox(height: 12),
                          _buildSectionTitle('DETAIL PERMOHONAN'),

                          DropdownButtonFormField<String>(
                            decoration: _inputDecoration('Jenis Surat', Icons.description_outlined),
                            value: selectedJenisSurat,
                            items: [
                              'Surat Baptis',
                              'Surat Nikah',
                              'Surat Keterangan Jemaat',
                              'Surat Pengantar'
                            ].map((jenis) => DropdownMenuItem(value: jenis, child: Text(jenis))).toList(),
                            onChanged: (value) => setState(() => selectedJenisSurat = value),
                            validator: (value) => value == null ? 'Pilih jenis surat' : null,
                          ),
                          const SizedBox(height: 16),

                          _buildTextField('Keperluan Surat', keperluanController, Icons.info_outline),
                          _buildTextField('Tanggal Pengambilan', tanggalController, Icons.calendar_today_outlined, hint: 'Contoh: 25 Mei 2024'),
                          _buildTextField('Catatan Tambahan (Opsional)', catatanController, Icons.note_alt_outlined, required: false),

                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: navy,
                                disabledBackgroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.message, color: Colors.white),
                                      SizedBox(width: 12),
                                      Text(
                                        'Kirim Permohonan',
                                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MemberBottomNavigation(currentIndex: -1),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType, bool required = true, String? hint, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: _inputDecoration(label, icon).copyWith(
          hintText: hint,
          fillColor: readOnly ? Colors.grey[100] : Colors.white,
        ),
        keyboardType: keyboardType,
        validator: required ? (value) => value!.isEmpty ? '$label wajib diisi' : null : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF05066F), size: 22),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }
}
