import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ================================================================
// MODEL — sesuai class diagram
// ================================================================

/// Enum jenis_perundungan dari class Laporan
enum JenisPerundungan { verbal, fisik, cyberbullying }

extension JenisPerundunganExt on JenisPerundungan {
  String get label {
    switch (this) {
      case JenisPerundungan.verbal:
        return 'Verbal';
      case JenisPerundungan.fisik:
        return 'Fisik';
      case JenisPerundungan.cyberbullying:
        return 'Cyberbullying';
    }
  }
}

/// Enum jenis_file dari class Bukti_Laporan
enum JenisFile { foto, video, screenshot, dokumen }

extension JenisFileExt on JenisFile {
  String get label {
    switch (this) {
      case JenisFile.foto:
        return 'Foto';
      case JenisFile.video:
        return 'Video';
      case JenisFile.screenshot:
        return 'Screenshot';
      case JenisFile.dokumen:
        return 'Dokumen';
    }
  }

  IconData get icon {
    switch (this) {
      case JenisFile.foto:
        return Icons.photo_rounded;
      case JenisFile.video:
        return Icons.videocam_rounded;
      case JenisFile.screenshot:
        return Icons.screenshot_monitor_rounded;
      case JenisFile.dokumen:
        return Icons.insert_drive_file_rounded;
    }
  }
}

/// Model Bukti_Laporan sesuai class diagram:
/// - no_bukti : int (PK)
/// - id_laporan : int (FK)
/// - file_path : varchar(255)
/// - jenis_file : enum (foto, video, screenshot, dokumen)
/// - upload_at : datetime
/// + uploadFile() : void
/// + hapusFile() : void
class BuktiLaporan {
  final int noBukti;
  final String filePath;
  final JenisFile jenisFile;
  final DateTime uploadAt;
  final XFile? xfile; // untuk preview lokal sebelum upload

  BuktiLaporan({
    required this.noBukti,
    required this.filePath,
    required this.jenisFile,
    required this.uploadAt,
    this.xfile,
  });

  /// uploadFile() — dari class diagram Bukti_Laporan
  void uploadFile() {
    // implementasi upload ke server
  }

  /// hapusFile() — dari class diagram Bukti_Laporan
  void hapusFile() {
    // implementasi hapus file dari server
  }
}

// ================================================================
// PAGE
// ================================================================

class FormLaporanPage extends StatefulWidget {
  const FormLaporanPage({super.key});

  @override
  State<FormLaporanPage> createState() => _FormLaporanPageState();
}

class _FormLaporanPageState extends State<FormLaporanPage> {
  final _formKey = GlobalKey<FormState>();

  // ── Field Laporan (class diagram) ──────────────────────────────
  final _namaPelapor = TextEditingController();    // nama_pelapor : varchar(50)
  final _nimController = TextEditingController();  // nim : varchar(unique)
  final _lokasiController = TextEditingController(); // lokasi : varchar(100)
  final _kronologiController = TextEditingController(); // kronologi : text
  final _identitasPelaku = TextEditingController(); // identitas_pelaku : varchar(50)

  JenisPerundungan? _jenisPerundungan;   // jenis_perundungan : enum
  DateTime? _tanggalKejadian;            // tanggal_kejadian : date
  DateTime _tanggalLapor = DateTime.now(); // tanggal_lapor : datetime (auto)

  bool _isSubmitting = false;

  // ── Bukti_Laporan list ─────────────────────────────────────────
  final List<BuktiLaporan> _buktiBuktiLaporan = [];
  final ImagePicker _imagePicker = ImagePicker();
  int _buktiCounter = 1;

  // ── Maps State ─────────────────────────────────────────────────
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;
  bool _isLoadingLocation = false;
  bool _showMap = false;
  static const LatLng _defaultLocation = LatLng(-6.200000, 106.816666);

  // ================================================================
  // NAVIGATION
  // ================================================================
  void _goBack() => Navigator.pop(context);

