class LetterRequestModel {
  final int? id;
  final String type;
  final String status;
  final String? note;
  final String createdAt;

  LetterRequestModel({
    this.id,
    required this.type,
    required this.status,
    this.note,
    required this.createdAt,
  });

  factory LetterRequestModel.fromJson(Map<String, dynamic> json) {
    return LetterRequestModel(
      id: json['id'],
      type: json['jenis_surat'] ?? json['type'] ?? '-',
      status: json['status'] ?? 'Pending',
      note: json['keterangan'] ?? json['note'],
      createdAt: json['created_at'] ?? '-',
    );
  }
}

class NotificationModel {
  final int? id;
  final String title;
  final String message;
  final String createdAt;
  final bool isRead;

  NotificationModel({
    this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['judul'] ?? json['title'] ?? '-',
      message: json['pesan'] ?? json['message'] ?? '-',
      createdAt: json['created_at'] ?? '-',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
    );
  }
}
