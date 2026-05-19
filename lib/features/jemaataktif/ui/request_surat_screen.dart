import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
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
  static const Color gold = Color(0xFFC5A327);
  static const Color redAccent = Color(0xFFD71313);
  static const Color softBg = Color(0xFFF8F9FE);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF7A7C92);

  final _formKey = GlobalKey<FormState>();

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
            colorScheme: const ColorScheme.light(
              primary: navy,
              onPrimary: Colors.white,
              onSurface: textDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
            ),
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
        SnackBar(
          content: Text("Mohon lengkapi semua field wajib.", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
          backgroundColor: redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
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
          SnackBar(
            content: Text("Gagal membuka WhatsApp.", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
            backgroundColor: redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MemberDrawer(activeMenu: MemberDrawerMenu.requestSurat),
      backgroundColor: softBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: navy.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu_rounded, color: navy, size: 22),
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: Text(
          'Layanan Surat',
          style: GoogleFonts.montserrat(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),

            _buildSectionCard(
              title: "Form Permohonan",
              subtitle: "Data akan dikirimkan ke WhatsApp Admin",
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInput("Nama Lengkap", nameController, Icons.person_outline_rounded, "Masukkan nama lengkap"),
                    _buildInput("No. HP / WhatsApp", phoneController, Icons.phone_android_rounded, "Contoh: 08123456789", keyboardType: TextInputType.phone),

                    Text(
                      "Jenis Surat",
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: textDark, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      style: GoogleFonts.montserrat(color: textDark, fontWeight: FontWeight.w600, fontSize: 15),
                      decoration: _inputDecoration(icon: Icons.description_outlined),
                      hint: Text("Pilih jenis surat", style: GoogleFonts.montserrat(fontSize: 14, color: textGrey)),
                      items: suratTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) => setState(() => selectedType = val),
                    ),
                    const SizedBox(height: 20),

                    _buildInput("Tanggal Pengambilan", dateController, Icons.calendar_today_rounded, "Pilih tanggal", readOnly: true, onTap: _selectDate),
                    _buildInput("Keperluan Penggunaan", purposeController, Icons.info_outline_rounded, "Contoh: Pendaftaran sekolah"),
                    _buildInput("Catatan Tambahan (Opsional)", noteController, Icons.note_alt_outlined, "Tuliskan detail tambahan...", maxLines: 3),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: navy.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: navy.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: navy, size: 16),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'WhatsApp akan terbuka otomatis dengan format pesan yang sudah tersusun.',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: textGrey,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitToWhatsApp,
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: Text("Kirim via WhatsApp", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'LAYANAN PERSURATAN',
            style: GoogleFonts.montserrat(
              color: gold,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Permohonan\nSurat Jemaat',
          style: GoogleFonts.montserrat(
            color: navy,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required String subtitle, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(color: textDark, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.montserrat(color: textGrey, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController controller, IconData icon, String hint, {TextInputType? keyboardType, int maxLines = 1, bool readOnly = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: textDark, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            style: GoogleFonts.montserrat(fontSize: 15, color: textDark, fontWeight: FontWeight.w600),
            decoration: _inputDecoration(hint: hint, icon: icon),
            validator: (val) => (val == null || val.isEmpty) ? "Field ini wajib diisi" : null,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.montserrat(color: textGrey, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: icon != null ? Icon(icon, color: textGrey, size: 20) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: navy, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: redAccent, width: 1),
      ),
    );
  }
}
