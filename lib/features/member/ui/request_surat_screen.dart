import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'member_drawer.dart';

class RequestSuratScreen extends StatefulWidget {
  const RequestSuratScreen({super.key});

  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color softBg = Color(0xFFF8F4FC);
  static const Color inputBg = Color(0xFFF1EFFB);
  static const Color textDark = Color(0xFF1E1E2F);
  static const Color textGrey = Color(0xFF77798A);

  @override
  State<RequestSuratScreen> createState() => _RequestSuratScreenState();
}

class _RequestSuratScreenState extends State<RequestSuratScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController pickupDateController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String selectedLetterType = 'Surat Keterangan Anggota';

  final List<String> letterTypes = const [
    'Surat Keterangan Anggota',
    'Surat Keterangan Baptis',
    'Surat Keterangan Pernikahan',
    'Surat Keterangan Pelayanan',
    'Surat Rekomendasi Gereja',
  ];

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    pickupDateController.dispose();
    purposeController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: RequestSuratScreen.navy,
              onPrimary: Colors.white,
              onSurface: RequestSuratScreen.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    final month = pickedDate.month.toString().padLeft(2, '0');
    final day = pickedDate.day.toString().padLeft(2, '0');
    final year = pickedDate.year.toString();

    setState(() {
      pickupDateController.text = '$month/$day/$year';
    });
  }

  Future<void> _sendToWhatsApp() async {
    final fullName = fullNameController.text.trim();
    final phone = phoneController.text.trim();
    final pickupDate = pickupDateController.text.trim();
    final purpose = purposeController.text.trim();
    final notes = notesController.text.trim();

    if (fullName.isEmpty ||
        phone.isEmpty ||
        pickupDate.isEmpty ||
        purpose.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nama, nomor HP, tanggal pengambilan, dan tujuan wajib diisi.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    const String adminPhone = '6281263299741';

    final String message = '''
Shalom Admin GPDI Sibulele,

Saya ingin mengajukan request surat jemaat dengan data berikut:

Nama Lengkap:
$fullName

Nomor HP:
$phone

Jenis Surat:
$selectedLetterType

Tanggal Pengambilan:
$pickupDate

Tujuan Pengajuan:
$purpose

Catatan Tambahan:
${notes.isEmpty ? '-' : notes}

Mohon bantuan untuk proses validasi dan pembuatan surat.

Terima kasih.
''';

    final Uri whatsappUrl = Uri.parse(
      'https://wa.me/$adminPhone?text=${Uri.encodeComponent(message)}',
    );

    try {
      final canOpen = await canLaunchUrl(whatsappUrl);

      if (!canOpen) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tidak dapat membuka WhatsApp. Pastikan WhatsApp terpasang.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka WhatsApp: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MemberDrawer(
        activeMenu: MemberDrawerMenu.requestSurat,
      ),
      backgroundColor: RequestSuratScreen.softBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: RequestSuratScreen.navy,
                size: 27,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        titleSpacing: 0,
        title: const Text(
          'GPdI',
          style: TextStyle(
            color: RequestSuratScreen.navy,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFD8D8DF),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: Color(0xFF17616A),
                child: Icon(
                  Icons.person,
                  color: Color(0xFFFFC326),
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 34, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 5,
              decoration: BoxDecoration(
                color: RequestSuratScreen.gold,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Request Surat Jemaat',
              style: TextStyle(
                color: RequestSuratScreen.navy,
                fontSize: 32,
                height: 1.15,
                fontWeight: FontWeight.w900,
                fontFamily: 'serif',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Silakan lengkapi formulir di bawah untuk\npengajuan surat keterangan gereja.',
              style: TextStyle(
                color: RequestSuratScreen.textGrey,
                fontSize: 17,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            _InputLabel(text: 'FULL NAME'),
            const SizedBox(height: 10),
            _TextInput(
              controller: fullNameController,
              hintText: 'Masukkan nama lengkap',
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 24),
            _InputLabel(text: 'PHONE NUMBER'),
            const SizedBox(height: 10),
            _TextInput(
              controller: phoneController,
              hintText: '0812-xxxx-xxxx',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            _InputLabel(text: 'LETTER TYPE'),
            const SizedBox(height: 10),
            _DropdownInput(
              value: selectedLetterType,
              items: letterTypes,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  selectedLetterType = value;
                });
              },
            ),
            const SizedBox(height: 24),
            _InputLabel(text: 'PICKUP DATE'),
            const SizedBox(height: 10),
            _TextInput(
              controller: pickupDateController,
              hintText: 'mm/dd/yyyy',
              readOnly: true,
              onTap: _pickDate,
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 24),
            _InputLabel(text: 'PURPOSE'),
            const SizedBox(height: 10),
            _TextInput(
              controller: purposeController,
              hintText: 'Tujuan pengajuan surat...',
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            _InputLabel(text: 'ADDITIONAL NOTES'),
            const SizedBox(height: 10),
            _TextInput(
              controller: notesController,
              hintText: 'Catatan tambahan (opsional)',
              maxLines: 3,
            ),
            const SizedBox(height: 56),
            SizedBox(
              width: double.infinity,
              height: 68,
              child: ElevatedButton(
                onPressed: _sendToWhatsApp,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: RequestSuratScreen.navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.send_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Kirim ke WhatsApp',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Dengan menekan tombol di atas, Anda akan diarahkan\nke layanan WhatsApp resmi gereja untuk validasi\nakhir.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: RequestSuratScreen.textGrey,
                  fontSize: 12,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 42),
            const _ProcedureCard(),
          ],
        ),
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String text;

  const _InputLabel({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF77798A),
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.2,
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;

  const _TextInput({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: maxLines > 1 ? 78.0 : 54.0,
      ),
      decoration: BoxDecoration(
        color: RequestSuratScreen.inputBg,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFFD1D2E5),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: RequestSuratScreen.textDark,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFFB8B6C8),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

class _DropdownInput extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownInput({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: RequestSuratScreen.inputBg,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFFD1D2E5),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: RequestSuratScreen.textDark,
            size: 26,
          ),
          dropdownColor: Colors.white,
          style: const TextStyle(
            color: RequestSuratScreen.textDark,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ProcedureCard extends StatelessWidget {
  const _ProcedureCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 36, 28, 36),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EEFA),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: RequestSuratScreen.gold,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Prosedur Pengambilan',
            style: TextStyle(
              color: RequestSuratScreen.textDark,
              fontSize: 24,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              fontFamily: 'serif',
            ),
          ),
          SizedBox(height: 28),
          _ProcedureItem(
            text: 'Proses verifikasi data\nmembutuhkan waktu 1-2 hari\nkerja.',
          ),
          SizedBox(height: 28),
          _ProcedureItem(
            text:
                'Surat dapat diambil di kantor\nsekretariat sesuai tanggal pilihan.',
          ),
          SizedBox(height: 28),
          _ProcedureItem(
            text: 'Harap membawa kartu identitas\n(KTP) saat pengambilan.',
          ),
        ],
      ),
    );
  }
}

class _ProcedureItem extends StatelessWidget {
  final String text;

  const _ProcedureItem({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 21,
          height: 21,
          margin: const EdgeInsets.only(top: 2),
          decoration: const BoxDecoration(
            color: Color(0xFF8A7100),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 15,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: RequestSuratScreen.textDark,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
