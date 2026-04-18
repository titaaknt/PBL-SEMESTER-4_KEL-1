import 'package:flutter/material.dart';

class StatusLaporanPage extends StatelessWidget {
  const StatusLaporanPage({super.key});

  // -------------------------------------------------------
  // NAVIGATION METHODS
  // -------------------------------------------------------
  void _goBack(BuildContext context) {
    Navigator.pop(context);
  }

  // -------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final String id = args?['id'] ?? 'RPT-2026-001';
    final String jenis = args?['jenis'] ?? 'Verbal Bullying';
    final String status = args?['status'] ?? 'Diproses';
    final Color statusColor = args?['statusColor'] ?? const Color(0xFFF59E0B);
    final String date = args?['date'] ?? '8 Apr, 2026';

    final List<Map<String, dynamic>> timeline = [
      {
        'label': 'Laporan Dikirim',
        'time': '8 Apr, 13:30',
        'desc': 'Laporan berhasil dikirimkan ke sistem',
        'done': true,
        'color': const Color(0xFF10B981),
      },
      {
        'label': 'Verifikasi Admin',
        'time': '8 Apr, 14:00',
        'desc': 'Valid · Data dan bukti diperiksa admin',
        'done': true,
        'color': const Color(0xFF10B981),
      },
      {
        'label': 'Tim Satgas',
        'time': '',
        'desc': status == 'Selesai' ? 'Kasus selesai ditangani' : 'Sedang investigasi...',
        'done': status == 'Selesai',
        'color': const Color(0xFFF59E0B),
      },
      {
        'label': 'Laporan Kaprodi',
        'time': '',
        'desc': status == 'Selesai' ? 'Ditinjau Kaprodi' : 'Menunggu...',
        'done': false,
        'color': const Color(0xFF64748B),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111D2C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => _goBack(context),
        ),
        title: const Text(
          'Status Laporan',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header Laporan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF1A2940)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2D4E8A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        id,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF93C5FD), fontWeight: FontWeight.w500),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withOpacity(0.4)),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    jenis,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dilaporkan $date',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Riwayat Penanganan',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 20),
            // Timeline
            ...List.generate(timeline.length, (i) {
              final item = timeline[i];
              final isLast = i == timeline.length - 1;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: (item['done'] as bool)
                              ? (item['color'] as Color).withOpacity(0.2)
                              : const Color(0xFF1A2940),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: (item['done'] as bool) ? item['color'] as Color : const Color(0xFF2D3E55),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          (item['done'] as bool) ? Icons.check : Icons.radio_button_unchecked,
                          size: 16,
                          color: (item['done'] as bool) ? item['color'] as Color : const Color(0xFF64748B),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 52,
                          color: (item['done'] as bool)
                              ? (item['color'] as Color).withOpacity(0.4)
                              : const Color(0xFF2D3E55),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item['label'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: (item['done'] as bool) ? Colors.white : const Color(0xFF64748B),
                                ),
                              ),
                              if ((item['time'] as String).isNotEmpty)
                                Text(
                                  item['time'],
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['desc'],
                            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2940),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2D3E55)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF3B82F6), size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Kamu akan menerima notifikasi setiap ada perubahan status laporan.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}