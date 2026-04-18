import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nimController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _selectedRole;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _roles = [
    {'label': 'Mahasiswa', 'subtitle': 'Pelapor / Korban', 'icon': Icons.school},
    {'label': 'Admin', 'subtitle': 'Verifikasi laporan', 'icon': Icons.admin_panel_settings},
    {'label': 'Kaprodi', 'subtitle': 'Tinjauan hasil', 'icon': Icons.supervisor_account},
  ];

  // -------------------------------------------------------
  // NAVIGATION METHODS
  // -------------------------------------------------------
  void _goToDashboardMahasiswa() {
    Navigator.pushReplacementNamed(
      context,
      '/dashboard',
      arguments: {
        'role': _selectedRole,
        'nim': _nimController.text.trim().isNotEmpty
            ? _nimController.text.trim()
            : 'Pengguna',
      },
    );
  }

  void _goToDashboardAdmin() {
    Navigator.pushReplacementNamed(
      context,
      '/dashboard-admin',
      arguments: {
        'role': _selectedRole,
        'nim': _nimController.text.trim().isNotEmpty
            ? _nimController.text.trim()
            : 'Admin',
      },
    );
  }

  void _goToDashboardKaprodi() {
    Navigator.pushReplacementNamed(
      context,
      '/dashboard-kaprodi',
      arguments: {
        'role': _selectedRole,
        'nim': _nimController.text.trim().isNotEmpty
            ? _nimController.text.trim()
            : 'Kaprodi',
      },
    );
  }

  // -------------------------------------------------------

  void _submit() {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih peran terlebih dahulu'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (_selectedRole == 'Admin') {
        _goToDashboardAdmin();
      } else if (_selectedRole == 'Kaprodi') {
        _goToDashboardKaprodi();
      } else {
        _goToDashboardMahasiswa();
      }
    });
  }

  @override
  void dispose() {
    _nimController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CustomPaint(
                          painter: _PolimenaLoginLogoPainter(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Selamat Datang',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Pilih peran & masuk dengan NIM',
                        style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Masuk sebagai:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 12),
                // Role Row
                Row(
                  children: _roles.map((role) {
                    final isSelected = _selectedRole == role['label'];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = role['label']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(
                            right: role == _roles.last ? 0 : 8,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1E3A8A)
                                : const Color(0xFF1A2940),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFF2D3E55),
                              width: 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                                      blurRadius: 10,
                                    )
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                role['icon'] as IconData,
                                size: 24,
                                color: isSelected
                                    ? const Color(0xFF3B82F6)
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                role['label'],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                role['subtitle'],
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF64748B),
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // NIM Field
                TextFormField(
                  controller: _nimController,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: _inputDecoration('NIM / Username', Icons.badge_outlined),
                ),
                const SizedBox(height: 14),
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: _inputDecoration(
                    'Password',
                    Icons.lock_outline,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: const Color(0xFF64748B),
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
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
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock, size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      const Text(
                        'Data terlindungi & rahasia',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
      filled: true,
      fillColor: const Color(0xFF1A2940),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
    );
  }
}

// -------------------------------------------------------
// Custom Painter: Logo Polinema Shield (versi kecil login)
// -------------------------------------------------------
class _PolimenaLoginLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

    Path shield(double hw, double topOff, double botOff) {
      final p = Path();
      p.moveTo(cx, cy - topOff);
      p.lineTo(cx + hw, cy - topOff + 14);
      p.lineTo(cx + hw, cy + 10);
      p.quadraticBezierTo(cx + hw, cy + botOff, cx, cy + botOff + 9);
      p.quadraticBezierTo(cx - hw, cy + botOff, cx - hw, cy + 10);
      p.lineTo(cx - hw, cy - topOff + 14);
      p.close();
      return p;
    }

    canvas.drawPath(shield(30, 34, 40), Paint()..color = const Color(0xFF1E3A8A));
    canvas.drawPath(shield(25, 28, 34), Paint()..color = const Color(0xFF2563EB));
    canvas.drawPath(shield(20, 23, 28), Paint()..color = const Color(0xFF3B82F6));

    final white = Paint()..color = const Color(0xFFEFF6FF);
    final lb    = Paint()..color = const Color(0xFFBFDBFE);
    final sb    = Paint()..color = const Color(0xFFDBEAFE);

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 6, cy - 10, 12, 28), const Radius.circular(1)), white);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 6, cy - 15, 12, 6),  const Radius.circular(1)), lb);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 17, cy - 2, 10, 20), const Radius.circular(1)), sb);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 17, cy - 6,  10, 5), const Radius.circular(1)), lb);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + 7,  cy - 2, 10, 20), const Radius.circular(1)), sb);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + 7,  cy - 6,  10, 5), const Radius.circular(1)), lb);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 19, cy + 18, 38, 3),  const Radius.circular(1)), lb);

    final pole = Paint()..color = const Color(0xFFBFDBFE)..strokeWidth = 1.0..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, cy - 22), Offset(cx, cy - 15), pole);
    final flag = Path()..moveTo(cx + 0.5, cy - 22)..lineTo(cx + 6, cy - 19)..lineTo(cx + 0.5, cy - 16)..close();
    canvas.drawPath(flag, Paint()..color = const Color(0xFFEFF6FF));

    final win = Paint()..color = const Color(0xFF2563EB).withOpacity(0.7);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 5, cy - 7, 3, 3), const Radius.circular(1)), win);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + 2, cy - 7, 3, 3), const Radius.circular(1)), win);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 5, cy - 2, 3, 3), const Radius.circular(1)), win);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + 2, cy - 2, 3, 3), const Radius.circular(1)), win);

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 3, cy + 10, 6, 8), const Radius.circular(1)),
        Paint()..color = const Color(0xFF1E3A8A).withOpacity(0.6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}