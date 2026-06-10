class NotifikasiModel {
  final int id;
  final String userId;
  final String tipe;
  final String judul;
  final String pesan;
  final bool dibaca;
  final DateTime? createdAt;

  NotifikasiModel({
    required this.id,
    required this.userId,
    required this.tipe,
    required this.judul,
    required this.pesan,
    required this.dibaca,
    this.createdAt,
  });

  factory NotifikasiModel.fromMap(Map<String, dynamic> map) {
    return NotifikasiModel(
      id: map['id'] is int ? map['id'] as int : int.parse(map['id'].toString()),
      userId: map['user_id']?.toString() ?? '',
      tipe: map['tipe']?.toString() ?? 'masuk',
      judul: map['judul']?.toString() ?? '',
      pesan: map['pesan']?.toString() ?? '',
      dibaca: map['dibaca'] is bool ? map['dibaca'] as bool : (map['dibaca']?.toString() == 'true'),
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'tipe': tipe,
      'judul': judul,
      'pesan': pesan,
      'dibaca': dibaca,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
