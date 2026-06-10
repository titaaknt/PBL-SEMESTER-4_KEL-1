import 'package:flutter/material.dart';
import '../../controllers/supabase_client.dart';
import '../../controllers/laporan_controller.dart';
import '../../models/laporan_model.dart';

class DaftarLaporanPage extends StatefulWidget {
  const DaftarLaporanPage({super.key});

  @override
  State<DaftarLaporanPage> createState() => _DaftarLaporanPageState();
}

class _DaftarLaporanPageState extends State<DaftarLaporanPage> {
  String _filterAktif = 'Semua';

  final List<String> _filtersMahasiswa = [
    'Semua',
    'Menunggu Verifikasi',
    'Diproses',
    'Selesai',
    'Tidak Valid',
  ];
  final List<String> _filtersAdmin = [
    'Semua',
    'Menunggu Verifikasi',
    'Diproses',
    'Selesai',
    'Tidak Valid',
  ];
  final List<String> _filtersKaprodi = [
    'Semua',
    'Menunggu Verifikasi',
    'Diproses',
    'Selesai',
    'Tidak Valid',
  ];

  // -------------------------------------------------------
  // NAVIGATION METHODS
  // -------------------------------------------------------
  void _goBack() => Navigator.pop(context);

  void _goToFormLaporan() {
    Navigator.pushNamed(context, '/form-laporan');
  }

  void _goToDetailLaporan(Map<String, dynamic> laporan) {
    Navigator.pushNamed(context, '/detail-laporan', arguments: laporan);
  }

  void _goToStatusLaporan(Map<String, dynamic> laporan) {
    Navigator.pushNamed(context, '/status-laporan', arguments: laporan);
  }
  // -------------------------------------------------------

  List<String> _filtersForRole(String role) {
    if (role == 'Admin') return _filtersAdmin;
    if (role == 'Kaprodi') return _filtersKaprodi;
    return _filtersMahasiswa;
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Diproses':
        return const Color(0xFFF59E0B);
      case 'Selesai':
        return const Color(0xFF10B981);
      case 'Tidak Valid':
        return const Color(0xFFEF4444);
      case 'Menunggu Verifikasi':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _getStatusColor(String status, String role) {
    switch (status) {
      case 'Diproses':
        return const Color(0xFFF59E0B);
      case 'Selesai':
        return const Color(0xFF10B981);
      case 'Tidak Valid':
        return const Color(0xFFEF4444);
      case 'Menunggu Verifikasi':
        return const Color(0xFF3B82F6);
      default:
        if (role == 'Kaprodi') return const Color(0xFF10B981);
        if (role == 'Admin') return const Color(0xFF3B82F6);
        return const Color(0xFF2563EB);
    }
  }

  String _formatTgl(dynamic ts) {
    if (ts == null) return '-';
    try {
      final dt = ts is DateTime ? ts.toLocal() : DateTime.parse(ts.toString()).toLocal();
      return '${dt.day} ${['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][dt.month - 1]}, ${dt.year}';
    } catch (_) {
      return ts.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Baca args di build — selalu dapat nilai terbaru, tidak akan kosong
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    
    // Resolve NIM and role dynamically from current user metadata or route arguments
    final currentUser = supabase.auth.currentUser;
    final String role = currentUser?.userMetadata?['role'] ?? args?['role'] ?? 'Mahasiswa';

    final bool isMahasiswa = role == 'Mahasiswa';

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111D2C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: _goBack,
        ),
        title: Text(
          isMahasiswa
              ? 'Laporan Saya'
              : role == 'Admin'
              ? 'Kelola Laporan'
              : 'Tinjauan Laporan',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<List<LaporanModel>>(
        stream: isMahasiswa
            ? LaporanController.streamLaporanSaya()
            : LaporanController.streamAllLaporan(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Terjadi kesalahan: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2563EB)),
            );
          }

          final rawList = snapshot.data ?? [];

          // Apply role filtering if Kaprodi
          var roleFilteredList = rawList;

          // Apply tab filter (`_filterAktif`)
          final filteredList = _filterAktif == 'Semua'
              ? roleFilteredList
              : roleFilteredList.where((l) => l.status == _filterAktif).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: _filtersForRole(role).map((f) {
                    final sel = _filterAktif == f;
                    return GestureDetector(
                      onTap: () => setState(() => _filterAktif = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: sel
                              ? _getStatusColor(f, role)
                              : const Color(0xFF1A2940),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sel
                                ? _getStatusColor(f, role)
                                : const Color(0xFF2D3E55),
                          ),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // List laporan
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                    await Future.delayed(const Duration(milliseconds: 800));
                  },
                  color: isMahasiswa
                      ? const Color(0xFF2563EB)
                      : role == 'Admin'
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFF10B981),
                  backgroundColor: const Color(0xFF111D2C),
                  child: filteredList.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.6,
                            alignment: Alignment.center,
                            child: _buildEmpty(isMahasiswa),
                          ),
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: filteredList.length,
                          itemBuilder: (_, i) {
                            final laporan = filteredList[i];
                            final mappedLaporan = {
                              ...laporan.toMap(),
                              'id': laporan.kode,
                              'jenis': laporan.jenis,
                              'status': laporan.status,
                              'statusColor': _statusColor(laporan.status),
                              'lokasi': laporan.lokasi,
                              'tanggal': _formatTgl(laporan.tanggalKejadian),
                              'waktu': laporan.waktuKejadian ?? '-',
                              'nama_pelapor': laporan.namaPelapor,
                              'kronologi': laporan.kronologi,
                              'pelaku': laporan.pelaku,
                              'db_id': laporan.id,
                            };
                            return _laporanCard(mappedLaporan, isMahasiswa);
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),

      // FAB HANYA untuk Mahasiswa
      floatingActionButton: isMahasiswa
          ? FloatingActionButton.extended(
              onPressed: _goToFormLaporan,
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.add),
              label: const Text(
                'Buat Laporan Baru',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _laporanCard(Map<String, dynamic> laporan, bool isMahasiswa) {
    final sc = _statusColor(laporan['status']);

    return GestureDetector(
      onTap: () => isMahasiswa
          ? _goToStatusLaporan(laporan)
          : _goToDetailLaporan(laporan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2940),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: laporan['status'] == 'Menunggu Verifikasi' && !isMahasiswa
              ? const Color(0xFF3B82F6).withValues(alpha: 0.5)
              : const Color(0xFF2D3E55),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris 1: titik + jenis + badge status
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: sc, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    laporan['jenis'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: sc.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    laporan['status'],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: sc,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Baris 2: ID + lokasi
            Row(
              children: [
                const Icon(Icons.tag, size: 12, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  laporan['id'],
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.location_on_outlined,
                  size: 12,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    laporan['lokasi'],
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Baris 3: tanggal + waktu (+ nama pelapor untuk Admin/Kaprodi)
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 12,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
                Text(
                  '${laporan['tanggal']} · ${laporan['waktu']}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
                if (!isMahasiswa) ...[
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.person_outline,
                    size: 12,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      laporan['nama_pelapor'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),

            // Tombol Lihat Detail — HANYA Admin & Kaprodi
            if (!isMahasiswa) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _goToDetailLaporan(laporan),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 0,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.visibility_outlined, size: 14),
                    label: const Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isMahasiswa) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2940),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Color(0xFF64748B),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada laporan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isMahasiswa
                ? 'Ketuk tombol + untuk membuat laporan baru'
                : 'Tidak ada laporan dengan filter ini',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
