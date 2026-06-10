import 'bukti_foto_model.dart';
import 'user_model.dart';

class LaporanModel {
  final int id;
  final String pelaporId;
  final String namaPelapor;
  final String nimPelapor;
  final String jenis;
  final String lokasi;
  final DateTime tanggalKejadian;
  final String? waktuKejadian;
  final String kronologi;
  final String? pelaku;
  final String prioritas;
  final String status;
  final String? hasilMediasi;
  final String? tindakan;
  final String? catatanKaprodi;
  final String? diverifikasiOleh;
  final DateTime? diverifikasiAt;
  final String? ditindakOleh;
  final DateTime? ditindakAt;
  final DateTime? createdAt;
  final List<BuktiFotoModel>? buktiFoto;
  final UserModel? pelapor;

  LaporanModel({
    required this.id,
    required this.pelaporId,
    required this.namaPelapor,
    required this.nimPelapor,
    required this.jenis,
    required this.lokasi,
    required this.tanggalKejadian,
    this.waktuKejadian,
    required this.kronologi,
    this.pelaku,
    required this.prioritas,
    required this.status,
    this.hasilMediasi,
    this.tindakan,
    this.catatanKaprodi,
    this.diverifikasiOleh,
    this.diverifikasiAt,
    this.ditindakOleh,
    this.ditindakAt,
    this.createdAt,
    this.buktiFoto,
    this.pelapor,
  });

  // Helper untuk generate kode laporan e.g. RPT-001 dari ID database
  String get kode => 'RPT-${id.toString().padLeft(3, '0')}';

  factory LaporanModel.fromMap(Map<String, dynamic> map) {
    List<BuktiFotoModel>? buktiList;
    if (map['bukti_foto'] != null) {
      final list = map['bukti_foto'] as List;
      buktiList = list.map((e) => BuktiFotoModel.fromMap(Map<String, dynamic>.from(e as Map))).toList();
    }

    UserModel? pelaporUser;
    if (map['users'] != null) {
      pelaporUser = UserModel.fromMap(Map<String, dynamic>.from(map['users'] as Map));
    }

    return LaporanModel(
      id: map['id'] is int ? map['id'] as int : int.parse(map['id'].toString()),
      pelaporId: map['pelapor_id']?.toString() ?? '',
      namaPelapor: map['nama_pelapor']?.toString() ?? '',
      nimPelapor: map['nim_pelapor']?.toString() ?? '',
      jenis: map['jenis']?.toString() ?? '',
      lokasi: map['lokasi']?.toString() ?? '',
      tanggalKejadian: map['tanggal_kejadian'] != null 
          ? DateTime.tryParse(map['tanggal_kejadian'].toString()) ?? DateTime.now()
          : DateTime.now(),
      waktuKejadian: map['waktu_kejadian']?.toString(),
      kronologi: map['kronologi']?.toString() ?? '',
      pelaku: map['pelaku']?.toString(),
      prioritas: map['prioritas']?.toString() ?? 'Sedang',
      status: map['status']?.toString() ?? 'Menunggu Verifikasi',
      hasilMediasi: map['hasil_mediasi']?.toString(),
      tindakan: map['tindakan']?.toString(),
      catatanKaprodi: map['catatan_kaprodi']?.toString(),
      diverifikasiOleh: map['diverifikasi_oleh']?.toString(),
      diverifikasiAt: map['diverifikasi_at'] != null ? DateTime.tryParse(map['diverifikasi_at'].toString()) : null,
      ditindakOleh: map['ditindak_oleh']?.toString(),
      ditindakAt: map['ditindak_at'] != null ? DateTime.tryParse(map['ditindak_at'].toString()) : null,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      buktiFoto: buktiList,
      pelapor: pelaporUser,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pelapor_id': pelaporId,
      'nama_pelapor': namaPelapor,
      'nim_pelapor': nimPelapor,
      'jenis': jenis,
      'lokasi': lokasi,
      'tanggal_kejadian': tanggalKejadian.toIso8601String().substring(0, 10),
      'waktu_kejadian': waktuKejadian,
      'kronologi': kronologi,
      'pelaku': pelaku,
      'prioritas': prioritas,
      'status': status,
      'hasil_mediasi': hasilMediasi,
      'tindakan': tindakan,
      'catatan_kaprodi': catatanKaprodi,
      'diverifikasi_oleh': diverifikasiOleh,
      'diverifikasi_at': diverifikasiAt?.toIso8601String(),
      'ditindak_oleh': ditindakOleh,
      'ditindak_at': ditindakAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'bukti_foto': buktiFoto?.map((e) => e.toMap()).toList(),
      'users': pelapor?.toMap(),
    };
  }
}
