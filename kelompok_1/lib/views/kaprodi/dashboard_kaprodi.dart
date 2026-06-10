import 'package:flutter/material.dart';
import '../../controllers/laporan_controller.dart';
import '../../controllers/notifikasi_controller.dart';
import '../../models/laporan_model.dart';
import '../../models/notifikasi_model.dart';

class DashboardKaprodiPage extends StatefulWidget {
  const DashboardKaprodiPage({super.key});
  @override
  State<DashboardKaprodiPage> createState() => _DashboardKaprodiPageState();
}

class _DashboardKaprodiPageState extends State<DashboardKaprodiPage> {
  int    _selectedIndex = 0;
  String _filterStatus  = 'Semua';

  final List<String> _filterOptions = [
    'Semua',
    'Menunggu Verifikasi',
    'Diproses',
    'Selesai',
    'Tidak Valid',
  ];

  void _goToDetailLaporan(LaporanModel laporan) =>
      Navigator.pushNamed(context, '/detail-laporan', arguments: laporan.toMap()..['db_id'] = laporan.id);
  void _goToDaftarLaporan(String nim, String role) =>
      Navigator.pushNamed(context, '/daftar-laporan', arguments: {'nim': nim, 'role': role});
  void _goToNotifikasi() => Navigator.pushNamed(context, '/notifikasi');
  void _goToProfil(String nim, String role) =>
      Navigator.pushNamed(context, '/profil', arguments: {'nim': nim, 'role': role});

  void _onBottomNavTap(int index, String nim, String role) {
    if (index == 1) { _goToDaftarLaporan(nim, role); return; }
    if (index == 2) { _goToNotifikasi(); return; }
    if (index == 3) { _goToProfil(nim, role); return; }
    setState(() => _selectedIndex = index);
  }

