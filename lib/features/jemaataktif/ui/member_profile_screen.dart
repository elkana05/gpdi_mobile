import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import 'member_drawer.dart';
import 'member_bottom_navigation.dart';

class MemberProfileScreen extends StatefulWidget {
  const MemberProfileScreen({super.key});

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  static const Color navy = Color(0xFF05066F);
  static const Color gold = Color(0xFFFFC326);
  static const Color red = Color(0xFFD71313);
  static const Color softBg = Color(0xFFF8F4FC);

  bool isLoading = true;
  String errorMsg = '';

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController emailController;
  late TextEditingController rayonController;

  final TextEditingController oldPassController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  List<dynamic> familyMembers = [];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    nameController = TextEditingController(text: user?.fullName);
    phoneController = TextEditingController(text: user?.phoneNumber);
    addressController = TextEditingController(text: user?.address);
    emailController = TextEditingController(text: user?.email);
    rayonController = TextEditingController(
      text: user?.rayonId != null ? 'Rayon ID: ${user?.rayonId}' : 'Belum Terdaftar',
    );
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMsg = '';
    });
    try {
      final results = await Future.wait([
        ApiClient().get(ApiConstants.userProfile),
        ApiClient().get(ApiConstants.familyMembers).catchError((e) => {'data': []}),
      ]);

      final pData = results[0]['data'] ?? results[0];
      final fData = results[1]['data'] ?? results[1] ?? [];

      if (mounted) {
        setState(() {
          nameController.text = pData['full_name'] ?? pData['name'] ?? nameController.text;
          phoneController.text = pData['phone_number'] ?? pData['phone'] ?? phoneController.text;
          addressController.text = pData['address'] ?? addressController.text;
          emailController.text = pData['email'] ?? emailController.text;

          if (pData['rayon'] != null) {
            rayonController.text = pData['rayon']['nama_rayon'] ?? pData['rayon']['name'] ?? 'Terdaftar';
          }

          familyMembers = fData is List ? fData : [];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      if (mounted) {
        setState(() {
          errorMsg = "Gagal sinkronisasi data dengan server.";
          isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() => isLoading = true);
    try {
      await ApiClient().post(ApiConstants.updateProfile, body: {
        'full_name': nameController.text,
        'phone_number': phoneController.text,
        'address': addressController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: Colors.green),
      );
      _fetchData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui profil: $e'), backgroundColor: Colors.red),
      );
      setState(() => isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MemberDrawer(activeMenu: MemberDrawerMenu.none),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text('Profil Saya', style: TextStyle(color: navy, fontWeight: FontWeight.w900, fontSize: 18)),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: navy),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return RefreshIndicator(
                onRefresh: _fetchData,
                color: navy,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (errorMsg.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, color: Colors.orange),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(errorMsg, style: const TextStyle(fontSize: 12))),
                                ],
                              ),
                            ),

                          _buildSectionHeader("DATA PRIBADI", Icons.person_outline),
                          _buildPersonalDataSection(),
                          const SizedBox(height: 32),

                          _buildSectionHeader("ANGGOTA KELUARGA", Icons.groups_outlined),
                          _buildFamilySection(),
                          const SizedBox(height: 32),

                          _buildSectionHeader("KEAMANAN AKUN", Icons.lock_outline),
                          _buildSecuritySection(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          ),
          if (isLoading)
            Container(
              color: Colors.white.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator(color: navy)),
            ),
          const Positioned(
            left: 0, right: 0, bottom: 0,
            child: MemberBottomNavigation(currentIndex: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        children: [
          Icon(icon, color: navy, size: 22),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(color: navy, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
        ],
      ),
    );
  }

  Widget _buildPersonalDataSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F9), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _buildInput("Nama Lengkap", nameController),
          _buildInput("Nomor HP", phoneController),
          _buildInput("Alamat", addressController, maxLines: 2),
          _buildInput("Email", emailController, readOnly: true),
          _buildInput("Rayon", rayonController, readOnly: true),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Simpan Perubahan", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F9), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          if (familyMembers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text("Belum ada data anggota keluarga.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            )
          else
            ...familyMembers.map((m) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(backgroundColor: navy, child: Icon(Icons.person, color: Colors.white, size: 20)),
              title: Text(m['full_name'] ?? m['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(m['relation'] ?? 'Anggota Keluarga', style: const TextStyle(fontSize: 12)),
            )),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur tambah anggota segera hadir')));
            },
            icon: const Icon(Icons.add, color: navy),
            label: const Text("Tambah Anggota", style: TextStyle(color: navy, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: navy),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F9), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _buildInput("Password Lama", oldPassController, isPassword: true),
          _buildInput("Password Baru", newPassController, isPassword: true),
          _buildInput("Konfirmasi Password Baru", confirmPassController, isPassword: true),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur ganti password segera hadir')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: navy, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text("Perbarui Password", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {int maxLines = 1, bool isPassword = false, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: navy, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            obscureText: isPassword,
            readOnly: readOnly,
            style: TextStyle(color: readOnly ? Colors.grey : Colors.black87, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly ? Colors.grey[100] : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: navy, width: 1)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
