import 'package:flutter/material.dart';
import 'detail_laporan.dart';

class DashboardKaprodiPage extends StatefulWidget {
  const DashboardKaprodiPage({super.key});

  @override
  State<DashboardKaprodiPage> createState() => _DashboardKaprodiPageState();
}

class _DashboardKaprodiPageState extends State<DashboardKaprodiPage> {
  int _selectedIndex = 0;
  String _filterStatus = 'Semua';

  final List<String> _filterOptions = ['Semua', 'Diproses', 'Selesai', 'Ditolak'];

  final List<Map<String, dynamic>> _laporanKaprodi = [
    {
      'id': 'RPT-2026-002',
      'jenis': 'Cyberbullying',
      'pelapor': '244107060031',
      'status': 'Diproses',
      'statusColor': Color(0xFFF59E0B),
      'date': '5 Apr, 2026',
      'tindakan': 'Surat peringatan telah diterbitkan',
      'catatan': 'Pelaku diminta menghadap satgas pada 12 Apr 2026',
    },
    {
      'id': 'RPT-2026-003',
      'jenis': 'Fisik',
      'pelapor': '244107060012',
      'status': 'Selesai',
      'statusColor': Color(0xFF10B981),
      'date': '2 Apr, 2026',
      'tindakan': 'Mediasi berhasil, kasus ditutup',
      'catatan': 'Kedua belah pihak sepakat berdamai',
    },
    {
      'id': 'RPT-2026-001',
      'jenis': 'Verbal Bullying',
      'pelapor': '244107060026',
      'status': 'Diproses',
      'statusColor': Color(0xFFF59E0B),
      'date': '8 Apr, 2026',
      'tindakan': 'Sedang investigasi',
      'catatan': 'Menunggu keterangan saksi',
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

  List<Map<String, dynamic>> get _filteredLaporan {
    if (_filterStatus == 'Semua') return _laporanKaprodi;
    return _laporanKaprodi.where((l) => l['status'] == _filterStatus).toList();
  }

  void _selesaikanLaporan(String id) {
    setState(() {
      final laporan = _laporanKaprodi.firstWhere((l) => l['id'] == id);
      laporan['status'] = 'Selesai';
      laporan['statusColor'] = const Color(0xFF10B981);
      laporan['tindakan'] = 'Ditinjau dan diselesaikan oleh Kaprodi';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Laporan $id ditandai selesai'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final String nim = args?['nim'] ?? 'Kaprodi';
    final String role = args?['role'] ?? 'Kaprodi';

    final int totalDisproses = _laporanKaprodi.where((l) => l['status'] == 'Diproses').length;
    final int totalSelesai = _laporanKaprodi.where((l) => l['status'] == 'Selesai').length;

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
                        'Panel Kaprodi',
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
                    backgroundColor: const Color(0xFF10B981),
                    child: const Icon(Icons.supervisor_account, color: Colors.white, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Banner info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.supervisor_account, color: Color(0xFF10B981), size: 18),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Kamu login sebagai Kaprodi · Tinjau & tutup laporan yang sudah ditangani',
                        style: TextStyle(fontSize: 12, color: Color(0xFF6EE7B7)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Stats
              Row(
                children: [
                  _statCard('${_laporanKaprodi.length}', 'Total', const Color(0xFF1E3A8A), const Color(0xFF3B82F6)),
                  const SizedBox(width: 10),
                  _statCard('$totalDisproses', 'Diproses', const Color(0xFF78350F), const Color(0xFFF59E0B)),
                  const SizedBox(width: 10),
                  _statCard('$totalSelesai', 'Selesai', const Color(0xFF064E3B), const Color(0xFF10B981)),
                ],
              ),
              const SizedBox(height: 24),

              // Grafik Ringkasan
              _ringkasanCard(totalDisproses, totalSelesai),
              const SizedBox(height: 24),

              // Filter & List
              const Text(
                'Daftar Laporan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 12),
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filterOptions.map((f) {
                    final isSelected = _filterStatus == f;
                    return GestureDetector(
                      onTap: () => setState(() => _filterStatus = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF10B981) : const Color(0xFF1A2940),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF10B981) : const Color(0xFF2D3E55),
                          ),
                        ),
                        child: Text(
                          f,
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
              ),
              const SizedBox(height: 14),

              ..._filteredLaporan.map((laporan) => _kaprodiLaporanCard(laporan)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ringkasanCard(int diproses, int selesai) {
    final total = _laporanKaprodi.length;
    final pctSelesai = total == 0 ? 0.0 : selesai / total;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF1A2940)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Penanganan',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(pctSelesai * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF10B981)),
                    ),
                    const Text('Tingkat Penyelesaian', style: TextStyle(fontSize: 11, color: Color(0xFF6EE7B7))),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(Icons.pending_outlined, '$diproses kasus masih diproses', const Color(0xFFF59E0B)),
                  const SizedBox(height: 6),
                  _infoRow(Icons.check_circle_outline, '$selesai kasus selesai', const Color(0xFF10B981)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pctSelesai,
              backgroundColor: const Color(0xFF1E3A8A),
              color: const Color(0xFF10B981),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }

  Widget _kaprodiLaporanCard(Map<String, dynamic> laporan) {
    final bool bisaSelesai = laporan['status'] == 'Diproses';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2940),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2D3E55)),
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
            ],
          ),
          const SizedBox(height: 8),
          Text(laporan['id'], style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 6),
          // Tindakan
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tindakan:', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                const SizedBox(height: 2),
                Text(laporan['tindakan'], style: const TextStyle(fontSize: 12, color: Colors.white)),
                if ((laporan['catatan'] as String).isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(laporan['catatan'], style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                ]
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton(
                onPressed: () => _goToDetailLaporan(laporan),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('Lihat Detail →', style: TextStyle(fontSize: 11)),
              ),
              const Spacer(),
              if (bisaSelesai)
                ElevatedButton(
                  onPressed: () => _selesaikanLaporan(laporan['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Tandai Selesai', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ],
      ),
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
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: accentColor)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ],
        ),
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
        selectedItemColor: const Color(0xFF10B981),
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
