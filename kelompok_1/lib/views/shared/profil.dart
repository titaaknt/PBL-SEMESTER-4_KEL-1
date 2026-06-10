import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});
  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  UserModel? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final p = await AuthController.getCurrentProfile();
      if (mounted) setState(() { _profile = p; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goToLogin() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _logout() async {
    await AuthController.logout();
    if (mounted) _goToLogin();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    // Fallback ke args jika profile belum load
    final String nim  = _profile?.nim  ?? args?['nim']  ?? '-';
    final String role = _profile?.role ?? args?['role'] ?? 'Mahasiswa';
    final String nama = _profile?.nama ?? args?['nama'] ?? nim;

    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.person_outline,         'label': 'Edit Profil',               'color': const Color(0xFF3B82F6)},
      {'icon': Icons.lock_outline,            'label': 'Ubah Password',             'color': const Color(0xFF8B5CF6)},
      {'icon': Icons.shield_outlined,         'label': 'Privasi & Keamanan',        'color': const Color(0xFF10B981)},
      {'icon': Icons.help_outline_rounded,    'label': 'Bantuan & FAQ',             'color': const Color(0xFF64748B)},
      {'icon': Icons.info_outline,            'label': 'Tentang Aplikasi',          'color': const Color(0xFF64748B)},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111D2C), elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Profil',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
          : RefreshIndicator(
              onRefresh: _loadProfile,
              color: const Color(0xFF3B82F6),
              backgroundColor: const Color(0xFF111D2C),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(children: [

                // ── Avatar & Info ─────────────────────────
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF1A2940)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2D4E8A)),
                  ),
                  child: Column(children: [
                    Stack(children: [
                      CircleAvatar(
                        radius: 38, backgroundColor: const Color(0xFF2563EB),
                        backgroundImage: (_profile?.fotoUrl != null && _profile!.fotoUrl!.isNotEmpty)
                            ? NetworkImage(_profile!.fotoUrl!)
                            : null,
                        child: (_profile?.fotoUrl == null || _profile!.fotoUrl!.isEmpty)
                            ? Text(
                                nama.isNotEmpty ? nama[0].toUpperCase() : 'U',
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
                              )
                            : null,
                      ),
                      Positioned(bottom: 0, right: 0,
                        child: Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981), shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF1A2940), width: 2),
                          ),
                          child: const Icon(Icons.check, size: 12, color: Colors.white),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    Text(nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 2),
                    if (role == 'Mahasiswa') ...[
                      Text('NIM: $nim', style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      const SizedBox(height: 4),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.5)),
                      ),
                      child: Text(role,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF93C5FD))),
                    ),
                  ]),
                ),
                const SizedBox(height: 24),

                // ── Menu ─────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2940), borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2D3E55)),
                  ),
                  child: Column(
                    children: List.generate(menuItems.length, (i) {
                      final item   = menuItems[i];
                      final isLast = i == menuItems.length - 1;
                      return Column(children: [
                        ListTile(
                          onTap: () {
                            if (item['label'] == 'Edit Profil') _showEditProfil(nama);
                            if (item['label'] == 'Ubah Password') _showGantiPassword();
                            if (item['label'] == 'Privasi & Keamanan') _showPrivasiKeamanan();
                            if (item['label'] == 'Bantuan & FAQ') _showBantuanFAQ();
                            if (item['label'] == 'Tentang Aplikasi') _showTentangAplikasi();
                          },
                          leading: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: (item['color'] as Color).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 18),
                          ),
                          title: Text(item['label'],
                              style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
                          trailing: const Icon(Icons.chevron_right, color: Color(0xFF64748B), size: 18),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        ),
                        if (!isLast) const Divider(height: 1, color: Color(0xFF2D3E55), indent: 16, endIndent: 16),
                      ]);
                    }),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Logout ────────────────────────────────
                SizedBox(
                  width: double.infinity, height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Keluar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),

                const Text('SafeCampus v1.0.0 · Politeknik Negeri Malang',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                const SizedBox(height: 20),
              ]),
            ),
          ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2940),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: const Text('Kamu akan keluar dari akun ini. Yakin ingin melanjutkan?',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B)))),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); _logout(); },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _showGantiPassword() {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final newPass = newPassCtrl.text;
          final isLong = newPass.length >= 8;
          final hasLetters = newPass.contains(RegExp(r'[A-Za-z]'));
          final hasDigits = newPass.contains(RegExp(r'[0-9]'));
          final score = (isLong ? 1 : 0) + (hasLetters ? 1 : 0) + (hasDigits ? 1 : 0);
          
          Color barColor = Colors.red;
          String strength = 'Lemah';
          if (score == 3) {
            barColor = Colors.green;
            strength = 'Kuat';
          } else if (score == 2) {
            barColor = Colors.orange;
            strength = 'Sedang';
          }

          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              left: 20, right: 20, top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 20),
                  const Text('Ubah Kata Sandi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: oldPassCtrl,
                    obscureText: obscureOld,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: _buildPasswordInputDeco(
                      hint: 'Kata Sandi Lama',
                      prefixIcon: Icons.lock_outline,
                      obscureText: obscureOld,
                      onToggle: () => setModalState(() => obscureOld = !obscureOld),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showLupaPasswordInfo(),
                      child: const Text('Lupa Sandi?', style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 12)),
                    ),
                  ),
                  
                  TextField(
                    controller: newPassCtrl,
                    obscureText: obscureNew,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    onChanged: (val) => setModalState(() {}),
                    decoration: _buildPasswordInputDeco(
                      hint: 'Kata Sandi Baru',
                      prefixIcon: Icons.lock_open_outlined,
                      obscureText: obscureNew,
                      onToggle: () => setModalState(() => obscureNew = !obscureNew),
                    ),
                  ),
                  if (newPass.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Kekuatan: $strength', style: TextStyle(color: barColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: score / 3,
                      backgroundColor: const Color(0xFF334155),
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      minHeight: 4,
                    ),
                  ],
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: confirmPassCtrl,
                    obscureText: obscureConfirm,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: _buildPasswordInputDeco(
                      hint: 'Ulangi Kata Sandi Baru',
                      prefixIcon: Icons.gpp_good_outlined,
                      obscureText: obscureConfirm,
                      onToggle: () => setModalState(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '* Tips: Minimal 8 karakter, kombinasi huruf & angka.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: saving ? null : () async {
                        final old = oldPassCtrl.text.trim();
                        final newP = newPassCtrl.text;
                        if (old.isEmpty || newP.length < 8) {
                          _showSnackBar('Lengkapi sandi (min. 8 karakter)', Colors.red);
                          return;
                        }
                        if (newP != confirmPassCtrl.text) {
                          _showSnackBar('Konfirmasi sandi tidak cocok', Colors.red);
                          return;
                        }
                        setModalState(() => saving = true);
                        try {
                          await AuthController.gantiPassword(newP);
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            if (mounted) _showSnackBar('Sandi berhasil diubah', Colors.green);
                          }
                        } catch (e) {
                          setModalState(() => saving = false);
                          _showSnackBar('Gagal: $e', Colors.red);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: saving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Simpan Sandi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditProfil(String currentNama) {
    final namaCtrl = TextEditingController(text: currentNama);
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 20, right: 20, top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 20),
                const Text('Edit Detail Profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 20),
                
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: const Color(0xFF2563EB),
                        backgroundImage: (_profile?.fotoUrl != null && _profile!.fotoUrl!.isNotEmpty)
                            ? NetworkImage(_profile!.fotoUrl!)
                            : null,
                        child: (_profile?.fotoUrl == null || _profile!.fotoUrl!.isEmpty)
                            ? Text(
                                namaCtrl.text.isNotEmpty ? namaCtrl.text[0].toUpperCase() : 'U',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 28),
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                              if (picked == null) return;

                              setModalState(() => saving = true);
                              try {
                                final url = await AuthController.updateProfilePhoto(picked);
                                if (url != null) {
                                  await _loadProfile();
                                  setModalState(() {});
                                  _showSnackBar('Foto profil berhasil diubah', Colors.green);
                                } else {
                                  _showSnackBar('Gagal mengunggah foto', Colors.red);
                                }
                              } catch (e) {
                                _showSnackBar('Gagal: $e', Colors.red);
                              } finally {
                                setModalState(() => saving = false);
                              }
                            },
                            child: const Text('Ubah Foto', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () async {
                              setModalState(() => saving = true);
                              try {
                                await AuthController.deleteProfilePhoto();
                                await _loadProfile();
                                setModalState(() {});
                                _showSnackBar('Foto berhasil dihapus', Colors.red);
                              } catch (e) {
                                _showSnackBar('Gagal: $e', Colors.red);
                              } finally {
                                setModalState(() => saving = false);
                              }
                            },
                            child: const Text('Hapus', style: TextStyle(color: Color(0xFFEF4444), fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                
                TextField(
                  controller: namaCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  onChanged: (text) => setModalState(() {}),
                  decoration: _buildInputDeco('Nama Lengkap', Icons.person_outline),
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: saving ? null : () async {
                      final newNama = namaCtrl.text.trim();
                      if (newNama.isEmpty) {
                        _showSnackBar('Nama tidak boleh kosong', Colors.red);
                        return;
                      }
                      setModalState(() => saving = true);
                      try {
                        await AuthController.updateProfil(nama: newNama);
                        await _loadProfile();
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          if (mounted) _showSnackBar('Profil berhasil diperbarui', Colors.green);
                        }
                      } catch (e) {
                        setModalState(() => saving = false);
                        _showSnackBar('Gagal: $e', Colors.red);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _showPrivasiKeamanan() {
    bool permCamera = true;
    bool permLocation = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              const Text('Privasi & Keamanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  children: [
                    _buildNotifSwitchTile(
                      icon: Icons.camera_alt_outlined,
                      iconColor: const Color(0xFF3B82F6),
                      title: 'Akses Kamera',
                      subtitle: 'Gunakan kamera untuk bukti kasus',
                      value: permCamera,
                      onChanged: (val) => setModalState(() => permCamera = val),
                    ),
                    const Divider(color: Color(0xFF334155), height: 1, indent: 56),
                    _buildNotifSwitchTile(
                      icon: Icons.pin_drop_outlined,
                      iconColor: const Color(0xFF10B981),
                      title: 'Akses Lokasi GPS',
                      subtitle: 'Catat koordinat kejadian bullying',
                      value: permLocation,
                      onChanged: (val) => setModalState(() => permLocation = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              ListTile(
                onTap: () => _showDeleteAccountDialog(),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.delete_forever_outlined, color: Colors.red, size: 20),
                ),
                title: const Text('Hapus Akun Permanen', style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text('Hapus data & profil dari SafeCampus secara permanen', style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFF64748B), size: 18),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2940),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 10),
            Text('Hapus Akun Permanen?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Tindakan ini tidak dapat dibatalkan. Seluruh profil, laporan kasus, data bukti, dan korespondensi Anda akan dihapus secara permanen dari server SafeCampus. Yakin ingin melanjutkan?',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Permintaan penghapusan akun sedang diproses admin', const Color(0xFFEF4444));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus Akun'),
          ),
        ],
      ),
    );
  }

  void _showBantuanFAQ() {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final String role = _profile?.role ?? args?['role'] ?? 'Mahasiswa';

    final List<Map<String, String>> faqs;

    if (role == 'Admin') {
      faqs = [
        {'q': 'Apa tugas utama Admin Satgas?', 'a': 'Memverifikasi keabsahan laporan masuk, memeriksa kevalidan bukti (foto/video), dan mengubah status laporan menjadi \'Diproses\' atau \'Tidak Valid\'.'},
        {'q': 'Bagaimana cara memverifikasi laporan baru?', 'a': 'Pilih laporan berstatus \'Menunggu Verifikasi\', tinjau kronologi dan bukti. Klik \'Verifikasi Laporan\' jika bukti valid untuk mengubah status menjadi \'Diproses\'.'},
        {'q': 'Kapan laporan ditandai sebagai \'Tidak Valid\'?', 'a': 'Jika laporan berisi informasi palsu, tidak masuk akal, bukti tidak relevan/kosong, atau tidak memenuhi unsur perundungan.'},
        {'q': 'Apakah Admin bisa melihat identitas pelapor?', 'a': 'Ya, Admin dapat melihat nama dan NIM pelapor untuk kebutuhan validasi laporan dan menghubungi pelapor jika diperlukan.'},
        {'q': 'Apakah tindakan Admin langsung terkirim ke Kaprodi?', 'a': 'Ya, setelah laporan diverifikasi (status \'Diproses\'), laporan tersebut otomatis muncul di dashboard Kaprodi untuk ditindaklanjuti.'},
        {'q': 'Bagaimana cara mengelola akun pengguna?', 'a': 'Pengelolaan akun dan pendaftaran pengguna baru dilakukan melalui database Supabase atau konsol administrasi yang disediakan.'},
        {'q': 'Berapa batas waktu verifikasi laporan?', 'a': 'Sesuai SOP SafeCampus, verifikasi laporan masuk diselesaikan maksimal dalam 1x24 jam setelah laporan dikirim.'},
        {'q': 'Apakah Admin bisa menghapus laporan secara permanen?', 'a': 'Demi integritas data, Admin hanya bisa mengubah status laporan menjadi \'Tidak Valid\'. Penghapusan permanen hanya dapat dilakukan oleh database administrator.'},
      ];
    } else if (role == 'Kaprodi') {
      faqs = [
        {'q': 'Apa tugas utama Kaprodi dalam penanganan kasus?', 'a': 'Menindaklanjuti laporan yang telah diverifikasi Admin dengan melakukan investigasi, mediasi, menetapkan tindakan/sanksi, dan menyelesaikan status laporan.'},
        {'q': 'Bagaimana cara memberikan tindak lanjut laporan?', 'a': 'Pilih laporan di dashboard, klik \'Tindak Lanjut\', isi deskripsi tindakan yang diambil (misal: mediasi/sanksi) dan catatan penyelesaian, lalu ubah status menjadi \'Selesai\'.'},
        {'q': 'Siapa saja yang terlibat dalam proses mediasi?', 'a': 'Mediasi melibatkan korban, pelaku, saksi (jika ada), tim Satgas Anti-Perundungan, serta dosen pembina/bimbingan konseling jika diperlukan.'},
        {'q': 'Apa perbedaan status \'Diproses\' dan \'Selesai\'?', 'a': 'Status \'Diproses\' berarti kasus sedang diinvestigasi oleh Kaprodi. Status \'Selesai\' berarti tindakan pemulihan/sanksi telah disepakati dan diimplementasikan.'},
        {'q': 'Bagaimana jika laporan ternyata terbukti salah sasaran?', 'a': 'Kaprodi dapat mengubah status laporan menjadi \'Tidak Valid\' setelah dilakukan pemeriksaan internal dan memberikan catatan penjelasan.'},
        {'q': 'Apakah mahasiswa pelapor mendapat notifikasi hasil tindak lanjut?', 'a': 'Ya, sistem secara otomatis mengirimkan pembaruan status dan catatan tindak lanjut dari Kaprodi kepada mahasiswa yang bersangkutan.'},
        {'q': 'Bagaimana cara melihat riwayat kasus yang sudah selesai?', 'a': 'Gunakan filter status \'Selesai\' pada dashboard Kaprodi untuk melihat seluruh arsip laporan penanganan kasus yang telah diselesaikan.'},
        {'q': 'Apakah laporan yang sudah selesai bisa dibuka kembali?', 'a': 'Arsip kasus berstatus \'Selesai\' bersifat final untuk melindungi privasi. Kasus baru harus dilaporkan kembali jika terjadi insiden berulang.'},
      ];
    } else {
      faqs = [
        {'q': 'Bagaimana cara melapor perundungan?', 'a': 'Klik tombol "+" di dashboard, isi jenis perundungan, kronologi kejadian, dan lampirkan bukti foto.'},
        {'q': 'Apakah identitas pelapor aman?', 'a': 'Sangat aman. Identitas Anda dienkripsi penuh di database dan dirahasiakan oleh pihak kampus.'},
        {'q': 'Berapa lama laporan diproses?', 'a': 'Proses verifikasi oleh Admin memakan waktu maksimal 1x24 jam sebelum diteruskan ke Kaprodi.'},
        {'q': 'Apakah saya bisa melapor secara anonim?', 'a': 'Pelaporan memerlukan login akun untuk validasi data, namun identitas Anda dijamin aman dan hanya diakses oleh pihak berwenang.'},
        {'q': 'Bagaimana jika laporan saya ditolak?', 'a': 'Laporan dapat ditolak jika bukti kurang memadai atau informasi tidak valid. Anda akan mendapat notifikasi beserta alasannya.'},
        {'q': 'Siapa saja yang dapat melihat laporan saya?', 'a': 'Hanya pelapor (Anda sendiri), Admin Satgas, dan Kepala Program Studi (Kaprodi) yang memiliki akses untuk meninjau laporan Anda.'},
        {'q': 'Apakah saya bisa mengunggah bukti selain foto?', 'a': 'Saat ini aplikasi mendukung unggahan bukti berupa gambar atau tangkapan layar (screenshot) untuk mempermudah verifikasi cepat.'},
        {'q': 'Bagaimana cara memantau status laporan?', 'a': 'Anda dapat memantau status penanganan kasus secara berkala langsung melalui menu Laporan Saya di dashboard.'},
      ];
    }

    String query = '';
    int expandedIndex = -1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => StatefulBuilder(
          builder: (ctx, setModalState) {
            final filtered = faqs.where((f) => f['q']!.toLowerCase().contains(query.toLowerCase()) || f['a']!.toLowerCase().contains(query.toLowerCase())).toList();
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 20),
                  const Text('Bantuan & FAQ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  
                  TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    onChanged: (val) => setModalState(() => query = val),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      hintText: 'Cari bantuan...',
                      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B), size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: filtered.length,
                      itemBuilder: (ctx, idx) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildFAQItem(
                          index: idx,
                          expandedIndex: expandedIndex,
                          question: filtered[idx]['q']!,
                          answer: filtered[idx]['a']!,
                          onTap: (i) => setModalState(() => expandedIndex = expandedIndex == i ? -1 : i),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showTentangAplikasi() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
              child: const Icon(Icons.security_outlined, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('SafeCampus', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const Text('Version 1.0.0 (Build 2026.0603)', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            const Text(
              'SafeCampus adalah platform pelaporan perundungan (bullying) dan kekerasan yang aman, terpercaya, dan rahasia untuk civitas akademika Politeknik Negeri Malang.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), height: 1.5),
            ),
            const SizedBox(height: 24),
            const Divider(color: Color(0xFF334155), height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Developer', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                Text('Kelompok 1 - SIB 2A Polinema', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required int index,
    required int expandedIndex,
    required String question,
    required String answer,
    required ValueChanged<int> onTap,
  }) {
    final bool isExpanded = index == expandedIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isExpanded ? const Color(0xFF1E293B) : const Color(0xFF0D1B2A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isExpanded ? const Color(0xFF3B82F6) : const Color(0xFF2D3E55)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.quiz_outlined,
                  color: isExpanded ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isExpanded ? Colors.white : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF64748B),
                  size: 20,
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 12),
              const Divider(color: Color(0xFF334155), height: 1),
              const SizedBox(height: 12),
              Text(
                answer,
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), height: 1.6),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showLupaPasswordInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2940),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: Color(0xFF8B5CF6)),
            SizedBox(width: 10),
            Text('Lupa Kata Sandi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Untuk mereset kata sandi Anda, silakan hubungi Administrator IT SafeCampus atau kunjungi Kantor Pelayanan IT di Gedung Sipil Lantai 2 Politeknik Negeri Malang dengan membawa KTM Anda.',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDeco(String hint, IconData prefixIcon) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF64748B), size: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  InputDecoration _buildPasswordInputDeco({
    required String hint,
    required IconData prefixIcon,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF64748B), size: 18),
      suffixIcon: IconButton(
        icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF64748B), size: 18),
        onPressed: onToggle,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Widget _buildNotifSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: iconColor,
        activeTrackColor: iconColor.withValues(alpha: 0.3),
        inactiveThumbColor: const Color(0xFF64748B),
        inactiveTrackColor: const Color(0xFF334155),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 13, color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}