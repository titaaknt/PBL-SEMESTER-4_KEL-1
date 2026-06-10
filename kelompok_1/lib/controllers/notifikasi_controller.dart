import '../models/notifikasi_model.dart';
import 'supabase_client.dart';

class NotifikasiController {
  // ── AMBIL SEMUA NOTIFIKASI USER LOGIN ─────────────────
  static Future<List<NotifikasiModel>> getNotifikasi() async {
    final uid = supabase.auth.currentUser!.id;

    final data = await supabase
        .from('notifikasi')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data).map((e) => NotifikasiModel.fromMap(e)).toList();
  }

  // ── REALTIME STREAM NOTIFIKASI ────────────────────────
  // Gunakan di widget: StreamBuilder(stream: NotifikasiService.streamNotifikasi(), ...)
  static Stream<List<NotifikasiModel>> streamNotifikasi() {
    final uid = supabase.auth.currentUser!.id;

    return supabase
        .from('notifikasi')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data).map((e) => NotifikasiModel.fromMap(e)).toList());
  }

  // ── JUMLAH BELUM DIBACA (untuk badge) ─────────────────
  static Future<int> getJumlahBelumDibaca() async {
    final uid = supabase.auth.currentUser!.id;

    final res = await supabase
        .from('notifikasi')
        .select('id')
        .eq('user_id', uid)
        .eq('dibaca', false);

    return (res as List).length;
  }

  // ── TANDAI SATU NOTIFIKASI SUDAH DIBACA ───────────────
  static Future<void> tandaiBaca(int notifId) async {
    await supabase
        .from('notifikasi')
        .update({'dibaca': true})
        .eq('id', notifId);
  }

  // ── TANDAI SEMUA SUDAH DIBACA ─────────────────────────
  static Future<void> tandaiBacaSemua() async {
    final uid = supabase.auth.currentUser!.id;

    await supabase
        .from('notifikasi')
        .update({'dibaca': true})
        .eq('user_id', uid)
        .eq('dibaca', false);
  }
}
