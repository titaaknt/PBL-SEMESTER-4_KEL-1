import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import 'supabase_client.dart';

class AuthController {
  // ── GET USER BY NIM (Dipakai di Login View untuk fetch email & role) ──
  static Future<UserModel?> getUserByNim(String nim) async {
    final row = await supabase
        .from('users')
        .select()
        .eq('nim', nim)
        .maybeSingle();
    if (row == null) return null;
    return UserModel.fromMap(row);
  }

  // ── LOGIN ──────────────────────────────────────────────
  static Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    final AuthResponse res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (res.user == null) return null;

    // Ambil data profil user dari tabel public.users
    final profile = await supabase
        .from('users')
        .select()
        .eq('id', res.user!.id)
        .single();

    return UserModel.fromMap(profile);
  }

  // ── REGISTER (dipakai saat setup awal / admin buat akun) ──
  static Future<UserModel?> register({
    required String nim,
    required String nama,
    required String password,
    required String role, // 'Mahasiswa' | 'Admin' | 'Kaprodi'
    String? email,
  }) async {
    final signUpEmail = email ?? '${nim.trim()}@safecampus.ac.id';

    final AuthResponse res = await supabase.auth.signUp(
      email: signUpEmail,
      password: password,
      data: {'nim': nim, 'nama': nama, 'role': role},
    );

    if (res.user == null) return null;

    // Insert ke tabel public.users
    final profile = await supabase.from('users').insert({
      'id': res.user!.id,
      'nim': nim.trim(),
      'nama': nama.trim(),
      'role': role,
      'email': signUpEmail,
    }).select().single();

    return UserModel.fromMap(profile);
  }

  // ── LOGOUT ─────────────────────────────────────────────
  static Future<void> logout() async {
    await supabase.auth.signOut();
  }

  // ── SESSION AKTIF ──────────────────────────────────────
  static User? get currentUser => supabase.auth.currentUser;

  // ── PROFIL USER LOGIN ──────────────────────────────────
  static Future<UserModel?> getCurrentProfile() async {
    final uid = currentUser?.id;
    if (uid == null) return null;

    final profile = await supabase
        .from('users')
        .select()
        .eq('id', uid)
        .single();
    return UserModel.fromMap(profile);
  }

  // ── UPDATE PROFIL ──────────────────────────────────────
  static Future<void> updateProfil({
    required String nama,
    String? fotoUrl,
  }) async {
    final uid = currentUser?.id;
    if (uid == null) return;

    await supabase.from('users').update({
      'nama': nama,
      'foto_url': fotoUrl,
    }).eq('id', uid);
  }

  // ── UPDATE PROFILE PHOTO ───────────────────────────────
  static Future<String?> updateProfilePhoto(XFile file) async {
    final uid = currentUser?.id;
    if (uid == null) return null;

    final ext = file.name.split('.').last;
    final path = 'profiles/${uid}_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final bytes = await file.readAsBytes();

    await supabase.storage
        .from('bukti-laporan')
        .uploadBinary(path, bytes);

    final url = supabase.storage.from('bukti-laporan').getPublicUrl(path);

    await supabase.from('users').update({
      'foto_url': url,
    }).eq('id', uid);

    return url;
  }

  // ── DELETE PROFILE PHOTO ───────────────────────────────
  static Future<void> deleteProfilePhoto() async {
    final uid = currentUser?.id;
    if (uid == null) return;

    await supabase.from('users').update({
      'foto_url': null,
    }).eq('id', uid);
  }

  // ── GANTI PASSWORD ─────────────────────────────────────
  static Future<void> gantiPassword(String newPassword) async {
    await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}