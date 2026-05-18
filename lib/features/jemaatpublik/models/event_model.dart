class WorshipScheduleModel {
  final int? id;
  final String title;
  final String day;
  final String time;
  final String location;

  WorshipScheduleModel({this.id, required this.title, required this.day, required this.time, required this.location});

  factory WorshipScheduleModel.fromJson(Map<String, dynamic> json) {
    return WorshipScheduleModel(
      id: json['id'],
      title: json['nama_ibadah'] ?? json['category'] ?? json['nama'] ?? '-',
      day: json['day_of_week'] ?? json['hari'] ?? '-',
      time: json['start_time'] ?? json['jam'] ?? json['waktu'] ?? '-',
      location: json['location'] ?? json['tempat'] ?? '-',
    );
  }
}

class ActivityModel {
  final int? id;
  final String title;
  final String description;
  final String date;
  final String? image;

  ActivityModel({this.id, required this.title, required this.description, required this.date, this.image});

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'],
      title: json['judul'] ?? json['title'] ?? json['nama_kegiatan'] ?? '-',
      description: json['description'] ?? json['deskripsi'] ?? '-',
      date: json['event_date'] ?? json['tanggal'] ?? '-',
      image: json['gambar'] ?? json['image'],
    );
  }
}

class RayonScheduleModel {
  final int? id;
  final String rayonName;
  final String date;
  final String location;
  final String? hostName;

  RayonScheduleModel({this.id, required this.rayonName, required this.date, required this.location, this.hostName});

  factory RayonScheduleModel.fromJson(Map<String, dynamic> json) {
    return RayonScheduleModel(
      id: json['id'],
      rayonName: json['rayon_name'] ?? json['nama_rayon'] ?? '-',
      date: json['date'] ?? json['tanggal'] ?? '-',
      location: json['location'] ?? json['tempat'] ?? '-',
      hostName: json['host_name'] ?? json['nama_tuan_rumah'],
    );
  }
}
