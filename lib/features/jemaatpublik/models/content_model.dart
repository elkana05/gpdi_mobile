class GalleryModel {
  final int? id;
  final String? title;
  final String? image;
  final String? description;

  GalleryModel({this.id, this.title, this.image, this.description});

  factory GalleryModel.fromJson(Map<String, dynamic> json) {
    return GalleryModel(
      id: json['id'],
      title: json['judul'] ?? json['title'] ?? '-',
      image: json['path_foto'] ?? json['foto'] ?? json['gambar'] ?? json['image'] ?? json['file_path'],
      description: json['deskripsi'] ?? json['description'],
    );
  }
}

class ServiceModel {
  final int? id;
  final String name;
  final String shortDesc;
  final String longDesc;
  final String? image;
  final String? schedule;
  final String? leader;

  ServiceModel({
    this.id,
    required this.name,
    required this.shortDesc,
    required this.longDesc,
    this.image,
    this.schedule,
    this.leader,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['nama'] ?? json['name'] ?? '-',
      shortDesc: json['deskripsi_singkat'] ?? json['short_description'] ?? '-',
      longDesc: json['deskripsi_lengkap'] ?? json['long_description'] ?? '-',
      image: json['path_foto'] ?? json['foto'] ?? json['gambar'] ?? json['image'],
      schedule: json['jadwal'] ?? json['schedule'],
      leader: json['penanggung_jawab'] ?? json['leader'],
    );
  }
}

class DevotionalModel {
  final int? id;
  final String title;
  final String content;
  final String date;
  final String? author;

  DevotionalModel({this.id, required this.title, required this.content, required this.date, this.author});

  factory DevotionalModel.fromJson(Map<String, dynamic> json) {
    return DevotionalModel(
      id: json['id'],
      title: json['judul'] ?? json['title'] ?? '-',
      content: json['konten'] ?? json['content'] ?? '-',
      date: json['tanggal'] ?? json['date'] ?? '-',
      author: json['penulis'] ?? json['author'],
    );
  }
}

class AnnouncementModel {
  final int? id;
  final String title;
  final String content;
  final String date;
  final String? category;

  AnnouncementModel({this.id, required this.title, required this.content, required this.date, this.category});

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'],
      title: json['judul'] ?? json['title'] ?? '-',
      content: json['isi'] ?? json['content'] ?? '-',
      date: json['tanggal'] ?? json['date'] ?? '-',
      category: json['kategori'] ?? json['category'],
    );
  }
}
