// lib/login.dart
// Tampilan: "Selamat Datang" dengan toggle Masuk/Daftar di bawah
// Keamanan role:
//   - Form Daftar: hanya Mahasiswa
//   - Form Masuk : role diambil dari DB, bukan pilihan user
//   - Trigger handle_new_user() insert row lengkap dari metadata

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // ── Logo ──
              SizedBox(
                width: 90,
                height: 90,
                child: CustomPaint(painter: _LogoPainter()),
              ),
              const SizedBox(height: 20),

              // ── Judul ──
              const Text(
                'Selamat Datang',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _tabCtrl.index == 0
                    ? 'Pilih peran & masuk dengan NIM'
                    : 'Daftar akun baru sebagai mahasiswa',
                style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 36),

              // ── Konten form ──
              IndexedStack(
                index: _tabCtrl.index,
                children: const [_LoginForm(), _RegisterForm()],
              ),

              const SizedBox(height: 20),

              // ── Toggle Masuk / Daftar di bawah ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _tabCtrl.index == 0
                        ? 'Belum punya akun? '
                        : 'Sudah punya akun? ',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _tabCtrl.animateTo(_tabCtrl.index == 0 ? 1 : 0);
                    },
                    child: Text(
                      _tabCtrl.index == 0 ? 'Daftar sekarang' : 'Masuk di sini',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF3B82F6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// FORM LOGIN
// ══════════════════════════════════════════════════════════
class _LoginForm extends StatefulWidget {
  const _LoginForm();
  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _nimCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _pilihanRole;

  final _roles = [
    {
      'label': 'Mahasiswa',
      'subtitle': 'Pelapor / Korban',
      'icon': Icons.school_outlined,
    },
    {
      'label': 'Admin',
      'subtitle': 'Verifikasi laporan',
      'icon': Icons.admin_panel_settings_outlined,
    },
    {
      'label': 'Kaprodi',
      'subtitle': 'Tinjauan hasil',
      'icon': Icons.supervisor_account_outlined,
    },
  ];

  @override
  void dispose() {
    _nimCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_pilihanRole == null) {
      _snack('Pilih peran terlebih dahulu');
      return;
    }
    final nim = _nimCtrl.text.trim();
    final pass = _passCtrl.text;
    if (nim.isEmpty) {
      _snack('NIM tidak boleh kosong');
      return;
    }
    if (pass.isEmpty) {
      _snack('Password tidak boleh kosong');
      return;
    }

    setState(() => _loading = true);

    try {
      // 1. Cari email & role dari NIM melalui AuthController
      final user = await AuthController.getUserByNim(nim);

      if (user == null) {
        _snack('NIM tidak ditemukan. Silakan daftar terlebih dahulu.');
        setState(() => _loading = false);
        return;
      }

      final email = user.email?.trim() ?? '';
      if (email.isEmpty) {
        _snack('Data akun belum lengkap. Hubungi administrator.');
        setState(() => _loading = false);
        return;
      }

      // 2. Login Supabase Auth melalui AuthController
      final profile = await AuthController.login(
        email: email,
        password: pass,
      );

      if (profile == null) {
        _snack('Password salah.');
        setState(() => _loading = false);
        return;
      }

      // 3. Ambil role dari profile — BUKAN dari pilihan UI
      final dbRole = profile.role;

      // 4. Cocokkan pilihan UI dengan role DB
      if (dbRole != _pilihanRole) {
        await AuthController.logout();
        _snack('Akun ini terdaftar sebagai $dbRole, bukan $_pilihanRole.');
        setState(() => _loading = false);
        return;
      }

      if (!mounted) return;

      // 5. Navigasi sesuai role
      final args = {
        'nim': profile.nim,
        'nama': profile.nama,
        'role': dbRole,
      };

      if (!mounted) return;

      if (dbRole == 'Admin') {
        Navigator.pushReplacementNamed(
          context,
          '/dashboard-admin',
          arguments: args,
        );
      } else if (dbRole == 'Kaprodi') {
        Navigator.pushReplacementNamed(
          context,
          '/dashboard-kaprodi',
          arguments: args,
        );
      } else {
        Navigator.pushReplacementNamed(context, '/dashboard', arguments: args);
      }
    } on AuthException catch (e) {
      _snack(_authErr(e.message));
      setState(() => _loading = false);
    } catch (e) {
      _snack('Terjadi kesalahan. Coba lagi.');
      setState(() => _loading = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _authErr(String m) {
    if (m.contains('Invalid login credentials')) return 'Password salah.';
    if (m.contains('Email not confirmed')) return 'Email belum dikonfirmasi.';
    return m;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Pilihan role ──
        scLabel('Masuk sebagai:'),
        const SizedBox(height: 10),
        Row(
          children: List.generate(_roles.length, (i) {
            final r = _roles[i];
            final sel = _pilihanRole == r['label'];
            return Expanded(
              child: GestureDetector(
                onTap: () =>
                    setState(() => _pilihanRole = r['label'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: EdgeInsets.only(right: i < _roles.length - 1 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color: sel
                        ? const Color(0xFF1E3A8A)
                        : const Color(0xFF1A2940),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: sel
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFF2D3E55),
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        r['icon'] as IconData,
                        size: 24,
                        color: sel
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r['label'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: sel ? Colors.white : const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        r['subtitle'] as String,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),

        // ── Warning box Admin/Kaprodi ──
        const SizedBox(height: 10),
        if (_pilihanRole == 'Admin' || _pilihanRole == 'Kaprodi')
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF78350F).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFFF59E0B),
                  size: 14,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Akun $_pilihanRole hanya bisa digunakan jika sudah didaftarkan oleh administrator sistem.',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFFDE68A),
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),

        // ── NIM / NIP / Username field ──
        scLabel(_pilihanRole == 'Mahasiswa'
            ? 'NIM (Nomor Induk Mahasiswa)'
            : _pilihanRole == 'Kaprodi'
                ? 'NIP (Nomor Induk Pegawai)'
                : 'Username'),
        const SizedBox(height: 6),
        TextField(
          controller: _nimCtrl,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: scDeco(
            _pilihanRole == 'Mahasiswa'
                ? 'Masukkan NIM Anda'
                : _pilihanRole == 'Kaprodi'
                    ? 'Masukkan NIP (18 digit)'
                    : 'Masukkan Username Anda',
            _pilihanRole == 'Admin'
                ? Icons.person_outline
                : Icons.badge_outlined,
          ),
        ),
        const SizedBox(height: 14),

        // ── Password field ──
        scLabel('Password'),
        const SizedBox(height: 6),
        TextField(
          controller: _passCtrl,
          obscureText: _obscure,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: scDeco('Password', Icons.lock_outline).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF64748B),
                size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // ── Tombol Masuk ──
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _loading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF1E3A8A),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Masuk ke Sistem',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Info keamanan ──
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.lock_outline, size: 13, color: Color(0xFF64748B)),
              SizedBox(width: 6),
              Text(
                'Data terlindungi & rahasia',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// FORM REGISTER
// Hanya Mahasiswa. Trigger handle_new_user() sudah handle insert.
// ══════════════════════════════════════════════════════════
class _RegisterForm extends StatefulWidget {
  const _RegisterForm();
  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _namaCtrl = TextEditingController();
  final _nimCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _konfCtrl = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;

  static const String _role = 'Mahasiswa';

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nimCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _konfCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final nama = _namaCtrl.text.trim();
    final nim = _nimCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final konf = _konfCtrl.text;

    if (nama.isEmpty) {
      _snack('Nama tidak boleh kosong');
      return;
    }
    if (nim.isEmpty) {
      _snack('NIM tidak boleh kosong');
      return;
    }
    if (!RegExp(r'^\d{9,15}$').hasMatch(nim)) {
      _snack('NIM harus angka 9-15 digit');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _snack('Email tidak valid');
      return;
    }
    if (pass.length < 6) {
      _snack('Password minimal 6 karakter');
      return;
    }
    if (pass != konf) {
      _snack('Konfirmasi password tidak sama');
      return;
    }

    setState(() => _loading = true);

    try {
      // Cek NIM sudah terdaftar melalui AuthController
      final existing = await AuthController.getUserByNim(nim);

      if (existing != null) {
        _snack('NIM $nim sudah terdaftar.');
        setState(() => _loading = false);
        return;
      }

      // register via AuthController
      final user = await AuthController.register(
        nim: nim,
        nama: nama,
        password: pass,
        role: _role,
        email: email,
      );

      if (user == null) {
        _snack('Pendaftaran gagal. Coba lagi.');
        setState(() => _loading = false);
        return;
      }

      if (!mounted) return;
      setState(() => _loading = false);
      _showOk();
    } on AuthException catch (e) {
      _snack(_authErr(e.message));
      setState(() => _loading = false);
    } catch (e) {
      _snack('Terjadi kesalahan. Coba lagi.');
      setState(() => _loading = false);
    }
  }

  void _showOk() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2940),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF064E3B),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF10B981),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Akun Berhasil Dibuat!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Selamat datang di SafeCampus. Silakan masuk menggunakan NIM dan password kamu.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('OK, ke halaman Masuk'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _authErr(String m) {
    if (m.contains('already registered')) {
      return 'Email sudah terdaftar. Gunakan email lain.';
    }
    if (m.contains('weak password')) return 'Password terlalu lemah.';
    if (m.contains('invalid email')) return 'Format email tidak valid.';
    return m;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Badge info ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.school, color: Color(0xFF93C5FD), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Pendaftaran Mahasiswa',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Form ini hanya untuk mahasiswa. Akun Admin dan Kaprodi didaftarkan oleh pengelola sistem.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF93C5FD)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        scLabel('Nama Lengkap'), const SizedBox(height: 6),
        TextField(
          controller: _namaCtrl,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: scDeco('Contoh: Tania Eka Putri', Icons.person_outline),
        ),
        const SizedBox(height: 14),

        scLabel('NIM'), const SizedBox(height: 6),
        TextField(
          controller: _nimCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: scDeco('Contoh: 244107060026', Icons.badge_outlined),
        ),
        const SizedBox(height: 14),

        scLabel('Email'), const SizedBox(height: 6),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: scDeco(
            'nama@student.polinema.ac.id',
            Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Gunakan email aktif — untuk reset password jika lupa.',
          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 14),

        scLabel('Password'), const SizedBox(height: 6),
        TextField(
          controller: _passCtrl,
          obscureText: _obscure1,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: scDeco('Minimal 6 karakter', Icons.lock_outline).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscure1
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF64748B),
                size: 20,
              ),
              onPressed: () => setState(() => _obscure1 = !_obscure1),
            ),
          ),
        ),
        const SizedBox(height: 14),

        scLabel('Konfirmasi Password'), const SizedBox(height: 6),
        TextField(
          controller: _konfCtrl,
          obscureText: _obscure2,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: scDeco('Ulangi password', Icons.lock_outline).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscure2
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF64748B),
                size: 20,
              ),
              onPressed: () => setState(() => _obscure2 = !_obscure2),
            ),
          ),
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _loading ? null : _register,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF064E3B),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_outlined, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Daftar sebagai Mahasiswa',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────
Widget scLabel(String text) => Text(
  text,
  style: const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Color(0xFF94A3B8),
  ),
);

