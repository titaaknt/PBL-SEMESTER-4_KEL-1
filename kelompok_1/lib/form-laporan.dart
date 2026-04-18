import 'package:flutter/material.dart';

class FormLaporanPage extends StatefulWidget {
  const FormLaporanPage({super.key});

  @override
  State<FormLaporanPage> createState() => _FormLaporanPageState();
}

class _FormLaporanPageState extends State<FormLaporanPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nimController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _kronologiController = TextEditingController();
  final _pelakuController = TextEditingController();

  String? _selectedJenis;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _uploadedFileName;
  bool _isSubmitting = false;

  final List<String> _jenisPerundungan = ['Verbal', 'Fisik', 'Cyberbullying', 'Seksual'];

  // -------------------------------------------------------
  // NAVIGATION METHODS
  // -------------------------------------------------------
  void _goBack() {
    Navigator.pop(context);
  }

  void _goToDashboard() {
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  // -------------------------------------------------------

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  String? _validateNIM(String? value) {
    if (value == null || value.trim().isEmpty) return 'NIM tidak boleh kosong';
    final nimRegex = RegExp(r'^\d{9,15}$');
    if (!nimRegex.hasMatch(value.trim())) {
      return 'NIM harus berupa angka (9-15 digit)';
    }
    return null;
  }

  String? _validateKronologi(String? value) {
    if (value == null || value.trim().isEmpty) return 'Kronologi tidak boleh kosong';
    if (value.trim().length < 30) return 'Kronologi minimal 30 karakter';
    return null;
  }

  bool _validateForm() {
    bool isValid = _formKey.currentState!.validate();
    if (_selectedJenis == null) {
      _showError('Pilih jenis perundungan terlebih dahulu');
      isValid = false;
    } else if (_selectedDate == null) {
      _showError('Pilih tanggal kejadian terlebih dahulu');
      isValid = false;
    }
    return isValid;
  }

  void _showError(String msg) {
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

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_validateForm()) return;
    setState(() => _isSubmitting = true);
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
              child: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Laporan Berhasil Dikirim!',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'ID: RPT-2026-00${DateTime.now().millisecond % 99 + 3}',
              style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 13),
            ),
            const SizedBox(height: 6),
            const Text(
              'Status: Menunggu Verifikasi',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _goToDashboard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    _lokasiController.dispose();
    _kronologiController.dispose();
    _pelakuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111D2C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: _goBack,
        ),
        title: const Text(
          'Buat Laporan Baru',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
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
              _buildField('Nama Pelapor', _namaController, 'Masukkan nama lengkap', Icons.person_outline,
                  validator: (v) => _validateRequired(v, 'Nama pelapor')),
              const SizedBox(height: 14),
              _buildField('NIM', _nimController, 'Contoh: 244107060001', Icons.badge_outlined,
                  validator: _validateNIM, keyboardType: TextInputType.number),
              const SizedBox(height: 14),

              // Jenis Perundungan
              _sectionLabel('Jenis Perundungan *'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _jenisPerundungan.map((jenis) {
                  final isSelected = _selectedJenis == jenis;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedJenis = jenis),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF1A2940),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF2D3E55),
                        ),
                      ),
                      child: Text(
                        jenis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              _buildField('Lokasi Kejadian', _lokasiController, 'Gedung / Ruangan / Area kampus',
                  Icons.location_on_outlined,
                  validator: (v) => _validateRequired(v, 'Lokasi')),
              const SizedBox(height: 14),

              // Tanggal Kejadian
              _sectionLabel('Tanggal Kejadian *'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2940),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2D3E55)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: Color(0xFF64748B), size: 18),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Pilih tanggal kejadian'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: TextStyle(
                          color: _selectedDate == null ? const Color(0xFF64748B) : Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Kronologi
              _sectionLabel('Kronologi Kejadian *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _kronologiController,
                validator: _validateKronologi,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Tulis kronologi kejadian secara rinci (min. 30 karakter)...',
                  hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF1A2940),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D3E55))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D3E55))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444))),
                  focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5)),
                  errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
                ),
              ),
              const SizedBox(height: 14),

              _buildField('Identitas Pelaku (jika diketahui)', _pelakuController,
                  'Nama / NIM pelaku (opsional)', Icons.person_off_outlined),
              const SizedBox(height: 14),

              // Upload Bukti
              _sectionLabel('Upload Bukti'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(() => _uploadedFileName = 'bukti_foto_sample.jpg'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2940),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _uploadedFileName != null ? const Color(0xFF10B981) : const Color(0xFF2D3E55),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _uploadedFileName != null ? Icons.check_circle : Icons.cloud_upload_outlined,
                        size: 32,
                        color: _uploadedFileName != null ? const Color(0xFF10B981) : const Color(0xFF64748B),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _uploadedFileName ?? 'Foto / Video / Screenshot',
                        style: TextStyle(
                          fontSize: 12,
                          color: _uploadedFileName != null ? const Color(0xFF10B981) : const Color(0xFF64748B),
                        ),
                      ),
                      if (_uploadedFileName == null)
                        const Text(
                          'Tap untuk memilih file',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Kirim Laporan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint,
    IconData icon, {
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
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
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
            filled: true,
            fillColor: const Color(0xFF1A2940),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D3E55))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D3E55))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444))),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5)),
            errorStyle: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
          ),
        ),
      ],
    );
  }
}