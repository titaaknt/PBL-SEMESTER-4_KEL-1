// lib/form_laporan.dart — versi Supabase
// Perubahan dari versi lama:
//   - _submit() memanggil LaporanService.submitLaporan()
//   - File foto asli dikirim ke Supabase Storage
//   - Semua logika UI/kamera/maps tidak berubah

import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../shared/camera_page.dart';
import '../shared/maps_page.dart';
import '../../controllers/laporan_controller.dart';
import '../../controllers/auth_controller.dart';

class FormLaporanPage extends StatefulWidget {
  const FormLaporanPage({super.key});
  @override
  State<FormLaporanPage> createState() => _FormLaporanPageState();
}

class _FormLaporanPageState extends State<FormLaporanPage> {
  final _formKey             = GlobalKey<FormState>();
  final _namaController      = TextEditingController();
  final _nimController       = TextEditingController();
  final _lokasiController    = TextEditingController();
  final _kronologiController = TextEditingController();
  final _pelakuController    = TextEditingController();
  final _picker              = ImagePicker();

  String?    _selectedJenis;
  DateTime?  _selectedDate;
  TimeOfDay? _selectedTime;
  final List<XFile> _buktiFotos = [];  // ← simpan XFile untuk Web & Mobile
  XFile? _buktiVideo;                  // ← DITAMBAHKAN: simpan XFile video
  bool _isSubmitting = false;

