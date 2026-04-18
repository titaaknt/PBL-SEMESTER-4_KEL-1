import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _laporanList = [
    {
      'id': 'RPT-2026-001',
      'jenis': 'Verbal Bullying',
      'status': 'Diproses',
      'statusColor': Color(0xFFF59E0B),
      'date': '8 Apr, 2026',
    },
    {
      'id': 'RPT-2026-002',
      'jenis': 'Cyberbullying',
      'status': 'Selesai',
      'statusColor': Color(0xFF10B981),
      'date': '5 Apr, 2026',
    },
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

  void _goToNotifikasi() {
    Navigator.pushNamed(context, '/notifikasi');
  }

  void _goToProfil(String nim, String role) {
    Navigator.pushNamed(context, '/profil', arguments: {'nim': nim, 'role': role});
  }

  void _onBottomNavTap(int index, String nim, String role) {
    if (index == _selectedIndex) return;
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
    final String nim = args?['nim'] ?? '244107060026';
    final String role = args?['role'] ?? 'Mahasiswa';

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
              Row(
                children: [
                  _statCard('${_laporanList.length}', 'Total', const Color(0xFF1E3A8A), const Color(0xFF3B82F6)),
                  const SizedBox(width: 10),
                  _statCard('1', 'Diproses', const Color(0xFF78350F), const Color(0xFFF59E0B)),
                  const SizedBox(width: 10),
                  _statCard('1', 'Selesai', const Color(0xFF064E3B), const Color(0xFF10B981)),
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
              const SizedBox(height: 14),
              // Laporan List
              ..._laporanList.map((laporan) => _laporanCard(laporan)),
              const SizedBox(height: 80),
            ],
          ),
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

  Widget _statCard(String value, String label, Color bgColor, Color accentColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accentColor.withOpacity(0.4)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _laporanCard(Map<String, dynamic> laporan) {
    return GestureDetector(
      onTap: () => _goToStatusLaporan(laporan),
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
                color: laporan['statusColor'],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    laporan['jenis'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    laporan['id'],
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: (laporan['statusColor'] as Color).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                laporan['status'],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: laporan['statusColor'],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(String nim, String role) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.description_outlined, 'label': 'Laporan'},
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
        selectedItemColor: const Color(0xFF3B82F6),
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