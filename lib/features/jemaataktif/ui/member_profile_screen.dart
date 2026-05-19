import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/providers/user_provider.dart';
import '../../auth/models/family_member_model.dart';
import 'member_drawer.dart';
import 'member_bottom_navigation.dart';

class MemberProfileScreen extends StatefulWidget {
  const MemberProfileScreen({super.key});

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFC5A327);
  static const Color redAccent = Color(0xFFD71313);
  static const Color softBg = Color(0xFFF8F9FE);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF7A7C92);

  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController emailController;
  late TextEditingController rayonController;

  final oldPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    emailController = TextEditingController();
    rayonController = TextEditingController();

    Future.microtask(() => _fetchInitialData());
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchPersonalData();
    _updateControllers();
  }

  void _updateControllers() {
    if (!mounted) return;
    final p = Provider.of<UserProvider>(context, listen: false).detailedProfile;
    if (p != null) {
      setState(() {
        nameController.text = p.fullName;
        phoneController.text = p.phoneNumber ?? "";
        addressController.text = p.address ?? "";
        emailController.text = p.email;
        rayonController.text = p.rayonId != null ? "Rayon ${p.rayonId}" : "Belum Terdaftar";
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    emailController.dispose();
    rayonController.dispose();
    oldPassController.dispose();
    newPassController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleProfileSubmit() async {
    final messenger = ScaffoldMessenger.of(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.updateProfile({
      'full_name': nameController.text,
      'phone_number': phoneController.text,
      'address': addressController.text,
    });

    if (!mounted) return;

    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text("Profil berhasil diperbarui!", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      _showError(userProvider.errorMessage);
    }
  }

  Future<void> _handlePasswordSubmit() async {
    final messenger = ScaffoldMessenger.of(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.changePassword(
      oldPassController.text,
      newPassController.text,
      confirmPassController.text,
    );

    if (!mounted) return;

    if (success) {
      oldPassController.clear();
      newPassController.clear();
      confirmPassController.clear();
      messenger.showSnackBar(
        SnackBar(
          content: Text("Password berhasil diperbarui!", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      _showError(userProvider.errorMessage);
    }
  }

  void _openFamilyModal([FamilyMemberModel? member]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => _FamilyMemberModal(
        member: member,
        onSave: (data) async {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          bool success = member != null
              ? await userProvider.updateFamilyMember(member.id!, data)
              : await userProvider.addFamilyMember(data);

          if (success && modalContext.mounted) {
            Navigator.pop(modalContext);
          } else if (!success && mounted) {
            _showError(userProvider.errorMessage);
          }
        },
      ),
    );
  }

  Future<void> _handleDeleteFamily(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Hapus Anggota", style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: navy)),
        content: Text("Yakin ingin menghapus anggota keluarga ini?", style: GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Batal", style: GoogleFonts.montserrat(color: textGrey, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("Hapus", style: GoogleFonts.montserrat(color: redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final success = await userProvider.deleteFamilyMember(id);
      if (success && mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text("Data keluarga dihapus", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
        backgroundColor: redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MemberDrawer(activeMenu: MemberDrawerMenu.profil),
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
          'Profil Saya',
          style: GoogleFonts.montserrat(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading && !_isInitialized) {
            return const Center(child: CircularProgressIndicator(color: navy));
          }

          if (!_isInitialized && userProvider.detailedProfile != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _updateControllers());
          }

          return RefreshIndicator(
            onRefresh: _fetchInitialData,
            color: navy,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),

                  _buildSectionCard(
                    title: "Data Pribadi",
                    subtitle: "Informasi kontak dan domisili",
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildInput("Nama Lengkap", nameController, Icons.person_outline_rounded),
                          _buildInput("Nomor HP", phoneController, Icons.phone_android_rounded),
                          _buildInput("Alamat", addressController, Icons.location_on_outlined),
                          _buildInput("Email", emailController, Icons.alternate_email_rounded, readOnly: true),
                          _buildInput("Rayon", rayonController, Icons.groups_outlined, readOnly: true),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: userProvider.isLoading ? null : _handleProfileSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: navy,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: 0,
                              ),
                              child: userProvider.isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text("Simpan Perubahan", style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  _buildSectionCard(
                    title: "Anggota Keluarga",
                    subtitle: "Data tanggungan keluarga jemaat",
                    headerAction: ElevatedButton.icon(
                      onPressed: () => _openFamilyModal(),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text("Tambah"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold.withOpacity(0.1),
                        foregroundColor: gold,
                        elevation: 0,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ),
                    child: Column(
                      children: [
                        if (userProvider.familyMembers.isEmpty)
                          _buildEmptyState("Belum ada data keluarga")
                        else
                          ...userProvider.familyMembers.map((m) => _buildFamilyItem(m)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  _buildSectionCard(
                    title: "Keamanan Akun",
                    subtitle: "Perbarui password secara berkala",
                    child: Form(
                      key: _passwordFormKey,
                      child: Column(
                        children: [
                          _buildInput("Password Lama", oldPassController, Icons.lock_open_rounded, isPassword: true),
                          _buildInput("Password Baru", newPassController, Icons.lock_outline_rounded, isPassword: true),
                          _buildInput("Konfirmasi Password", confirmPassController, Icons.lock_rounded, isPassword: true),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: userProvider.isLoading ? null : _handlePasswordSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: navy,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: 0,
                              ),
                              child: Text("Perbarui Password", style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const MemberBottomNavigation(currentIndex: 2),
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
            'DATA JEMAAT',
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
          'Profil &\nKeanggotaan',
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

  Widget _buildSectionCard({required String title, required String subtitle, required Widget child, Widget? headerAction}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(color: textDark, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(color: textGrey, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            if (headerAction != null) ...[
              const SizedBox(width: 8),
              headerAction,
            ],
          ],
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

  Widget _buildInput(String label, TextEditingController controller, IconData icon, {bool readOnly = false, bool isPassword = false}) {
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
            readOnly: readOnly,
            obscureText: isPassword,
            style: GoogleFonts.montserrat(fontSize: 15, color: textDark, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly ? softBg : Colors.white,
              prefixIcon: Icon(icon, color: textGrey, size: 20),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyItem(FamilyMemberModel member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: softBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: navy.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.family_restroom_rounded, color: navy, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 15, color: textDark),
                ),
                Text(
                  "${member.relationship} • ${member.gender ?? '-'}",
                  style: GoogleFonts.montserrat(fontSize: 12, color: textGrey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: navy, size: 22),
            onPressed: () => _openFamilyModal(member),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: redAccent, size: 22),
            onPressed: () => _handleDeleteFamily(member.id!),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.people_outline_rounded, color: textGrey.withOpacity(0.3), size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.montserrat(color: textGrey, fontSize: 14, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyMemberModal extends StatefulWidget {
  final FamilyMemberModel? member;
  final Future<void> Function(Map<String, dynamic>) onSave;
  const _FamilyMemberModal({this.member, required this.onSave});

  @override
  State<_FamilyMemberModal> createState() => _FamilyMemberModalState();
}

class _FamilyMemberModalState extends State<_FamilyMemberModal> {
  final nameController = TextEditingController();
  final relController = TextEditingController();
  final dateController = TextEditingController();
  String? gender;
  bool _isSaving = false;

  static const Color navy = Color(0xFF05066F);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF7A7C92);

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      nameController.text = widget.member!.name;
      relController.text = widget.member!.relationship;
      dateController.text = widget.member!.birthDate ?? "";
      gender = widget.member!.gender;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Data Keluarga",
              style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w900, color: navy),
            ),
            const SizedBox(height: 8),
            Text(
              "Lengkapi detail informasi anggota keluarga",
              style: GoogleFonts.montserrat(fontSize: 14, color: textGrey, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),
            _buildField("Nama Lengkap", nameController, Icons.person_outline_rounded),
            _buildField("Hubungan", relController, Icons.family_restroom_rounded, hint: "Contoh: Anak / Istri"),

            Text(
              "Jenis Kelamin",
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 13, color: textDark),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: gender,
              isExpanded: true,
              style: GoogleFonts.montserrat(color: textDark, fontWeight: FontWeight.w600, fontSize: 15),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.wc_rounded, color: textGrey, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                fillColor: Colors.white,
                filled: true,
              ),
              items: ["Laki-laki", "Perempuan"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: _isSaving ? null : (v) => setState(() => gender = v),
            ),
            const SizedBox(height: 20),
            _buildField("Tanggal Lahir", dateController, Icons.calendar_today_rounded, hint: "YYYY-MM-DD"),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : () async {
                  if (nameController.text.isEmpty || relController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Nama dan Hubungan wajib diisi", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  setState(() => _isSaving = true);
                  FocusScope.of(context).unfocus();

                  await widget.onSave({
                    'full_name': nameController.text,
                    'relationship': relController.text,
                    'gender': gender,
                    'birth_date': dateController.text,
                  });

                  if (mounted) {
                    setState(() => _isSaving = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: navy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text("Simpan Data", style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 13, color: textDark),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: !_isSaving,
            style: GoogleFonts.montserrat(fontSize: 15, color: textDark, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.montserrat(color: textGrey, fontSize: 14),
              prefixIcon: Icon(icon, color: textGrey, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