InputDecoration scDeco(String hint, IconData icon) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
  prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
  filled: true,
  fillColor: const Color(0xFF1A2940),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFF2D3E55)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFF2D3E55)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFEF4444)),
  ),
  errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
);

// ── Logo Painter ───────────────────────────────────────────
class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Dynamically scale down the paint commands from 160x160 to 90x90 (or any other size)
    final double scale = size.width / 160;
    canvas.save();
    canvas.scale(scale);

    // Center coordinates for a 160x160 boundary box
    final double cx = 80.0;
    final double cy = 80.0;

    // Shield layer 1 — navy terluar
    final paintNavy = Paint()..color = const Color(0xFF1E3A8A);
    canvas.drawPath(_shieldPath(cx, cy, 52, 68, 80), paintNavy);

    // Shield layer 2 — biru medium
    final paintMid = Paint()..color = const Color(0xFF2563EB);
    canvas.drawPath(_shieldPath(cx, cy, 43, 58, 72), paintMid);

    // Shield layer 3 — biru terang dalam
    final paintInner = Paint()..color = const Color(0xFF3B82F6);
    canvas.drawPath(_shieldPath(cx, cy, 35, 48, 63), paintInner);

    // ---- GEDUNG TENGAH (tower utama) ----
    final white    = Paint()..color = const Color(0xFFEFF6FF);
    final lightBlue = Paint()..color = const Color(0xFFBFDBFE);
    final softBlue  = Paint()..color = const Color(0xFFDBEAFE);

    // Tower utama
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 11, cy - 18, 22, 48), const Radius.circular(2)),
      white,
    );
    // Atap tower
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 11, cy - 26, 22, 10), const Radius.circular(1)),
      lightBlue,
    );

    // Sayap kiri
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 30, cy - 4, 17, 34), const Radius.circular(2)),
      softBlue,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 30, cy - 10, 17, 8), const Radius.circular(1)),
      lightBlue,
    );

    // Sayap kanan
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx + 13, cy - 4, 17, 34), const Radius.circular(2)),
      softBlue,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx + 13, cy - 10, 17, 8), const Radius.circular(1)),
      lightBlue,
    );

    // Lantai dasar
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 33, cy + 30, 66, 4), const Radius.circular(2)),
      lightBlue,
    );

    // Tiang bendera
    final flagPole = Paint()
      ..color = const Color(0xFFBFDBFE)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx + 0.5, cy - 38), Offset(cx + 0.5, cy - 26), flagPole);

    // Bendera
    final flagFill = Paint()..color = const Color(0xFFEFF6FF);
    final flag = Path()
      ..moveTo(cx + 1, cy - 38)
      ..lineTo(cx + 9, cy - 34)
      ..lineTo(cx + 1, cy - 30)
      ..close();
    canvas.drawPath(flag, flagFill);

    // Jendela tower utama
    final win = Paint()..color = const Color(0xFF2563EB).withValues(alpha: 0.7);
    for (final row in [cy - 12.0, cy - 3.0]) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(cx - 8, row, 5, 5), const Radius.circular(1)), win);
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(cx + 3, row, 5, 5), const Radius.circular(1)), win);
    }

    // Jendela sayap
    final winSm = Paint()..color = const Color(0xFF2563EB).withValues(alpha: 0.55);
    for (final row in [cy + 2.0, cy + 10.0]) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 28, row, 4, 4), const Radius.circular(1)), winSm);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 22, row, 4, 4), const Radius.circular(1)), winSm);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + 15, row, 4, 4), const Radius.circular(1)), winSm);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + 21, row, 4, 4), const Radius.circular(1)), winSm);
    }

    // Pintu
    final door = Paint()..color = const Color(0xFF1E3A8A).withValues(alpha: 0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 5, cy + 18, 10, 12), const Radius.circular(2)),
      door,
    );

    canvas.restore();
  }

  Path _shieldPath(double cx, double cy, double hw, double topOff, double botOff) {
    final p = Path();
    p.moveTo(cx, cy - topOff);
    p.lineTo(cx + hw, cy - topOff + 26);
    p.lineTo(cx + hw, cy + 22);
    p.quadraticBezierTo(cx + hw, cy + botOff, cx, cy + botOff + 17);
    p.quadraticBezierTo(cx - hw, cy + botOff, cx - hw, cy + 22);
    p.lineTo(cx - hw, cy - topOff + 26);
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}
