class BuktiFotoModel {
  final int id;
  final int laporanId;
  final String url;
  final DateTime? createdAt;

  BuktiFotoModel({
    required this.id,
    required this.laporanId,
    required this.url,
    this.createdAt,
  });

  factory BuktiFotoModel.fromMap(Map<String, dynamic> map) {
    return BuktiFotoModel(
      id: map['id'] is int ? map['id'] as int : int.parse(map['id'].toString()),
      laporanId: map['laporan_id'] is int ? map['laporan_id'] as int : int.parse(map['laporan_id'].toString()),
      url: map['url']?.toString() ?? '',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'laporan_id': laporanId,
      'url': url,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
