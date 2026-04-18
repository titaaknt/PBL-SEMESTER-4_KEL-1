import 'package:flutter/material.dart';
import 'dart:async';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  // -------------------------------------------------------
  // NAVIGATION METHODS
  // -------------------------------------------------------
  void _goToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  // -------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) _goToLogin();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo shield + gedung Polinema
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CustomPaint(
                    painter: _PolinemaSplashLogoPainter(),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'SafeCampus',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aplikasi Pelaporan Perundungan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 14),
                // Badge PNM
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withOpacity(0.4),
                    ),
                  ),
                  child: const Text(
                    'Politeknik Negeri Malang',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF93C5FD),
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 56),
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.3),
                    color: const Color(0xFF3B82F6),
                    minHeight: 3,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------
// Custom Painter: Shield + Gedung Kampus Polinema
// -------------------------------------------------------
class _PolinemaSplashLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;

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
    final win = Paint()..color = const Color(0xFF2563EB).withOpacity(0.7);
    for (final row in [cy - 12.0, cy - 3.0]) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(cx - 8, row, 5, 5), const Radius.circular(1)), win);
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(cx + 3, row, 5, 5), const Radius.circular(1)), win);
    }

    // Jendela sayap
    final winSm = Paint()..color = const Color(0xFF2563EB).withOpacity(0.55);
    for (final row in [cy + 2.0, cy + 10.0]) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 28, row, 4, 4), const Radius.circular(1)), winSm);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 22, row, 4, 4), const Radius.circular(1)), winSm);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + 15, row, 4, 4), const Radius.circular(1)), winSm);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + 21, row, 4, 4), const Radius.circular(1)), winSm);
    }

    // Pintu
    final door = Paint()..color = const Color(0xFF1E3A8A).withOpacity(0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 5, cy + 18, 10, 12), const Radius.circular(2)),
      door,
    );
  }

  // Helper bikin path shield
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}