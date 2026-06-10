import 'package:flutter/material.dart';
import '../../controllers/notifikasi_controller.dart';
import '../../models/notifikasi_model.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});
  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {

  // ── HELPER: icon & warna berdasarkan tipe ─────────────
  static IconData _icon(String tipe) {
    switch (tipe) {
      case 'verifikasi': return Icons.verified_rounded;
      case 'selesai'   : return Icons.check_circle_rounded;
      case 'masuk'     : return Icons.inbox_rounded;
      default          : return Icons.update_rounded;
    }
  }

  static Color _iconColor(String tipe) {
    switch (tipe) {
      case 'verifikasi': return const Color(0xFF10B981);
      case 'selesai'   : return const Color(0xFF10B981);
      case 'masuk'     : return const Color(0xFF3B82F6);
      default          : return const Color(0xFFF59E0B);
    }
  }

  static Color _bgColor(String tipe) {
    switch (tipe) {
      case 'verifikasi': return const Color(0xFF064E3B);
      case 'selesai'   : return const Color(0xFF064E3B);
      case 'masuk'     : return const Color(0xFF1E3A8A);
      default          : return const Color(0xFF78350F);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111D2C), elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: StreamBuilder<List<NotifikasiModel>>(
          stream: NotifikasiController.streamNotifikasi(),
          builder: (context, snapshot) {
            final count = (snapshot.data ?? [])
                .where((n) => n.dibaca == false)
                .length;
            final String title = count > 0 ? 'Notifikasi ($count)' : 'Notifikasi';
            return Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await NotifikasiController.tandaiBacaSemua();
              if (mounted) setState(() {});
            },
            child: const Text('Tandai Sudah Dibaca', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12)),
          ),
        ],
      ),

      // ── Realtime stream dari Supabase ──────────────────
      body: StreamBuilder<List<NotifikasiModel>>(
        stream: NotifikasiController.streamNotifikasi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white54)));
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
                await Future.delayed(const Duration(milliseconds: 800));
              },
              color: const Color(0xFF3B82F6),
              backgroundColor: const Color(0xFF111D2C),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top,
                  child: _buildEmpty(),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
              await Future.delayed(const Duration(milliseconds: 800));
            },
            color: const Color(0xFF3B82F6),
            backgroundColor: const Color(0xFF111D2C),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _notifCard(list[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _notifCard(NotifikasiModel notif) {
    final bool dibaca = notif.dibaca;
    final String tipe = notif.tipe;
    final String pesan = notif.pesan;
    final String judul = notif.judul;
    final bool isDiprosesNotif = pesan.toLowerCase().contains('diproses') || judul.toLowerCase().contains('diproses');

    return GestureDetector(
      onTap: () async {
        if (!dibaca) {
          await NotifikasiController.tandaiBaca(notif.id);
          if (mounted) setState(() {});
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: dibaca ? const Color(0xFF1A2940) : const Color(0xFF1E2D45),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: dibaca ? const Color(0xFF2D3E55) : const Color(0xFF3B82F6).withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: _bgColor(tipe).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon(tipe), color: _iconColor(tipe), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(notif.judul,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                            color: dibaca ? const Color(0xFF94A3B8) : Colors.white))),
                    if (!dibaca)
                      Container(width: 8, height: 8,
                          decoration: const BoxDecoration(color: Color(0xFF3B82F6), shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(notif.pesan,
                    style: TextStyle(fontSize: 12, height: 1.5,
                        color: dibaca ? const Color(0xFF64748B) : const Color(0xFF94A3B8))),
                if (isDiprosesNotif) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.campaign_outlined, color: Color(0xFF3B82F6), size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Anda dapat melakukan mediasi dengan menemui Tim Satgas Anti Perundungan dan melakukan konseling di Poliklinik Polinema pada Hari Selasa & Jumat pukul 09.00 - 13.00 WIB',
                            style: TextStyle(fontSize: 11, color: Colors.white, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(_formatWaktu(notif.createdAt),
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            )),
          ],
        ),
      ),
    );
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

  Widget _buildEmpty() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 72, height: 72,
          decoration: BoxDecoration(color: const Color(0xFF1A2940), borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.notifications_off_outlined, color: Color(0xFF64748B), size: 32)),
      const SizedBox(height: 16),
      const Text('Belum ada notifikasi',
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      const Text('Notifikasi akan muncul di sini',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
    ]));
  }
}