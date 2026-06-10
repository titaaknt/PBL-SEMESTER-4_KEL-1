import 'package:flutter/material.dart';
import '../../controllers/supabase_client.dart';
import '../../controllers/laporan_controller.dart';
import '../../controllers/notifikasi_controller.dart';
import '../../models/laporan_model.dart';
import '../../models/notifikasi_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  String _filterStatus = 'Semua';
  final List<String> _filterOptions = [
    'Semua',
    'Menunggu Verifikasi',
    'Diproses',
    'Selesai',
    'Tidak Valid',
  ];

  // -------------------------------------------------------
  // NAVIGATION METHODS
  // -------------------------------------------------------
  void _goToFormLaporan() {
    Navigator.pushNamed(context, '/form-laporan');
  }

  void _goToStatusLaporan(Map<String, dynamic> laporan) {
    Navigator.pushNamed(context, '/status-laporan', arguments: laporan);
  }

  // ← DITAMBAHKAN: method untuk tab Laporan
  void _goToDaftarLaporan(String nim, String role) {
    Navigator.pushNamed(
      context,
      '/daftar-laporan',
      arguments: {'nim': nim, 'role': role},
    );
  }

  void _goToNotifikasi() {
    Navigator.pushNamed(context, '/notifikasi');
  }

  void _goToProfil(String nim, String role) {
    Navigator.pushNamed(context, '/profil', arguments: {'nim': nim, 'role': role});
  }

  void _onBottomNavTap(int index, String nim, String role) {
    if (index == _selectedIndex) return;
    // ← DITAMBAHKAN: case index 1 untuk tab Laporan
    if (index == 1) {
      _goToDaftarLaporan(nim, role);
      return;
    }
    if (index == 2) {
      _goToNotifikasi();
      return;
    }
    if (index == 3) {
      _goToProfil(nim, role);
      return;
    }
    setState(() => _selectedIndex = index);
  }

  // -------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    
    // Resolve NIM and role from current user metadata or route arguments
    final currentUser = supabase.auth.currentUser;
    final String nim = currentUser?.userMetadata?['nim'] ?? args?['nim'] ?? '244107060026';
    final String role = currentUser?.userMetadata?['role'] ?? args?['role'] ?? 'Mahasiswa';

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      bottomNavigationBar: _buildBottomNav(nim, role),
      body: SafeArea(
        child: StreamBuilder<List<LaporanModel>>(
          stream: LaporanController.streamLaporanSaya(),
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

            final laporanList = snapshot.data ?? [];
            final total = laporanList.length;
            final menunggu = laporanList.where((l) => l.status == 'Menunggu Verifikasi').length;
            final diproses = laporanList.where((l) => l.status == 'Diproses').length;
            final selesai = laporanList.where((l) => l.status == 'Selesai').length;
            final tidakValid = laporanList.where((l) => l.status == 'Tidak Valid').length;

            final filteredList = _filterStatus == 'Semua'
                ? laporanList
                : laporanList.where((l) => l.status == _filterStatus).toList();

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
                await Future.delayed(const Duration(milliseconds: 800));
              },
              color: const Color(0xFF2563EB),
              backgroundColor: const Color(0xFF111D2C),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dashboard',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Halo, $nim 👋',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFF2563EB),
                        child: Text(
                          nim.isNotEmpty ? nim[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Stats Row
                  Column(
                    children: [
                      Row(
                        children: [
                          _statCard(
                            '$total',
                            'Total Laporan',
                            const Color(0xFF1E3A8A),
                            const Color(0xFF3B82F6),
                            onTap: () => setState(() => _filterStatus = 'Semua'),
                          ),
                          const SizedBox(width: 12),
                          _statCard(
                            '$menunggu',
                            'Menunggu Verifikasi',
                            const Color(0xFF1E3A8A),
                            const Color(0xFF3B82F6),
                            onTap: () => setState(() => _filterStatus = 'Menunggu Verifikasi'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _statCard(
                            '$diproses',
                            'Diproses',
                            const Color(0xFF78350F),
                            const Color(0xFFF59E0B),
                            onTap: () => setState(() => _filterStatus = 'Diproses'),
                          ),
                          const SizedBox(width: 8),
                          _statCard(
                            '$selesai',
                            'Selesai',
                            const Color(0xFF064E3B),
                            const Color(0xFF10B981),
                            onTap: () => setState(() => _filterStatus = 'Selesai'),
                          ),
                          const SizedBox(width: 8),
                          _statCard(
                            '$tidakValid',
                            'Tidak Valid',
                            const Color(0xFF5B1B1B),
                            const Color(0xFFEF4444),
                            onTap: () => setState(() => _filterStatus = 'Tidak Valid'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Laporan Saya',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filterOptions.map((f) {
                        final sel = _filterStatus == f;
                        return GestureDetector(
                          onTap: () => setState(() => _filterStatus = f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: sel ? _getStatusColor(f) : const Color(0xFF1A2940),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: sel ? _getStatusColor(f) : const Color(0xFF2D3E55),
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
                  const SizedBox(height: 14),
                  // Laporan List
                  if (filteredList.isEmpty)
                    _buildEmpty()
                  else
                    ...filteredList.map((laporan) {
                      return _laporanCard(laporan);
                    }),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToFormLaporan,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text(
          'Buat Laporan Baru',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _statCard(
    String value,
    String label,
    Color bgColor,
    Color accentColor, {
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: bgColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: accentColor.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _laporanCard(LaporanModel laporan) {
    final statusColor = _statusColor(laporan.status);
    return GestureDetector(
      onTap: () => _goToStatusLaporan({
        'id': laporan.kode,
        'db_id': laporan.id,
        'jenis': laporan.jenis,
        'status': laporan.status,
        'statusColor': statusColor,
        'date': _formatTgl(laporan.tanggalKejadian),
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2940),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2D3E55)),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    laporan.jenis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    laporan.kode,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                laporan.status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(String nim, String role) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111D2C),
        border: Border(top: BorderSide(color: Color(0xFF2D3E55))),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => _onBottomNavTap(i, nim, role),
        backgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFF3B82F6),
        unselectedItemColor: const Color(0xFF64748B),
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: StreamBuilder<List<NotifikasiModel>>(
              stream: NotifikasiController.streamNotifikasi(),
              builder: (context, snapshot) {
                final count = (snapshot.data ?? [])
                    .where((n) => n.dibaca == false)
                    .length;
                return Badge(
                  label: Text('$count'),
                  isLabelVisible: count > 0,
                  backgroundColor: const Color(0xFFEF4444),
                  textColor: Colors.white,
                  child: const Icon(Icons.notifications_outlined),
                );
              },
            ),
            label: 'Notif',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
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

  Color _getStatusColor(String status) {
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
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
            'Belum ada laporan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ketuk tombol di bawah untuk membuat laporan baru',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}