  // ── FORM TINDAK LANJUT ─────────────────────────────────
  void _showFormTindakLanjut(LaporanModel laporan) {
    final tindakanCtrl = TextEditingController(text: laporan.tindakan ?? '');
    final catatanCtrl  = TextEditingController(text: laporan.catatanKaprodi ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A2940),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFF2D3E55), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),

            Row(children: [
              const Icon(Icons.gavel_rounded, color: Color(0xFF10B981), size: 20),
              const SizedBox(width: 8),
              const Text('Tindak Lanjut Kaprodi',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            ]),
            const SizedBox(height: 4),
            Text('${laporan.kode} · ${laporan.jenis}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
            const SizedBox(height: 20),

            // Tindakan
            const Text('Tindakan yang Dilakukan *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
            const SizedBox(height: 8),
            TextField(
              controller: tindakanCtrl, maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: _inputDeco('Contoh: Surat peringatan diterbitkan...'),
            ),
            const SizedBox(height: 14),

            // Catatan
            const Text('Catatan Tambahan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
            const SizedBox(height: 8),
            TextField(
              controller: catatanCtrl, maxLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: _inputDeco('Catatan tambahan (opsional)'),
            ),
            const SizedBox(height: 20),

            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  side: const BorderSide(color: Color(0xFF2D3E55)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Batal'),
              )),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: ElevatedButton.icon(
                onPressed: () async {
                  if (tindakanCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Isi tindakan terlebih dahulu'),
                      backgroundColor: Color(0xFFEF4444),
                    ));
                    return;
                  }
                  Navigator.pop(ctx);
                  try {
                    await LaporanController.tindakLanjutLaporan(
                      id      : laporan.id,
                      status  : 'Selesai',
                      tindakan: tindakanCtrl.text.trim(),
                      catatan : catatanCtrl.text.trim().isEmpty ? null : catatanCtrl.text.trim(),
                    );
                    // ↑ Trigger DB otomatis kirim notif ke Mahasiswa
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Tindak lanjut laporan ${laporan.kode} berhasil disimpan'),
                          backgroundColor: const Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(16),
                        ));
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFFEF4444)));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14), elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Simpan Tindak Lanjut', style: TextStyle(fontWeight: FontWeight.w600)),
                )),
              ]),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      );
    }

  @override
  Widget build(BuildContext context) {
    final args    = ModalRoute.of(context)?.settings.arguments as Map?;
    final String nim  = args?['nim']  ?? 'Kaprodi';
    final String role = args?['role'] ?? 'Kaprodi';

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      bottomNavigationBar: _buildBottomNav(nim, role),

      body: StreamBuilder<List<LaporanModel>>(
        stream: LaporanController.streamAllLaporan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
          }

          final all = snapshot.data ?? [];

          final filtered = _filterStatus == 'Semua'
              ? all
              : all.where((l) => l.status == _filterStatus).toList();

          final menunggu  = all.where((l) => l.status == 'Menunggu Verifikasi').length;
          final diproses  = all.where((l) => l.status == 'Diproses').length;
          final selesai   = all.where((l) => l.status == 'Selesai').length;
          final tidakValid = all.where((l) => l.status == 'Tidak Valid').length;

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {});
                await Future.delayed(const Duration(milliseconds: 800));
              },
              color: const Color(0xFF10B981),
              backgroundColor: const Color(0xFF111D2C),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Panel Kaprodi',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text('Halo, $nim 👋',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                  ]),
                ]),
                const SizedBox(height: 20),

                // Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.supervisor_account, color: Color(0xFF10B981), size: 18),
                    SizedBox(width: 10),
                    Expanded(child: Text(
                      'Kamu login sebagai Kaprodi · Tinjau & tindaklanjuti laporan',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6EE7B7)),
                    )),
                  ]),
                ),
                const SizedBox(height: 20),

                // Stats
                Column(
                  children: [
                    Row(
                      children: [
                        _statCard(
                          '${all.length}',
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

                // Progress card
                _ringkasanCard(diproses, selesai, all.length),
                const SizedBox(height: 24),

                const Text('Daftar Laporan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 12),

                // Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: _filterOptions.map((f) {
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
                          border: Border.all(color: sel ? _getStatusColor(f) : const Color(0xFF2D3E55)),
                        ),
                        child: Text(f, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : const Color(0xFF64748B))),
                      ),
                    );
                  }).toList()),
                ),
                const SizedBox(height: 14),

                ...filtered.map((l) => _kaprodiCard(l)),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        );
        },
      ),
    );
  }

  Widget _kaprodiCard(LaporanModel laporan) {
    final String status = laporan.status;
    final Color  sc     = _statusColor(status);
    final String? hasilMediasi = laporan.hasilMediasi;
    final bool adaHasilMediasi = hasilMediasi != null && hasilMediasi.isNotEmpty;
    final bool bisaAksi = status == 'Diproses' && adaHasilMediasi;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2940), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2D3E55)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: sc, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(laporan.jenis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: sc.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: sc)),
          ),
        ]),
        const SizedBox(height: 8),
        Text(laporan.kode, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        if (adaHasilMediasi) ...[
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF0D1B2A), borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Hasil Penanganan Satgas:', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              const SizedBox(height: 2),
              Text(hasilMediasi, style: const TextStyle(fontSize: 12, color: Colors.white)),
            ]),
          ),
        ],
        if (laporan.tindakan != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF0D1B2A), borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Tindakan:', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              const SizedBox(height: 2),
              Text(laporan.tindakan!, style: const TextStyle(fontSize: 12, color: Colors.white)),
              if (laporan.catatanKaprodi != null && laporan.catatanKaprodi!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(laporan.catatanKaprodi!, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ]),
          ),
        ],
        const SizedBox(height: 10),
        Row(children: [
          TextButton(
            onPressed: () => _goToDetailLaporan(laporan),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B82F6),
                minimumSize: const Size(0, 32), padding: const EdgeInsets.symmetric(horizontal: 8)),
            child: const Text('Lihat Detail →', style: TextStyle(fontSize: 11)),
          ),
          const Spacer(),
          if (status == 'Diproses' && !adaHasilMediasi)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.hourglass_empty_rounded, size: 12, color: Color(0xFFEF4444)),
                  SizedBox(width: 4),
                  Text(
                    'Menunggu Hasil Mediasi',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFEF4444)),
                  ),
                ],
              ),
            )
          else if (bisaAksi)
            ElevatedButton.icon(
              onPressed: () => _showFormTindakLanjut(laporan),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white,
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0,
              ),
              icon: const Icon(Icons.gavel_rounded, size: 14),
              label: const Text('Tindak Lanjut', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ),
        ]),
      ]),
    );
  }

  Widget _ringkasanCard(int diproses, int selesai, int total) {
    final pct = total == 0 ? 0.0 : selesai / total;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF064E3B), Color(0xFF1A2940)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Ringkasan Penanganan',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${(pct * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
            const Text('Tingkat Penyelesaian', style: TextStyle(fontSize: 11, color: Color(0xFF6EE7B7))),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _infoRow(Icons.pending_outlined, '$diproses kasus diproses', const Color(0xFFF59E0B)),
            const SizedBox(height: 6),
            _infoRow(Icons.check_circle_outline, '$selesai kasus selesai', const Color(0xFF10B981)),
          ]),
        ]),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: pct, backgroundColor: const Color(0xFF1E3A8A),
              color: const Color(0xFF10B981), minHeight: 6)),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) => Row(children: [
    Icon(icon, size: 13, color: color), const SizedBox(width: 6),
    Text(text, style: TextStyle(fontSize: 11, color: color)),
  ]);

  Color _statusColor(String s) {
    switch (s) {
      case 'Diproses':    return const Color(0xFFF59E0B);
      case 'Selesai':     return const Color(0xFF10B981);
      case 'Tidak Valid': return const Color(0xFFEF4444);
      case 'Menunggu Verifikasi': return const Color(0xFF3B82F6);
      default:            return const Color(0xFF64748B);
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
        return const Color(0xFF10B981);
    }
  }

  Widget _statCard(
    String value,
    String label,
    Color bg,
    Color accent, {
    required VoidCallback onTap,
  }) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: bg.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: accent.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );



  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
    filled: true, fillColor: const Color(0xFF0D1B2A),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D3E55))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2D3E55))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5)),
  );

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
        selectedItemColor: const Color(0xFF10B981),
        unselectedItemColor: const Color(0xFF64748B),
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed, elevation: 0,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: 'Laporan'),
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
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}