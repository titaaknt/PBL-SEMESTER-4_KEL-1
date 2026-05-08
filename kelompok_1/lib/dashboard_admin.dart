import 'package:flutter/material.dart';
import 'detail_laporan.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _semuaLaporan = [
    {
      'id': 'RPT-2026-001',
      'jenis': 'Verbal Bullying',
      'pelapor': '244107060026',
      'status': 'Menunggu Verifikasi',
      'statusColor': Color(0xFF3B82F6),
      'date': '8 Apr, 2026',
      'prioritas': 'Sedang',
    },
    {
      'id': 'RPT-2026-002',
      'jenis': 'Cyberbullying',
      'pelapor': '244107060031',
      'status': 'Diproses',
      'statusColor': Color(0xFFF59E0B),
      'date': '5 Apr, 2026',
      'prioritas': 'Tinggi',
    },
    {
      'id': 'RPT-2026-003',
      'jenis': 'Fisik',
      'pelapor': '244107060012',
      'status': 'Selesai',
      'statusColor': Color(0xFF10B981),
      'date': '2 Apr, 2026',
      'prioritas': 'Tinggi',
    },
    {
      'id': 'RPT-2026-004',
      'jenis': 'Seksual',
      'pelapor': '244107060044',
      'status': 'Menunggu Verifikasi',
      'statusColor': Color(0xFF3B82F6),
      'date': '10 Apr, 2026',
      'prioritas': 'Tinggi',
    },
  ];

  // -------------------------------------------------------
  // NAVIGATION METHODS
  // -------------------------------------------------------
  void _goToDetailLaporan(Map<String, dynamic> laporan) {
    Navigator.pushNamed(
    context,
    '/detail-laporan',
    arguments: laporan,
  );
  }

  void _goToNotifikasi() {
    Navigator.pushNamed(context, '/notifikasi');
  }

  void _goToProfil(String nim, String role) {
    Navigator.pushNamed(context, '/profil', arguments: {'nim': nim, 'role': role});
  }

  void _onBottomNavTap(int index, String nim, String role) {
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

  void _verifikasiLaporan(String id) {
    setState(() {
      final laporan = _semuaLaporan.firstWhere((l) => l['id'] == id);
      laporan['status'] = 'Diproses';
      laporan['statusColor'] = const Color(0xFFF59E0B);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Laporan $id berhasil diverifikasi'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  int get _menunggu => _semuaLaporan.where((l) => l['status'] == 'Menunggu Verifikasi').length;
  int get _diproses => _semuaLaporan.where((l) => l['status'] == 'Diproses').length;
  int get _selesai => _semuaLaporan.where((l) => l['status'] == 'Selesai').length;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final String nim = args?['nim'] ?? 'Admin';
    final String role = args?['role'] ?? 'Admin';

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      bottomNavigationBar: _buildBottomNav(nim, role),
      body: SafeArea(
        child: SingleChildScrollView(
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
                        'Panel Admin',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      Text(
                        'Halo, $nim 👋',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF7C3AED),
                    child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Banner info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings, color: Color(0xFF3B82F6), size: 18),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Kamu login sebagai Admin · Kelola & verifikasi laporan masuk',
                        style: TextStyle(fontSize: 12, color: Color(0xFF93C5FD)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Stats
              Row(
                children: [
                  _statCard('${_semuaLaporan.length}', 'Total', const Color(0xFF1E3A8A), const Color(0xFF3B82F6)),
                  const SizedBox(width: 8),
                  _statCard('$_menunggu', 'Menunggu', const Color(0xFF1E3A8A), const Color(0xFF3B82F6)),
                  const SizedBox(width: 8),
                  _statCard('$_diproses', 'Diproses', const Color(0xFF78350F), const Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  _statCard('$_selesai', 'Selesai', const Color(0xFF064E3B), const Color(0xFF10B981)),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Semua Laporan Masuk',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 14),

              ..._semuaLaporan.map((laporan) => _adminLaporanCard(laporan)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, Color bgColor, Color accentColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: accentColor)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }

  Widget _adminLaporanCard(Map<String, dynamic> laporan) {
    final bool menunggu = laporan['status'] == 'Menunggu Verifikasi';
    final Color prioritasColor = laporan['prioritas'] == 'Tinggi'
        ? const Color(0xFFEF4444)
        : const Color(0xFFF59E0B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2940),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: menunggu
              ? const Color(0xFF3B82F6).withOpacity(0.5)
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
                decoration: BoxDecoration(color: laporan['statusColor'], shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  laporan['jenis'],
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: prioritasColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  laporan['prioritas'],
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: prioritasColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.badge_outlined, size: 13, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(laporan['pelapor'], style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              const SizedBox(width: 12),
              const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(laporan['date'], style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (laporan['statusColor'] as Color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  laporan['status'],
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: laporan['statusColor']),
                ),
              ),
              const Spacer(),
              if (menunggu)
                ElevatedButton(
                  onPressed: () => _verifikasiLaporan(laporan['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Verifikasi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                )
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
    );
  }

  Widget _buildBottomNav(String nim, String role) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.list_alt_rounded, 'label': 'Laporan'},
      {'icon': Icons.notifications_outlined, 'label': 'Notif'},
      {'icon': Icons.person_outline, 'label': 'Profil'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111D2C),
        border: Border(top: BorderSide(color: const Color(0xFF2D3E55))),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => _onBottomNavTap(i, nim, role),
        backgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFF7C3AED),
        unselectedItemColor: const Color(0xFF64748B),
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: items
            .map((e) => BottomNavigationBarItem(
                  icon: Icon(e['icon'] as IconData),
                  label: e['label'] as String,
                ))
            .toList(),
      ),
    );
  }
}