  void _goToDashboard() {
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  // ================================================================
  // Mahasiswa.uploadBukti() — kamera & galeri
  // ================================================================

  /// Ambil foto langsung dari kamera → jenis_file: foto
  Future<void> _ambilFoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (photo != null) {
        setState(() {
          _buktiBuktiLaporan.add(BuktiLaporan(
            noBukti: _buktiCounter++,
            filePath: photo.path,
            jenisFile: JenisFile.foto,
            uploadAt: DateTime.now(),
            xfile: photo,
          ));
        });
      }
    } catch (e) {
      _showError('Gagal membuka kamera: $e');
    }
  }

  /// Tambah foto dari galeri (multi-select) → jenis_file: foto
  Future<void> _tambahFoto() async {
    try {
      final List<XFile> photos = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (photos.isNotEmpty) {
        setState(() {
          for (final p in photos) {
            _buktiBuktiLaporan.add(BuktiLaporan(
              noBukti: _buktiCounter++,
              filePath: p.path,
              jenisFile: JenisFile.foto,
              uploadAt: DateTime.now(),
              xfile: p,
            ));
          }
        });
      }
    } catch (e) {
      _showError('Gagal membuka galeri: $e');
    }
  }

  /// hapusFile() — hapus bukti dari list
  void _hapusBukti(int index) {
    _buktiBuktiLaporan[index].hapusFile();
    setState(() => _buktiBuktiLaporan.removeAt(index));
  }

  // ================================================================
  // MAPS — lokasi kejadian (max 100 karakter sesuai varchar(100))
  // ================================================================
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('Layanan GPS tidak aktif. Aktifkan terlebih dahulu.');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Izin lokasi ditolak.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showError('Izin lokasi ditolak permanen. Aktifkan di pengaturan.');
        return;
      }
      final Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _selectedLocation = latLng;
        _showMap = true;
      });
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
      // Sesuai varchar(100)
      _lokasiController.text =
          'Lat:${pos.latitude.toStringAsFixed(5)},Lng:${pos.longitude.toStringAsFixed(5)}';
    } catch (e) {
      _showError('Gagal mendapatkan lokasi: $e');
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _onMapTap(LatLng latLng) {
    setState(() => _selectedLocation = latLng);
    _lokasiController.text =
        'Lat:${latLng.latitude.toStringAsFixed(5)},Lng:${latLng.longitude.toStringAsFixed(5)}';
  }

  void _toggleMap() {
    setState(() {
      _showMap = !_showMap;
      if (_showMap && _selectedLocation == null) {
        _selectedLocation = _defaultLocation;
      }
    });
  }

  // ================================================================
  // VALIDATION
  // ================================================================
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName tidak boleh kosong';
    return null;
  }

  String? _validateNIM(String? value) {
    if (value == null || value.trim().isEmpty) return 'NIM tidak boleh kosong';
    if (!RegExp(r'^\d{9,15}$').hasMatch(value.trim()))
      return 'NIM harus berupa angka (9–15 digit)';
    return null;
  }

  String? _validateKronologi(String? value) {
    if (value == null || value.trim().isEmpty) return 'Kronologi tidak boleh kosong';
    if (value.trim().length < 30) return 'Kronologi minimal 30 karakter';
    return null;
  }

  String? _validateLokasi(String? value) {
    if (value == null || value.trim().isEmpty) return 'Lokasi tidak boleh kosong';
    if (value.trim().length > 100) return 'Lokasi maksimal 100 karakter';
    return null;
  }

  bool _validateForm() {
    bool isValid = _formKey.currentState!.validate();
    if (_jenisPerundungan == null) {
      _showError('Pilih jenis perundungan terlebih dahulu');
      isValid = false;
    } else if (_tanggalKejadian == null) {
      _showError('Pilih tanggal kejadian terlebih dahulu');
      isValid = false;
    }
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

  // ================================================================
  // Mahasiswa.kirimLaporan() + Mahasiswa.uploadBukti()
  // ================================================================
  void kirimLaporan() {
    FocusScope.of(context).unfocus();
    if (!_validateForm()) return;
    setState(() {
      _isSubmitting = true;
      _tanggalLapor = DateTime.now(); // tanggal_lapor : datetime (auto)
    });

    // uploadBukti() — upload semua Bukti_Laporan
    for (final bukti in _buktiBuktiLaporan) {
      bukti.uploadFile();
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
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
              child:
                  const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Laporan Berhasil Dikirim!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'ID: RPT-${_tanggalLapor.year}-00${DateTime.now().millisecond % 99 + 3}',
              style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 13),
            ),
            const SizedBox(height: 4),
            const Text(
              'Status: Menunggu Verifikasi',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
            if (_buktiBuktiLaporan.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${_buktiBuktiLaporan.length} bukti diunggah',
                style:
                    const TextStyle(color: Color(0xFF64748B), fontSize: 11),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _goToDashboard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Kembali ke Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTanggalKejadian() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF3B82F6),
            surface: Color(0xFF1A2940),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tanggalKejadian = picked);
  }

  @override
  void dispose() {
    _namaPelapor.dispose();
    _nimController.dispose();
    _lokasiController.dispose();
    _kronologiController.dispose();
    _identitasPelaku.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ================================================================
  // BUILD
  // ================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111D2C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: _goBack,
        ),
        title: const Text(
          'Buat Laporan Baru',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── INFORMASI PELAPOR ─────────────────────────────────
              _sectionHeader('Informasi Pelapor', Icons.person_outline),
              const SizedBox(height: 12),

              // nama_pelapor : varchar(50)
              _buildField(
                'Nama Pelapor *',
                _namaPelapor,
                'Masukkan nama lengkap',
                Icons.person_outline,
                validator: (v) => _validateRequired(v, 'Nama pelapor'),
                maxLength: 50,
              ),
              const SizedBox(height: 12),

              // nim : varchar(unique)
              _buildField(
                'NIM *',
                _nimController,
                'Contoh: 244107060001',
                Icons.badge_outlined,
                validator: _validateNIM,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 22),

              // ── DETAIL LAPORAN ────────────────────────────────────
              _sectionHeader('Detail Laporan', Icons.description_outlined),
              const SizedBox(height: 12),

              // jenis_perundungan : enum (verbal, fisik, cyberbullying)
              _sectionLabel('Jenis Perundungan *'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: JenisPerundungan.values.map((jenis) {
                  final isSelected = _jenisPerundungan == jenis;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _jenisPerundungan = jenis),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1E3A8A)
                            : const Color(0xFF1A2940),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF2D3E55),
                        ),
                      ),
                      child: Text(
                        jenis.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // tanggal_kejadian : date
              _sectionLabel('Tanggal Kejadian *'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickTanggalKejadian,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2940),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _tanggalKejadian != null
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFF2D3E55),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: _tanggalKejadian != null
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF64748B),
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _tanggalKejadian == null
                            ? 'Pilih tanggal kejadian'
                            : '${_tanggalKejadian!.day.toString().padLeft(2, '0')}/'
                                '${_tanggalKejadian!.month.toString().padLeft(2, '0')}/'
                                '${_tanggalKejadian!.year}',
                        style: TextStyle(
                          color: _tanggalKejadian == null
                              ? const Color(0xFF64748B)
                              : Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // lokasi : varchar(100) + Maps
              _sectionLabel('Lokasi Kejadian *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lokasiController,
                validator: _validateLokasi,
                maxLength: 100,
                style:
                    const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _inputDecoration(
                  hint: 'Gedung / Ruangan / Area kampus',
                  icon: Icons.location_on_outlined,
                ),
              ),
              const SizedBox(height: 6),

              // Tombol maps
              Row(
                children: [
                  Expanded(
                    child: _mapActionButton(
                      icon: Icons.my_location_rounded,
                      label: _isLoadingLocation
                          ? 'Mencari...'
                          : 'Lokasi Saya',
                      color: const Color(0xFF0EA5E9),
                      bgColor: const Color(0xFF0C2A3A),
                      isLoading: _isLoadingLocation,
                      onTap: _isLoadingLocation
                          ? null
                          : _getCurrentLocation,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _mapActionButton(
                      icon: Icons.map_outlined,
                      label: _showMap
                          ? 'Sembunyikan Peta'
                          : 'Pilih di Peta',
                      color: const Color(0xFF8B5CF6),
                      bgColor: const Color(0xFF1E1440),
                      onTap: _toggleMap,
                    ),
                  ),
                ],
              ),

              // Google Maps embed
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _showMap
                    ? Container(
                        margin: const EdgeInsets.only(top: 10),
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0xFF2D3E55)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: _selectedLocation ??
                                    _defaultLocation,
                                zoom: 15,
                              ),
                              onMapCreated: (c) => _mapController = c,
                              onTap: _onMapTap,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                              markers: _selectedLocation != null
                                  ? {
                                      Marker(
                                        markerId:
                                            const MarkerId('loc'),
                                        position: _selectedLocation!,
                                        icon: BitmapDescriptor
                                            .defaultMarkerWithHue(
                                                BitmapDescriptor
                                                    .hueBlue),
                                      )
                                    }
                                  : {},
                            ),
                            Positioned(
                              bottom: 8,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.black.withOpacity(0.65),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Tap peta untuk menandai lokasi kejadian',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 14),

              // kronologi : text
              _sectionLabel('Kronologi Kejadian *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _kronologiController,
                validator: _validateKronologi,
                maxLines: 5,
                style:
                    const TextStyle(color: Colors.white, fontSize: 13),
                decoration: _inputDecoration(
                  hint:
                      'Ceritakan kronologi secara rinci (min. 30 karakter)...',
                ).copyWith(
                    contentPadding: const EdgeInsets.all(14)),
              ),
              const SizedBox(height: 14),

              // identitas_pelaku : varchar(50)
              _buildField(
                'Identitas Pelaku (opsional)',
                _identitasPelaku,
                'Nama / NIM pelaku jika diketahui',
                Icons.person_off_outlined,
                maxLength: 50,
              ),
              const SizedBox(height: 22),

              // ── BUKTI LAPORAN ─────────────────────────────────────
              // Bukti_Laporan: file_path, jenis_file, upload_at
              // Mahasiswa.uploadBukti()
              Row(
                children: [
                  _sectionHeader(
                      'Bukti Laporan', Icons.attach_file_rounded),
                  const Spacer(),
                  if (_buktiBuktiLaporan.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_buktiBuktiLaporan.length} file',
                        style: const TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              // Hint jenis_file enum
              const Text(
                'jenis_file: foto · video · screenshot · dokumen',
                style: TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 10,
                    fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 10),

              // Dua tombol: Ambil Foto & Tambah Foto
              Row(
                children: [
                  // Ambil Foto → kamera → jenis_file: foto
                  Expanded(
                    child: GestureDetector(
                      onTap: _ambilFoto,
                      child: _buktiButton(
                        icon: Icons.camera_alt_rounded,
                        label: 'Ambil Foto',
                        sublabel: 'Buka kamera',
                        color: const Color(0xFF3B82F6),
                        iconBg: const Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Tambah Foto → galeri → jenis_file: foto
                  Expanded(
                    child: GestureDetector(
                      onTap: _tambahFoto,
                      child: _buktiButton(
                        icon: Icons.photo_library_rounded,
                        label: 'Tambah Foto',
                        sublabel: 'Dari galeri',
                        color: const Color(0xFF10B981),
                        iconBg: const Color(0xFF064E3B),
                      ),
                    ),
                  ),
                ],
              ),

              // Preview grid Bukti_Laporan
              if (_buktiBuktiLaporan.isNotEmpty) ...[
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _buktiBuktiLaporan.length,
                  itemBuilder: (context, index) {
                    final bukti = _buktiBuktiLaporan[index];
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        // Preview gambar (file_path)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: bukti.xfile != null
                              ? Image.file(
                                  File(bukti.xfile!.path),
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: const Color(0xFF1A2940),
                                  child: Icon(
                                      bukti.jenisFile.icon,
                                      color: const Color(0xFF3B82F6),
                                      size: 28),
                                ),
                        ),
                        // Badge jenis_file
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  Colors.black.withOpacity(0.65),
                              borderRadius:
                                  BorderRadius.circular(6),
                            ),
                            child: Text(
                              bukti.jenisFile.label,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        // no_bukti badge
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB)
                                  .withOpacity(0.85),
                              borderRadius:
                                  BorderRadius.circular(5),
                            ),
                            child: Text(
                              '#${bukti.noBukti}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        // hapusFile() button
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _hapusBukti(index),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color:
                                    Colors.black.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],

              const SizedBox(height: 22),

              // tanggal_lapor : datetime (auto-generated, read-only)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF111D2C),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color(0xFF1E2D3D)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        color: Color(0xFF475569), size: 15),
                    const SizedBox(width: 8),
                    Text(
                      'tanggal_lapor: '
                      '${_tanggalLapor.day.toString().padLeft(2, '0')}/'
                      '${_tanggalLapor.month.toString().padLeft(2, '0')}/'
                      '${_tanggalLapor.year} '
                      '${_tanggalLapor.hour.toString().padLeft(2, '0')}:'
                      '${_tanggalLapor.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          color: Color(0xFF475569), fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // kirimLaporan() button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : kirimLaporan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white),
                        )
                      : const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Kirim Laporan',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                        FontWeight.w600)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // HELPER WIDGETS
  // ================================================================

  Widget _sectionHeader(String label, IconData icon) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A),
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              Icon(icon, color: const Color(0xFF3B82F6), size: 15),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF94A3B8)),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(color: Color(0xFF64748B), fontSize: 13),
      prefixIcon: icon != null
          ? Icon(icon, color: const Color(0xFF64748B), size: 20)
          : null,
      filled: true,
      fillColor: const Color(0xFF1A2940),
      counterStyle:
          const TextStyle(color: Color(0xFF475569), fontSize: 10),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2D3E55))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2D3E55))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444))),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFFEF4444), width: 1.5)),
      errorStyle:
          const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint,
    IconData icon, {
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: _inputDecoration(hint: hint, icon: icon),
        ),
      ],
    );
  }

  Widget _mapActionButton({
    required IconData? icon,
    required String label,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: color),
              )
            else
              Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buktiButton({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2940),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(sublabel,
              style: const TextStyle(
                  color: Color(0xFF64748B), fontSize: 10)),
        ],
      ),
    );
  }
}