  final List<String> _jenisPerundungan = ['Verbal', 'Fisik', 'Cyberbullying', 'Seksual'];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await AuthController.getCurrentProfile();
      if (profile != null && mounted) {
        setState(() {
          _namaController.text = profile.nama;
          _nimController.text = profile.nim;
        });
      }
    } catch (_) {}
  }

  // ── NAVIGATION ─────────────────────────────────────────
  void _goBack() => Navigator.pop(context);

  void _goToDashboard() {
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  Future<void> _goToCamera() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const CameraPage(mode: 'bukti')),
    );
    if (result != null && mounted) {
      setState(() => _buktiFotos.add(XFile(result)));
    }
  }

  Future<void> _goToMaps() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const MapsLokasiPage()),
    );
    if (result != null && mounted) {
      setState(() => _lokasiController.text = result);
    }
  }

  Future<void> _pickFromGaleri() async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage(imageQuality: 80, limit: 5);
      if (picked.isNotEmpty && mounted) {
        setState(() {
          for (final f in picked) {
            if (_buktiFotos.length < 5) _buktiFotos.add(f);
          }
        });
      }
    } catch (_) {
      _showError('Gagal membuka galeri');
    }
  }

  void _hapusFoto(int index) => setState(() => _buktiFotos.removeAt(index));

  Future<void> _pickVideoFromGaleri() async {
    try {
      final XFile? picked = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      if (picked != null && mounted) {
        setState(() {
          _buktiVideo = picked;
        });
      }
    } catch (_) {
      _showError('Gagal mengambil video dari galeri');
    }
  }

  Future<void> _recordVideo() async {
    try {
      final XFile? picked = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );
      if (picked != null && mounted) {
        setState(() {
          _buktiVideo = picked;
        });
      }
    } catch (_) {
      _showError('Gagal merekam video');
    }
  }

  void _hapusVideo() => setState(() => _buktiVideo = null);

  // ── VALIDASI ───────────────────────────────────────────
  String? _validateNIM(String? v) {
    if (v == null || v.trim().isEmpty) return 'NIM tidak boleh kosong';
    if (!RegExp(r'^\d{9,15}$').hasMatch(v.trim())) return 'NIM harus angka 9-15 digit';
    return null;
  }

  String? _validateKronologi(String? v) {
    if (v == null || v.trim().isEmpty) return 'Kronologi tidak boleh kosong';
    if (v.trim().length < 30) return 'Kronologi minimal 30 karakter';
    return null;
  }

  bool _validateForm() {
    bool isValid = _formKey.currentState!.validate();
    if (_selectedJenis == null) { _showError('Pilih jenis perundungan'); isValid = false; }
    if (_selectedDate  == null) { _showError('Pilih tanggal kejadian'); isValid = false; }
    return isValid;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── SUBMIT → SUPABASE ──────────────────────────────────
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_validateForm()) {
      _showError('Mohon lengkapi semua data laporan dengan benar (kronologi minimal 30 karakter)');
      return;
    }
    setState(() => _isSubmitting = true);

    try {
      final waktuStr = _selectedTime == null
          ? null
          : '${_selectedTime!.hour.toString().padLeft(2,'0')}:${_selectedTime!.minute.toString().padLeft(2,'0')}';

      final laporan = await LaporanController.submitLaporan(
        namaPelapor    : _namaController.text.trim(),
        nimPelapor     : _nimController.text.trim(),
        jenis          : _selectedJenis!,
        lokasi         : _lokasiController.text.trim(),
        tanggalKejadian: _selectedDate!,
        waktuKejadian  : waktuStr,
        kronologi      : _kronologiController.text.trim(),
        pelaku         : _pelakuController.text.trim().isEmpty ? null : _pelakuController.text.trim(),
        buktiFotos     : _buktiFotos,
        buktiVideo     : _buktiVideo,
      );

      if (mounted) {
        setState(() { _isSubmitting = false; });
        _showSuccessDialog(laporan.kode);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showError('Gagal mengirim laporan: $e');
      }
    }
  }

  void _showSuccessDialog(String kode) {
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
              width: 64, height: 64,
              decoration: BoxDecoration(color: const Color(0xFF064E3B), borderRadius: BorderRadius.circular(32)),
              child: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 36),
            ),
            const SizedBox(height: 16),
            const Text('Laporan Berhasil Dikirim!',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('ID: $kode', style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 13)),
            const SizedBox(height: 6),
            const Text('Status: Menunggu Verifikasi',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            const SizedBox(height: 6),
            const Text('Admin akan mendapat notifikasi.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _goToDashboard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Kembali ke Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: Color(0xFF3B82F6), surface: Color(0xFF1A2940))),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context, initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: Color(0xFF3B82F6), surface: Color(0xFF1A2940))),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  void dispose() {
    _namaController.dispose(); _nimController.dispose();
    _lokasiController.dispose(); _kronologiController.dispose(); _pelakuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111D2C), elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: _goBack,
        ),
        title: const Text('Buat Laporan Baru',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _buildField('Nama Pelapor', _namaController, 'Memuat nama...', Icons.person_outline,
                  readOnly: true,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama tidak boleh kosong' : null),
              const SizedBox(height: 14),

              _buildField('NIM', _nimController, 'Memuat NIM...', Icons.badge_outlined,
                  readOnly: true,
                  validator: _validateNIM, keyboardType: TextInputType.number),
              const SizedBox(height: 14),

              // ── Jenis Perundungan ──────────────────────
              _sectionLabel('Jenis Perundungan *'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _jenisPerundungan.map((jenis) {
                  final sel = _selectedJenis == jenis;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedJenis = jenis),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? const Color(0xFF1E3A8A) : const Color(0xFF1A2940),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? const Color(0xFF3B82F6) : const Color(0xFF2D3E55)),
                      ),
                      child: Text(jenis, style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : const Color(0xFF64748B),
                      )),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // ── Lokasi ────────────────────────────────
              _sectionLabel('Lokasi Kejadian *'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _lokasiController, readOnly: true,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Pilih lokasi' : null,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: _inputDeco('Ketuk ikon peta untuk memilih', Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _goToMaps,
                  child: Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A), borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.5)),
                    ),
                    child: const Icon(Icons.map_outlined, color: Color(0xFF3B82F6), size: 24),
                  ),
                ),
              ]),
              const SizedBox(height: 14),

              // ── Tanggal & Waktu ────────────────────────
              _sectionLabel('Tanggal & Waktu Kejadian *'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: _pickDate,
                  child: _dateTimeBox(
                    Icons.calendar_today_outlined,
                    _selectedDate == null
                        ? 'Pilih tanggal'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    _selectedDate != null,
                  ),
                )),
                const SizedBox(width: 10),
                Expanded(child: GestureDetector(
                  onTap: _pickTime,
                  child: _dateTimeBox(
                    Icons.access_time_outlined,
                    _selectedTime == null
                        ? 'Pilih waktu'
                        : '${_selectedTime!.hour.toString().padLeft(2,'0')}:${_selectedTime!.minute.toString().padLeft(2,'0')}',
                    _selectedTime != null,
                  ),
                )),
              ]),
              const SizedBox(height: 14),

              // ── Kronologi ─────────────────────────────
              _sectionLabel('Kronologi Kejadian *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _kronologiController, validator: _validateKronologi, maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Tulis kronologi kejadian secara rinci (min. 30 karakter)...',
                  hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  filled: true, fillColor: const Color(0xFF1A2940),
                  border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D3E55))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D3E55))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
                  errorBorder:   OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444))),
                  errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
                ),
              ),
              const SizedBox(height: 14),

              _buildField('Identitas Pelaku (jika diketahui)', _pelakuController,
                  'Nama pelaku (opsional)', Icons.person_off_outlined),
              const SizedBox(height: 20),

              // ── Upload Bukti ──────────────────────────
              _sectionLabel('Upload Bukti (Foto / Screenshot)'),
              const SizedBox(height: 4),
              const Text('Maks. 5 foto.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              const SizedBox(height: 10),

              Row(children: [
                Expanded(child: _fotoBtn(Icons.camera_alt_outlined, 'Kamera', 'Ambil foto langsung',
                    const Color(0xFF3B82F6), _goToCamera)),
                const SizedBox(width: 10),
                Expanded(child: _fotoBtn(Icons.photo_library_outlined, 'Galeri', 'Pilih dari galeri HP',
                    const Color(0xFF8B5CF6), _pickFromGaleri)),
              ]),

              if (_buktiFotos.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(children: [
                  const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 14),
                  const SizedBox(width: 6),
                  Text('${_buktiFotos.length} foto dipilih',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF10B981))),
                ]),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                  itemCount: _buktiFotos.length,
                  itemBuilder: (_, i) => Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: kIsWeb
                            ? Image.network(_buktiFotos[i].path, fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(color: const Color(0xFF1A2940),
                                    child: const Icon(Icons.broken_image_outlined, color: Color(0xFF64748B), size: 28)))
                            : Image.file(io.File(_buktiFotos[i].path), fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(color: const Color(0xFF1A2940),
                                    child: const Icon(Icons.broken_image_outlined, color: Color(0xFF64748B), size: 28))),
                      ),
                      Positioned(top: 4, right: 4,
                        child: GestureDetector(
                          onTap: () => _hapusFoto(i),
                          child: Container(width: 22, height: 22,
                              decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                              child: const Icon(Icons.close, size: 13, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ── Upload Video ──────────────────────────
              _sectionLabel('Upload Bukti Video (opsional)'),
              const SizedBox(height: 4),
              const Text('Maks. 1 video.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              const SizedBox(height: 10),

              Row(children: [
                Expanded(child: _fotoBtn(Icons.videocam_outlined, 'Rekam Video', 'Ambil video langsung',
                    const Color(0xFF10B981), _recordVideo)),
                const SizedBox(width: 10),
                Expanded(child: _fotoBtn(Icons.video_library_outlined, 'Galeri Video', 'Pilih dari galeri HP',
                    const Color(0xFFF59E0B), _pickVideoFromGaleri)),
              ]),

              if (_buktiVideo != null) ...[
                const SizedBox(height: 12),
                Row(children: [
                  const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 14),
                  const SizedBox(width: 6),
                  const Text('1 video dipilih',
                      style: TextStyle(fontSize: 12, color: Color(0xFF10B981))),
                ]),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2940),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2D3E55)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.movie_creation_outlined, color: Color(0xFF10B981)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _buktiVideo!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'Format Video',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFFEF4444), size: 20),
                        onPressed: _hapusVideo,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // ── Tombol Kirim ──────────────────────────
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF1E3A8A), elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.send_rounded, size: 18), SizedBox(width: 8),
                          Text('Kirim Laporan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        ]),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widget helpers ──────────────────────────────────────
  Widget _sectionLabel(String label) => Text(label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)));

  Widget _dateTimeBox(IconData icon, String text, bool filled) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0xFF1A2940), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF2D3E55)),
    ),
    child: Row(children: [
      Icon(icon, color: const Color(0xFF64748B), size: 18), const SizedBox(width: 8),
      Expanded(child: Text(text, style: TextStyle(fontSize: 13,
          color: filled ? Colors.white : const Color(0xFF64748B)))),
    ]),
  );

  Widget _fotoBtn(IconData icon, String label, String sub, Color color, VoidCallback onTap) {
    final disabled = _buktiFotos.length >= 5;
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2940), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2D3E55)),
        ),
        child: Column(children: [
          Icon(icon, size: 28, color: disabled ? const Color(0xFF2D3E55) : color),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
              color: disabled ? const Color(0xFF2D3E55) : color)),
          Text(sub, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        ]),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, [IconData? icon]) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
    prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF64748B), size: 20) : null,
    filled: true, fillColor: const Color(0xFF1A2940),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D3E55))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D3E55))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
    errorBorder:   OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444))),
    errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
  );

  Widget _buildField(String label, TextEditingController ctrl, String hint, IconData icon,
      {String? Function(String?)? validator, TextInputType keyboardType = TextInputType.text, bool readOnly = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel(label), const SizedBox(height: 8),
      TextFormField(
        controller: ctrl, validator: validator, keyboardType: keyboardType,
        readOnly: readOnly,
        style: TextStyle(color: readOnly ? const Color(0xFF94A3B8) : Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
          filled: true, fillColor: const Color(0xFF1A2940),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D3E55))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D3E55))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
          errorBorder:   OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444))),
          errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
        ),
      ),
    ]);
  }
}