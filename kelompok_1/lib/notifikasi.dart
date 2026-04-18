import 'package:flutter/material.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  final List<Map<String, dynamic>> _notifikasi = [
    {
      'id': '1',
      'judul': 'Status Laporan Diperbarui',
      'pesan': 'Laporan RPT-2026-001 (Verbal Bullying) telah masuk ke tahap Tim Satgas.',
      'waktu': '8 Apr, 14:30',
      'icon': Icons.update_rounded,
      'iconColor': Color(0xFFF59E0B),
      'bgColor': Color(0xFF78350F),
      'dibaca': false,
    },
    {
      'id': '2',
      'judul': 'Laporan Terverifikasi',
      'pesan': 'Laporan RPT-2026-002 (Cyberbullying) telah diverifikasi oleh admin dan dinyatakan valid.',
      'waktu': '5 Apr, 14:00',
      'icon': Icons.verified_rounded,
      'iconColor': Color(0xFF10B981),
      'bgColor': Color(0xFF064E3B),
      'dibaca': false,
    },
    {
      'id': '3',
      'judul': 'Laporan Selesai Ditangani',
      'pesan': 'Laporan RPT-2026-002 (Cyberbullying) telah selesai ditangani oleh Tim Satgas.',
      'waktu': '7 Apr, 09:15',
      'icon': Icons.check_circle_rounded,
      'iconColor': Color(0xFF10B981),
      'bgColor': Color(0xFF064E3B),
      'dibaca': true,
    },
    {
      'id': '4',
      'judul': 'Laporan Diterima',
      'pesan': 'Laporan RPT-2026-001 kamu berhasil diterima sistem dan menunggu verifikasi admin.',
      'waktu': '8 Apr, 13:30',
      'icon': Icons.inbox_rounded,
      'iconColor': Color(0xFF3B82F6),
      'bgColor': Color(0xFF1E3A8A),
      'dibaca': true,
    },
  ];

  // -------------------------------------------------------
  // NAVIGATION METHODS
  // -------------------------------------------------------
  void _goBack() {
    Navigator.pop(context);
  }

  // -------------------------------------------------------

  void _tandaiBacaSemua() {
    setState(() {
      for (final notif in _notifikasi) {
        notif['dibaca'] = true;
      }
    });
  }

  void _tandaiBaca(String id) {
    setState(() {
      final notif = _notifikasi.firstWhere((n) => n['id'] == id);
      notif['dibaca'] = true;
    });
  }

  int get _belumDibaca => _notifikasi.where((n) => n['dibaca'] == false).length;

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
        title: Row(
          children: [
            const Text(
              'Notifikasi',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            if (_belumDibaca > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_belumDibaca',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ]
          ],
        ),
        actions: [
          if (_belumDibaca > 0)
            TextButton(
              onPressed: _tandaiBacaSemua,
              child: const Text(
                'Baca Semua',
                style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12),
              ),
            ),
        ],
      ),
      body: _notifikasi.isEmpty
          ? _buildEmpty()
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _notifikasi.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notif = _notifikasi[index];
                return _notifCard(notif);
              },
            ),
    );
  }

  Widget _notifCard(Map<String, dynamic> notif) {
    final bool dibaca = notif['dibaca'] as bool;
    return GestureDetector(
      onTap: () => _tandaiBaca(notif['id']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: dibaca ? const Color(0xFF1A2940) : const Color(0xFF1E2D45),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: dibaca ? const Color(0xFF2D3E55) : const Color(0xFF3B82F6).withOpacity(0.4),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: (notif['bgColor'] as Color).withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                notif['icon'] as IconData,
                color: notif['iconColor'] as Color,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif['judul'],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: dibaca ? const Color(0xFF94A3B8) : Colors.white,
                          ),
                        ),
                      ),
                      if (!dibaca)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif['pesan'],
                    style: TextStyle(
                      fontSize: 12,
                      color: dibaca ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif['waktu'],
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
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
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2940),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.notifications_off_outlined, color: Color(0xFF64748B), size: 32),
          ),
          const SizedBox(height: 16),
          const Text('Belum ada notifikasi', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Notifikasi akan muncul di sini', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        ],
      ),
    );
  }
}
