// lib/features/auth/models/user_model.dart

class UserModel {
  final String id;
  final String email;
  final bool isActive;
  final String fullName;
  final String? phoneNumber;
  final String? address;
  final int? rayonId;
  final List<String> roles;

  UserModel({
    required this.id,
    required this.email,
    required this.isActive,
    required this.fullName,
    this.phoneNumber,
    this.address,
    this.rayonId,
    required this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // 1. Tangkap 'role' yang dari backend aslinya String tunggal ("jemaat_aktif")
    List<String> parsedRoles = [];
    if (json['role'] != null && json['role'] is String) {
      parsedRoles.add(json['role'].toString());
    } else if (json['roles'] != null && json['roles'] is List) {
      parsedRoles = (json['roles'] as List).map((e) => e['name']?.toString() ?? e.toString()).toList();
    }

    // 2. Petakan data yang sudah dirampingkan (flattened) oleh backend
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      isActive: json['is_active'] == 1 || json['is_active'] == true,

      // Ambil 'name' langsung sesuai JSON Pak Tommy
      fullName: json['name']?.toString() ?? 'Jemaat GPdI',

      phoneNumber: json['phone']?.toString(), // Sesuaikan jika ada
      address: json['address']?.toString(),   // Sesuaikan jika ada

      // Ambil 'id_rayon' langsung sesuai JSON Pak Tommy
      rayonId: json['id_rayon'] != null ? int.tryParse(json['id_rayon'].toString()) : null,

      roles: parsedRoles,
    );
  }

  bool get isAdmin => roles.contains('admin');
}