import 'package:flutter/material.dart';

class DaftarLaporanPage extends StatefulWidget {
  const DaftarLaporanPage({super.key});

  @override
  State<DaftarLaporanPage> createState() => _DaftarLaporanPageState();
}

class _DaftarLaporanPageState extends State<DaftarLaporanPage> {
  String _filterAktif = 'Semua';

  final List<String> _filters = ['Semua', 'Menunggu', 'Diproses', 'Selesai'];

  final List<Map<String, dynamic>> _semuaLaporan = [
    {
      'id': 'RPT-2026-001',
      'jenis': 'Verbal Bullying',
      'lokasi': 'Gedung D - Teknologi Informasi',
      'status': 'Diproses',
      'statusColor': Color(0xFFF59E0B),
      'date': '8 Apr, 2026',
      'time': '13:30',
    },
    {
      'id': 'RPT-2026-002',
      'jenis': 'Cyberbullying',
      'lokasi': 'Koperasi Mahasiswa',
      'status': 'Selesai',
      'statusColor': Color(0xFF10B981),
      'date': '5 Apr, 2026',
      'time': '09:15',
    },
    {
      'id': 'RPT-2026-003',
      'jenis': 'Verbal Bullying',
      'lokasi': 'Kantin Kampus',
      'status': 'Menunggu',
      'statusColor': Color(0xFF3B82F6),
      'date': '10 Apr, 2026',
      'time': '11:00',
    },
  ];

  // -------------------------------------------------------
  // NAVIGATION METHODS
  // -------------------------------------------------------
  void _goBack() {
    Navigator.pop(context);
  }

  void _goToStatusLaporan(Map<String, dynamic> laporan) {
    Navigator.pushNamed(context, '/status-laporan', arguments: laporan);
  }

  void _goToFormLaporan() {
    Navigator.pushNamed(context, '/form-laporan');
  }

  // -------------------------------------------------------

  List<Map<String, dynamic>> get _filtered {
    if (_filterAktif == 'Semua') return _semuaLaporan;
    return _semuaLaporan.where((l) {
      if (_filterAktif == 'Menunggu') return l['status'] == 'Menunggu';
      return l['status'] == _filterAktif;
    }).toList();
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
        title: const Text('Laporan Saya',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF3B82F6)),
            onPressed: _goToFormLaporan,
            tooltip: 'Buat laporan baru',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: _filters.map((f) {
                final sel = _filterAktif == f;
                return GestureDetector(
                  onTap: () => setState(() => _filterAktif = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? const Color(0xFF2563EB) : const Color(0xFF1A2940),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? const Color(0xFF3B82F6) : const Color(0xFF2D3E55)),
                    ),
                    child: Text(f,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : const Color(0xFF64748B))),
                  ),
                );
              }).toList(),
            ),
          ),

          // List laporan
          Expanded(
            child: _filtered.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) => _laporanCard(_filtered[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToFormLaporan,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text('Laporan Baru', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(color: laporan['statusColor'], shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(laporan['jenis'],
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (laporan['statusColor'] as Color).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(laporan['status'],
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: laporan['statusColor'])),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.tag, size: 12, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(laporan['id'], style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                const SizedBox(width: 14),
                const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(laporan['lokasi'],
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text('${laporan['date']} · ${laporan['time']}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(color: const Color(0xFF1A2940), borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.description_outlined, color: Color(0xFF64748B), size: 32),
          ),
          const SizedBox(height: 16),
          const Text('Belum ada laporan',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Ketuk tombol + untuk membuat laporan baru',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        ],
      ),
    );
  }
}
