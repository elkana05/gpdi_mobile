class ChurchProfileModel {
  final String? name;
  final String? history;
  final String? vision;
  final List<String> missions;
  final String? image;
  final String? faithStatement;

  ChurchProfileModel({
    this.name,
    this.history,
    this.vision,
    this.missions = const [],
    this.image,
    this.faithStatement,
  });

  factory ChurchProfileModel.fromJson(Map<String, dynamic> json) {
    return ChurchProfileModel(
      name: json['nama_gereja'] ?? json['name'],
      history: json['sejarah'] ?? json['history'],
      vision: json['visi'] ?? json['vision'],
      missions: json['misi'] != null
          ? List<String>.from(json['misi'])
          : (json['missions'] != null ? List<String>.from(json['missions']) : []),
      image: json['path_foto'] ?? json['foto'] ?? json['gambar'] ?? json['image'],
      faithStatement: json['pengakuan_iman'] ?? json['faith_statement'],
    );
  }
}
