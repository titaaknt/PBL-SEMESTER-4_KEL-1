import 'package:image_picker/image_picker.dart';
import '../models/laporan_model.dart';
import 'supabase_client.dart';

class LaporanController {

  // ── SUBMIT LAPORAN BARU (Mahasiswa) ───────────────────
  static Future<LaporanModel> submitLaporan({
    required String namaPelapor,
    required String nimPelapor,
    required String jenis,         // enum: Verbal|Fisik|Cyberbullying|Seksual
    required String lokasi,
    required DateTime tanggalKejadian,
    String?  waktuKejadian,        // format "HH:mm"
    required String kronologi,
    String?  pelaku,
    List<XFile> buktiFotos = const [],
    XFile? buktiVideo,             // ← DITAMBAHKAN: opsi video
  }) async {
    final uid = supabase.auth.currentUser!.id;

    // 1. Insert laporan (kode di-generate otomatis oleh trigger DB)
    final laporanMap = await supabase.from('laporan').insert({
      'pelapor_id'      : uid,
      'nama_pelapor'    : namaPelapor,
      'nim_pelapor'     : nimPelapor,
      'jenis'           : jenis,
      'lokasi'          : lokasi,
      'tanggal_kejadian': tanggalKejadian.toIso8601String().substring(0, 10),
      'waktu_kejadian'  : waktuKejadian,
      'kronologi'       : kronologi,
      'pelaku'          : pelaku,
      'prioritas'       : _hitungPrioritas(jenis),
    }).select().single();

    final laporanId = laporanMap['id'] as int;

    // 2. Upload foto bukti (jika ada)
    for (int i = 0; i < buktiFotos.length; i++) {
      final file    = buktiFotos[i];
      final ext     = file.name.split('.').last;
      final path    = 'laporan/$laporanId/bukti_$i.$ext';
      
      final bytes   = await file.readAsBytes();

      await supabase.storage
          .from('bukti-laporan')
          .uploadBinary(path, bytes);

      final url = supabase.storage.from('bukti-laporan').getPublicUrl(path);

      await supabase.from('bukti_foto').insert({
        'laporan_id': laporanId,
        'url'       : url,
      });
    }

    // 3. Upload video bukti (jika ada)
    if (buktiVideo != null) {
      final ext   = buktiVideo.name.split('.').last;
      final path  = 'laporan/$laporanId/video_${DateTime.now().millisecondsSinceEpoch}.$ext';
      
      final bytes = await buktiVideo.readAsBytes();

      await supabase.storage
          .from('bukti-laporan')
          .uploadBinary(path, bytes);

      final url = supabase.storage.from('bukti-laporan').getPublicUrl(path);

      await supabase.from('bukti_foto').insert({
        'laporan_id': laporanId,
        'url'       : url,
      });
    }

    // Fetch the complete inserted model (with attachments and joins if needed)
    final fullMap = await supabase
        .from('laporan')
        .select('*, bukti_foto(*)')
        .eq('id', laporanId)
        .single();

    return LaporanModel.fromMap(fullMap);
  }

  // ── LAPORAN MILIK MAHASISWA ───────────────────────────
  static Future<List<LaporanModel>> getLaporanSaya() async {
    final uid = supabase.auth.currentUser!.id;

    final data = await supabase
        .from('laporan')
        .select('*, bukti_foto(*)')
        .eq('pelapor_id', uid)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data).map((e) => LaporanModel.fromMap(e)).toList();
  }

  // ── SEMUA LAPORAN (Admin) ─────────────────────────────
  static Future<List<LaporanModel>> getAllLaporan({
    String? filterStatus,
  }) async {
    var query = supabase
        .from('laporan')
        .select('*, bukti_foto(*), users!laporan_pelapor_id_fkey(nama, nim)');

    if (filterStatus != null && filterStatus != 'Semua') {
      query = query.eq('status', filterStatus) as dynamic;
    }

    final data = await (query as dynamic).order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data).map((e) => LaporanModel.fromMap(e)).toList();
  }

  // ── LAPORAN KAPRODI (Diproses + Selesai) ─────────────
  static Future<List<LaporanModel>> getLaporanKaprodi({
    String? filterStatus,
  }) async {
    var query = supabase
        .from('laporan')
        .select('*, bukti_foto(*), users!laporan_pelapor_id_fkey(nama, nim)')
        .inFilter('status', ['Diproses', 'Selesai', 'Tidak Valid']);

    if (filterStatus != null && filterStatus != 'Semua') {
      query = query.eq('status', filterStatus) as dynamic;
    }

    final data = await (query as dynamic).order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data).map((e) => LaporanModel.fromMap(e)).toList();
  }

  // ── DETAIL LAPORAN ────────────────────────────────────
  static Future<LaporanModel> getDetailLaporan(int id) async {
    final data = await supabase
        .from('laporan')
        .select('*, bukti_foto(*), users!laporan_pelapor_id_fkey(nama, nim)')
        .eq('id', id)
        .single();
    return LaporanModel.fromMap(data);
  }

  // ── VERIFIKASI (Admin → ubah ke Diproses) ─────────────
  static Future<void> verifikasiLaporan(int id) async {
    final uid = supabase.auth.currentUser!.id;

    await supabase.from('laporan').update({
      'status'            : 'Diproses',
      'diverifikasi_oleh' : uid,
      'diverifikasi_at'   : DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  // ── TOLAK LAPORAN (Admin → ubah ke Tidak Valid) ────────
  static Future<void> tolakLaporan(int id) async {
    final uid = supabase.auth.currentUser!.id;

    await supabase.from('laporan').update({
      'status'            : 'Tidak Valid',
      'diverifikasi_oleh' : uid,
      'diverifikasi_at'   : DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  // ── INPUT HASIL PENANGANAN / MEDIASI (Admin) ─────────
  static Future<void> inputHasilMediasi(int id, String hasil) async {
    await supabase.from('laporan').update({
      'hasil_mediasi': hasil,
    }).eq('id', id);
  }

  // ── TINDAK LANJUT (Kaprodi) ───────────────────────────
  static Future<void> tindakLanjutLaporan({
    required int    id,
    required String status,   // 'Selesai' | 'Tidak Valid' | 'Diproses'
    required String tindakan,
    String?         catatan,
  }) async {
    final uid = supabase.auth.currentUser!.id;

    await supabase.from('laporan').update({
      'status'         : status,
      'tindakan'       : tindakan,
      'catatan_kaprodi': catatan,
      'ditindak_oleh'  : uid,
      'ditindak_at'    : DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  // ── REALTIME STREAM semua laporan (Admin dashboard) ───
  static Stream<List<LaporanModel>> streamAllLaporan() {
    return supabase
        .from('laporan')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data).map((e) => LaporanModel.fromMap(e)).toList());
  }

  // ── REALTIME STREAM laporan mahasiswa ─────────────────
  static Stream<List<LaporanModel>> streamLaporanSaya() {
    final uid = supabase.auth.currentUser!.id;
    return supabase
        .from('laporan')
        .stream(primaryKey: ['id'])
        .eq('pelapor_id', uid)
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data).map((e) => LaporanModel.fromMap(e)).toList());
  }

  // ── HELPER: prioritas berdasarkan jenis ───────────────
  static String _hitungPrioritas(String jenis) {
    switch (jenis) {
      case 'Seksual':
      case 'Fisik':
        return 'Tinggi';
      case 'Cyberbullying':
        return 'Sedang';
      default:
        return 'Sedang';
    }
  }
}