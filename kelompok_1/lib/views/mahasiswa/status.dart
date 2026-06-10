import 'package:flutter/material.dart';
import '../../controllers/laporan_controller.dart';
import '../../models/laporan_model.dart';

class StatusLaporanPage extends StatelessWidget {
  const StatusLaporanPage({super.key});

  void _goBack(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    
    // Mendapatkan ID laporan secara aman
    final dynamic dbIdVal = args?['db_id'] ?? args?['id'];
    final int? id = dbIdVal is int
        ? dbIdVal
        : (dbIdVal != null ? int.tryParse(dbIdVal.toString()) : null);

    final String fallbackId = args?['id']?.toString() ?? 'RPT-2026-001';
    final String fallbackJenis = args?['jenis'] ?? 'Verbal';
    final String fallbackStatus = args?['status'] ?? 'Menunggu Verifikasi';
    final Color fallbackStatusColor = args?['statusColor'] ?? const Color(0xFF3B82F6);
    final String fallbackDate = args?['date'] ?? '-';

    if (id == null) {
      // Fallback jika tidak ada ID database untuk fetching
      return _buildScaffold(
        context: context,
        idStr: fallbackId,
        jenis: fallbackJenis,
        status: fallbackStatus,
        statusColor: fallbackStatusColor,
        dateStr: fallbackDate,
        timeline: _buildTimelineList(fallbackStatus, fallbackDate, null, null, null, null, null),
      );
    }

    return FutureBuilder<LaporanModel>(
      future: LaporanController.getDetailLaporan(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color(0xFF0D1B2A),
            appBar: AppBar(
              backgroundColor: const Color(0xFF111D2C),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () => _goBack(context),
              ),
              title: const Text('Status Laporan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            body: const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6))),
          );
        }

        if (snapshot.hasError) {
          return _buildScaffold(
            context: context,
            idStr: fallbackId,
            jenis: fallbackJenis,
            status: fallbackStatus,
            statusColor: fallbackStatusColor,
            dateStr: fallbackDate,
            timeline: _buildTimelineList(fallbackStatus, fallbackDate, null, null, null, null, null),
          );
        }

        final data = snapshot.data;
        final String status = data?.status ?? fallbackStatus;
        final Color statusColor = _statusColor(status);
        final String date = data != null ? _formatTgl(data.tanggalKejadian) : fallbackDate;
        final String idStr = data?.kode ?? fallbackId;
        final String jenis = data?.jenis ?? fallbackJenis;
        final String? hasilMediasi = data?.hasilMediasi;
        final String? tindakan = data?.tindakan;
        final String? catatanKaprodi = data?.catatanKaprodi;

        return _buildScaffold(
          context: context,
          idStr: idStr,
          jenis: jenis,
          status: status,
          statusColor: statusColor,
          dateStr: date,
          hasilMediasi: hasilMediasi,
          tindakan: tindakan,
          catatanKaprodi: catatanKaprodi,
          timeline: _buildTimelineList(
            status,
            _formatWaktu(data?.createdAt),
            _formatWaktu(data?.diverifikasiAt),
            _formatWaktu(data?.ditindakAt),
            tindakan,
            catatanKaprodi,
            hasilMediasi,
          ),
        );
      },
    );
  }

  Widget _buildScaffold({
    required BuildContext context,
    required String idStr,
    required String jenis,
    required String status,
    required Color statusColor,
    required String dateStr,
    required List<Map<String, dynamic>> timeline,
    String? hasilMediasi,
    String? tindakan,
    String? catatanKaprodi,
  }) {
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
                        idStr,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF93C5FD), fontWeight: FontWeight.w500),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withValues(alpha: 0.4)),
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
                    'Dilaporkan $dateStr',
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
                              ? (item['color'] as Color).withValues(alpha: 0.2)
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
                              ? (item['color'] as Color).withValues(alpha: 0.4)
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
            if (status == 'Diproses' && (hasilMediasi == null || hasilMediasi.isEmpty)) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.25)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.campaign_outlined, color: Color(0xFF3B82F6), size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Anda dapat melakukan konseling atau mediasi dengan menemui tim satgas anti perundungan di gedung AA pada hari senin – jumat pukul 7.00 – 16.00 WIB',
                        style: TextStyle(fontSize: 12, color: Colors.white, height: 1.5, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (hasilMediasi != null && hasilMediasi.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.handshake_outlined, color: Color(0xFF3B82F6), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Hasil Penanganan Satgas',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      hasilMediasi,
                      style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],

            if (tindakan != null && tindakan.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.gavel_rounded, color: Color(0xFF10B981), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Tindak Lanjut Kaprodi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tindakan:',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tindakan,
                      style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.4),
                    ),
                    if (catatanKaprodi != null && catatanKaprodi.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Catatan Tambahan:',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        catatanKaprodi,
                        style: const TextStyle(fontSize: 13, color: Color(0xFFCBD5E1), height: 1.4),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _buildTimelineList(
    String status,
    String tglKirim,
    String? tglVerif,
    String? tglTindak,
    String? tindakan,
    String? catatanKaprodi,
    String? hasilMediasi,
  ) {
    final bool isVerif = status != 'Menunggu Verifikasi';
    final bool isMediasiDone = hasilMediasi != null && hasilMediasi.isNotEmpty;
    final bool isTindak = ['Selesai', 'Tidak Valid'].contains(status);

    String verifDesc = 'Valid · Data dan bukti diperiksa admin';
    if (!isVerif) {
      verifDesc = 'Menunggu data diperiksa dan diverifikasi oleh admin';
    }

    String mediasiDesc = 'Menunggu konseling/mediasi fisik bersama Tim Satgas';
    if (isMediasiDone) {
      mediasiDesc = 'Selesai: $hasilMediasi';
    }

    String tindakDesc = 'Laporan sedang ditindaklanjuti oleh Kaprodi';
    if (isTindak) {
      if (status == 'Selesai') {
        tindakDesc = 'Selesai ditindaklanjuti.\nTindakan: ${tindakan ?? '-'}';
      } else {
        tindakDesc = 'Laporan dinyatakan tidak valid / ditolak.\nCatatan: ${catatanKaprodi ?? '-'}';
      }
    }

    return [
      {
        'label': 'Laporan Dikirim',
        'time': tglKirim,
        'desc': 'Laporan berhasil dikirimkan ke sistem',
        'done': true,
        'color': const Color(0xFF10B981),
      },
      {
        'label': 'Verifikasi Admin',
        'time': isVerif ? (tglVerif ?? '') : '',
        'desc': verifDesc,
        'done': isVerif,
        'color': const Color(0xFF10B981),
      },
      {
        'label': 'Mediasi & Penanganan Satgas',
        'time': '',
        'desc': mediasiDesc,
        'done': isMediasiDone,
        'color': const Color(0xFF10B981),
      },
      {
        'label': 'Tindak Lanjut Kaprodi',
        'time': isTindak ? (tglTindak ?? '') : '',
        'desc': tindakDesc,
        'done': isTindak,
        'color': status == 'Tidak Valid' ? const Color(0xFFEF4444) : const Color(0xFF10B981),
      },
    ];
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

  String _formatTgl(dynamic ts) {
    if (ts == null) return '-';
    try {
      final dt = ts is DateTime ? ts.toLocal() : DateTime.parse(ts.toString()).toLocal();
      return '${dt.day} ${['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][dt.month - 1]}, ${dt.year}';
    } catch (_) {
      return ts.toString();
    }
  }

  String _formatWaktu(dynamic ts) {
    if (ts == null) return '';
    try {
      final dt = ts is DateTime ? ts.toLocal() : DateTime.parse(ts.toString()).toLocal();
      return '${dt.day} ${_bulan(dt.month)}, ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    } catch (_) {
      return ts.toString();
    }
  }

  String _bulan(int m) => ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'][m-1];
}