class FamilyMemberModel {
  final int? id;
  final String name;
  final String relationship;
  final String? birthDate;
  final String? gender;

  FamilyMemberModel({
    this.id,
    required this.name,
    required this.relationship,
    this.birthDate,
    this.gender,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      id: json['id'],
      name: json['full_name'] ?? json['name'] ?? '',
      relationship: json['relationship'] ?? '',
      birthDate: json['birth_date'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': name,
      'relationship': relationship,
      'birth_date': birthDate,
      'gender': gender,
    };
  }
}
