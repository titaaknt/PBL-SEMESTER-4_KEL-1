import 'package:flutter/material.dart';
import '../../controllers/laporan_controller.dart';
import '../../controllers/notifikasi_controller.dart';
import '../../models/laporan_model.dart';
import '../../models/notifikasi_model.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});
  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  int _selectedIndex = 0;
  String _filterStatus = 'Semua';
  final List<String> _filterOptions = [
    'Semua',
    'Menunggu Verifikasi',
    'Diproses',
    'Selesai',
    'Tidak Valid',
  ];

  void _goToDetailLaporan(LaporanModel laporan) =>
      Navigator.pushNamed(context, '/detail-laporan', arguments: laporan.toMap()..['db_id'] = laporan.id);

  void _goToDaftarLaporan(String nim, String role) => Navigator.pushNamed(
    context,
    '/daftar-laporan',
    arguments: {'nim': nim, 'role': role},
  );

  void _goToNotifikasi() => Navigator.pushNamed(context, '/notifikasi');

  void _goToProfil(String nim, String role) => Navigator.pushNamed(
    context,
    '/profil',
    arguments: {'nim': nim, 'role': role},
  );

  void _onBottomNavTap(int index, String nim, String role) {
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

  Future<void> _verifikasiLaporan(int id, String kode) async {
    try {
      await LaporanController.verifikasiLaporan(id);
      // Notifikasi ke MHS & Kaprodi dikirim OTOMATIS oleh trigger DB
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Laporan $kode berhasil diverifikasi'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal verifikasi: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _tolakLaporan(int id, String kode) async {
    try {
      await LaporanController.tolakLaporan(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Laporan $kode berhasil ditolak'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menolak laporan: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final String nim = args?['nim'] ?? 'Admin';
    final String role = args?['role'] ?? 'Admin';

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      bottomNavigationBar: _buildBottomNav(nim, role),

      // ── Realtime stream ──────────────────────────────────
      body: StreamBuilder<List<LaporanModel>>(
        stream: LaporanController.streamAllLaporan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
            );
          }

          final laporanList = snapshot.data ?? [];
          final menunggu = laporanList
              .where((l) => l.status == 'Menunggu Verifikasi')
              .length;
          final diproses = laporanList
              .where((l) => l.status == 'Diproses')
              .length;
          final selesai = laporanList
              .where((l) => l.status == 'Selesai')
              .length;
          final tidakValid = laporanList
              .where((l) => l.status == 'Tidak Valid')
              .length;

          final filteredList = _filterStatus == 'Semua'
              ? laporanList
              : laporanList.where((l) => l.status == _filterStatus).toList();

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
                await Future.delayed(const Duration(milliseconds: 800));
              },
              color: const Color(0xFF3B82F6),
              backgroundColor: const Color(0xFF111D2C),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ─────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Panel Admin',
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

                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Banner ─────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          color: Color(0xFF3B82F6),
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Kamu login sebagai Admin · Kelola & verifikasi laporan masuk',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF93C5FD),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Stats ──────────────────────────────────
                  Column(
                    children: [
                      Row(
                        children: [
                          _statCard(
                            '${laporanList.length}',
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
                  const SizedBox(height: 24),

                  const Text(
                    'Semua Laporan Masuk',
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

                  if (filteredList.isEmpty)
                    _buildEmptyAdmin()
                  else
                    ...filteredList.map((l) => _adminLaporanCard(l)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
        },
      ),
    );
  }

  Widget _adminLaporanCard(LaporanModel laporan) {
    final String status = laporan.status;
    final bool menunggu = status == 'Menunggu Verifikasi';
    final Color sc = _statusColor(status);
    final String prioritas = laporan.prioritas;
    final Color pc = prioritas == 'Tinggi'
        ? const Color(0xFFEF4444)
        : const Color(0xFFF59E0B);
    final int id = laporan.id;
    final String kode = laporan.kode;

    return GestureDetector(
      onTap: () => _goToDetailLaporan(laporan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2940),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: menunggu
                ? const Color(0xFF3B82F6).withValues(alpha: 0.5)
                : const Color(0xFF2D3E55),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: sc, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    laporan.jenis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: pc.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    prioritas,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: pc,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.badge_outlined,
                  size: 13,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
                Text(
                  laporan.nimPelapor,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTgl(laporan.createdAt),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
            if (laporan.tindakan != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1B2A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tindak Lanjut Kaprodi:',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      laporan.tindakan!,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    if (laporan.catatanKaprodi != null &&
                        laporan.catatanKaprodi!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        laporan.catatanKaprodi!,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
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
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: sc,
                    ),
                  ),
                ),
                const Spacer(),
                if (menunggu) ...[
                  OutlinedButton(
                    onPressed: () => _tolakLaporan(id, kode),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Tolak',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _verifikasiLaporan(id, kode),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Verifikasi',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ]
                else
                  TextButton(
                    onPressed: () => _goToDetailLaporan(laporan),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF3B82F6),
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text('Detail →', style: TextStyle(fontSize: 11)),
                  ),
              ],
            ),
          ],
        ),
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
        return const Color(0xFF3B82F6);
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
        selectedItemColor: const Color(0xFF7C3AED),
        unselectedItemColor: const Color(0xFF64748B),
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
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

  Widget _buildEmptyAdmin() {
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
            'Tidak ada laporan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tidak ada laporan dengan status ini',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Widget badge notifikasi ───────────────────────────────
class NotifBadge extends StatelessWidget {
  final VoidCallback onTap;
  const NotifBadge({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NotifikasiModel>>(
      stream: NotifikasiController.streamNotifikasi(),
      builder: (_, snap) {
        final count = (snap.data ?? [])
            .where((n) => n.dibaca == false)
            .length;
        return GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2940),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2D3E55)),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              if (count > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
