import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class CameraPage extends StatefulWidget {
  /// mode: 'bukti' → grid overlay | 'profil' → frame lingkaran
  final String mode;
  const CameraPage({super.key, this.mode = 'bukti'});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? _ctrl;
  List<CameraDescription> _cameras = [];
  int     _camIdx  = 0;
  bool    _ready   = false;
  bool    _taking  = false;
  bool    _flashOn = false;
  String? _preview;

  void _goBack()               => Navigator.pop(context);
  void _returnPhoto(String fp) => Navigator.pop(context, fp);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.addObserver(this);
    _initCam();
  }

  Future<void> _initCam() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;
      await _startCtrl(_cameras[_camIdx]);
    } catch (e) {
      debugPrint('initCam error: $e');
    }
  }

  Future<void> _startCtrl(CameraDescription desc) async {
    if (_ctrl != null) {
      await _ctrl!.dispose();
      _ctrl = null;
    }
    if (mounted) setState(() => _ready = false);

    final ctrl = CameraController(
      desc,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _ctrl = ctrl;

    try {
      await ctrl.initialize();
      await ctrl.lockCaptureOrientation(DeviceOrientation.portraitUp);
      if (mounted) setState(() => _ready = true);
    } catch (e) {
      debugPrint('startCtrl error: $e');
    }
  }

  Future<void> _flipCam() async {
    if (_cameras.length < 2) return;
    _camIdx  = _camIdx == 0 ? 1 : 0;
    _flashOn = false; // kamera depan tidak ada flash
    await _startCtrl(_cameras[_camIdx]);
  }

  Future<void> _toggleFlash() async {
    if (_ctrl == null || !_ready) return;
    _flashOn = !_flashOn;
    try {
      await _ctrl!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
    } catch (_) {
      _flashOn = false;
    }
    if (mounted) setState(() {});
  }

  Future<void> _snap() async {
    if (_ctrl == null || !_ready || _taking) return;
    setState(() => _taking = true);
    try {
      final xf  = await _ctrl!.takePicture();
      final dir = await getApplicationDocumentsDirectory();
      final dest = p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
      await File(xf.path).copy(dest);
      if (mounted) setState(() { _preview = dest; _taking = false; });
    } catch (e) {
      debugPrint('snap error: $e');
      if (mounted) setState(() => _taking = false);
    }
  }

  void _retake() => setState(() => _preview = null);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_ctrl == null || !_ready) return;
    if (state == AppLifecycleState.inactive) {
      _ctrl!.dispose();
      _ctrl = null;
      if (mounted) setState(() => _ready = false);
    } else if (state == AppLifecycleState.resumed) {
      _startCtrl(_cameras[_camIdx]);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WidgetsBinding.instance.removeObserver(this);
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _preview != null ? _buildPreview() : _buildCamera(),
    );
  }

  // ───────────────────────────────────────────────────────
  // HALAMAN KAMERA
  // ───────────────────────────────────────────────────────
  Widget _buildCamera() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Preview — pakai widget terpisah yang handle AR sendiri
        if (_ready && _ctrl != null)
          _FullScreenPreview(controller: _ctrl!)
        else
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF3B82F6)),
                SizedBox(height: 16),
                Text('Memuat kamera...',
                    style: TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),

        // Grid (bukti)
        if (_ready && widget.mode == 'bukti')
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

        // Lingkaran (profil)
        if (_ready && widget.mode == 'profil')
          Center(
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 2.5),
              ),
            ),
          ),

        // TOP BAR
        _TopBar(
          label: widget.mode == 'profil' ? 'Foto Profil' : 'Foto Bukti',
          flashOn: _flashOn,
          onClose: _goBack,
          onFlash: _toggleFlash,
        ),

        // BOTTOM BAR
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _iconBtn(Icons.photo_library_outlined, () {}),
                    // Shutter
                    GestureDetector(
                      onTap: _taking ? null : _snap,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 80),
                        width:  _taking ? 66 : 72,
                        height: _taking ? 66 : 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.white38, width: 5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.25),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: _taking
                            ? const Padding(
                                padding: EdgeInsets.all(18),
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.black54),
                              )
                            : null,
                      ),
                    ),
                    _iconBtn(Icons.flip_camera_ios_outlined, _flipCam),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────
  // HALAMAN PREVIEW FOTO
  // ───────────────────────────────────────────────────────
  Widget _buildPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(File(_preview!), fit: BoxFit.cover),

        // TOP BAR — posisi & style sama persis dengan halaman kamera
        _TopBar(
          label: 'Preview',
          flashOn: false,
          showFlash: false,   // sembunyikan icon flash
          onClose: _retake,   // X = kembali ke kamera
          onFlash: () {},
        ),

        // BOTTOM ACTIONS
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _retake,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Ulangi',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => _returnPhoto(_preview!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Gunakan Foto',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap,
      {Color color = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// TOP BAR — reusable, dipakai di kamera & preview
// ═══════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final String       label;
  final bool         flashOn;
  final bool         showFlash;
  final VoidCallback onClose;
  final VoidCallback onFlash;

  const _TopBar({
    required this.label,
    required this.flashOn,
    required this.onClose,
    required this.onFlash,
    this.showFlash = true,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.78),
              Colors.transparent,
            ],
            stops: const [0.6, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tombol X / close
                _btn(Icons.close, onClose),

                // Label tengah
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.camera_alt_outlined,
                          color: Colors.white, size: 13),
                      const SizedBox(width: 6),
                      Text(label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),

                // Flash atau placeholder agar label tetap di tengah
                showFlash
                    ? _btn(
                        flashOn ? Icons.flash_on : Icons.flash_off,
                        onFlash,
                        color: flashOn
                            ? const Color(0xFFF59E0B)
                            : Colors.white,
                      )
                    : const SizedBox(width: 46),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap,
      {Color color = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// FULL-SCREEN CAMERA PREVIEW
// Pakai previewSize (piksel asli) bukan aspectRatio (sering salah)
// ═══════════════════════════════════════════════════════════
class _FullScreenPreview extends StatelessWidget {
  final CameraController controller;
  const _FullScreenPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final screenW = constraints.maxWidth;
        final screenH = constraints.maxHeight;

        // previewSize dari Flutter camera = ukuran piksel LANDSCAPE
        // (width selalu > height di sini, tidak peduli jenis kamera)
        final ps = controller.value.previewSize;
        if (ps == null) return const ColoredBox(color: Colors.black);

        // Di portrait: lebar layar = sisi pendek sensor, tinggi = sisi panjang
        // ps.width  = sisi panjang sensor (jadi tinggi di portrait)
        // ps.height = sisi pendek sensor  (jadi lebar di portrait)
        final portraitW = ps.height; // lebar dalam portrait
        final portraitH = ps.width;  // tinggi dalam portrait

        // Scale agar preview COVER layar penuh (tidak ada celah hitam)
        // Ambil scale terbesar antara fit-width vs fit-height
        final scaleW = screenW / portraitW;
        final scaleH = screenH / portraitH;
        final scale  = scaleW > scaleH ? scaleW : scaleH;

        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            maxWidth:  portraitW * scale,
            maxHeight: portraitH * scale,
            child: SizedBox(
              width:  portraitW * scale,
              height: portraitH * scale,
              child: CameraPreview(controller),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// GRID PAINTER — rule-of-thirds guide
// ═══════════════════════════════════════════════════════════
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(size.width / 3, 0),
        Offset(size.width / 3, size.height), paint);
    canvas.drawLine(Offset(size.width * 2 / 3, 0),
        Offset(size.width * 2 / 3, size.height), paint);
    canvas.drawLine(Offset(0, size.height / 3),
        Offset(size.width, size.height / 3), paint);
    canvas.drawLine(Offset(0, size.height * 2 / 3),
        Offset(size.width, size.height * 2 / 3), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}