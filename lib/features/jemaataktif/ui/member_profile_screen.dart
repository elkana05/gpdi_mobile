import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/user_provider.dart';
import '../../auth/models/family_member_model.dart';
import 'member_drawer.dart';
import 'member_bottom_navigation.dart';

// Top-level constants to ensure accessibility and valid constant values
const Color _navy = Color(0xFF05066F);
const Color _redAccent = Color(0xFFD71313);
const Color _sectionGray = Color(0xFFEEEDED);

class MemberProfileScreen extends StatefulWidget {
  const MemberProfileScreen({super.key});

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
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
        rayonController.text = p.rayonId != null ? "Rayon ID: ${p.rayonId}" : "Belum Terdaftar";
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
        const SnackBar(content: Text("Profil berhasil diperbarui!"), backgroundColor: Colors.green),
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
        const SnackBar(content: Text("Password berhasil diperbarui!"), backgroundColor: Colors.green),
      );
    } else {
      _showError(userProvider.errorMessage);
    }
  }

  void _openFamilyModal([FamilyMemberModel? member]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (modalContext) => _FamilyMemberModal(
        member: member,
        onSave: (data) async {
          // Gunakan context utama untuk provider agar tetap valid
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
        title: const Text("Hapus Anggota"),
        content: const Text("Yakin ingin menghapus anggota keluarga ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Hapus", style: TextStyle(color: _redAccent))),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final success = await userProvider.deleteFamilyMember(id);
      if (success && mounted) {
        messenger.showSnackBar(const SnackBar(content: Text("Data keluarga dihapus")));
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: _redAccent));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MemberDrawer(activeMenu: MemberDrawerMenu.profil),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: _navy),
        title: const Text("Profil Saya", style: TextStyle(color: _navy, fontSize: 17, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading && !_isInitialized) {
            return const Center(child: CircularProgressIndicator(color: _navy));
          }

          if (!_isInitialized && userProvider.detailedProfile != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _updateControllers());
          }

          return RefreshIndicator(
            onRefresh: _fetchInitialData,
            color: _navy,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Profil Saya", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: _navy)),
                  const SizedBox(height: 8),
                  const Text("Kelola informasi pribadi dan data keluarga", style: TextStyle(fontSize: 16, color: Colors.grey)),

                  _buildSectionBox(
                    title: "Data Pribadi",
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildInput("Nama Lengkap", nameController),
                          _buildInput("Nomor HP", phoneController),
                          _buildInput("Alamat", addressController),
                          _buildInput("Email", emailController, readOnly: true),
                          _buildInput("Rayon", rayonController, readOnly: true),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: userProvider.isLoading ? null : _handleProfileSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _navy,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: userProvider.isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("Simpan Perubahan", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  _buildSectionBox(
                    title: "Anggota Keluarga",
                    headerAction: IntrinsicWidth(
                      child: SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () => _openFamilyModal(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: const Text("+ Tambah", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        if (userProvider.familyMembers.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text("Belum ada data keluarga", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                          )
                        else
                          ...userProvider.familyMembers.map((m) => _buildFamilyItem(m)),
                      ],
                    ),
                  ),

                  _buildSectionBox(
                    title: "Keamanan Akun",
                    child: Form(
                      key: _passwordFormKey,
                      child: Column(
                        children: [
                          _buildInput("Password Lama", oldPassController, isPassword: true),
                          _buildInput("Password Baru", newPassController, isPassword: true),
                          _buildInput("Konfirmasi Password Baru", confirmPassController, isPassword: true),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: userProvider.isLoading ? null : _handlePasswordSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _navy,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Perbarui Password", style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildSectionBox({required String title, required Widget child, Widget? headerAction}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: _sectionGray, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              if (headerAction != null) headerAction,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {bool readOnly = false, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: _navy, fontSize: 13)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            obscureText: isPassword,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly ? Colors.grey[200] : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _navy)),
                Text("${member.relationship} • ${member.gender ?? '-'}", style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit_note, color: _navy), onPressed: () => _openFamilyModal(member)),
          IconButton(icon: const Icon(Icons.delete_outline, color: _redAccent), onPressed: () => _handleDeleteFamily(member.id!)),
        ],
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
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Data Anggota Keluarga", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _navy)),
            const SizedBox(height: 24),
            _buildField("Nama Lengkap", nameController),
            _buildField("Hubungan", relController, hint: "Contoh: Anak / Istri"),
            const Text("Jenis Kelamin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _navy)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: gender,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                fillColor: Colors.white,
                filled: true,
              ),
              items: ["Laki-laki", "Perempuan"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: _isSaving ? null : (v) => setState(() => gender = v),
            ),
            const SizedBox(height: 16),
            _buildField("Tanggal Lahir", dateController, hint: "YYYY-MM-DD"),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : () async {
                  if (nameController.text.isEmpty || relController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nama dan Hubungan wajib diisi")));
                    return;
                  }

                  setState(() => _isSaving = true);

                  // Menutup keyboard sebelum proses selesai
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
                  backgroundColor: _navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Simpan Data", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _navy)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: !_isSaving,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
