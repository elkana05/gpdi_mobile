class RayonModel {
  final int id;
  final String name;
  final String? description;

  RayonModel({required this.id, required this.name, this.description});

  factory RayonModel.fromJson(Map<String, dynamic> json) {
    return RayonModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['nama_rayon'] ?? json['name'] ?? '-',
      description: json['keterangan'] ?? json['description'],
    );
  }
}
