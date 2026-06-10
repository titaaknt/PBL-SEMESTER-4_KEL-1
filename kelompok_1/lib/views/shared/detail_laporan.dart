import 'package:flutter/material.dart';
import '../../controllers/laporan_controller.dart';
import '../../controllers/supabase_client.dart';
import '../../models/bukti_foto_model.dart';
import '../../models/laporan_model.dart';
import '../../utils/launcher.dart';
import 'video_player_widget.dart';

class DetailLaporanPage extends StatelessWidget {
  const DetailLaporanPage({super.key});

  String _formatTgl(dynamic ts) {
    if (ts == null) return '-';
    try {
      final dt = ts is DateTime ? ts.toLocal() : DateTime.parse(ts.toString()).toLocal();
      return '${dt.day} ${['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][dt.month - 1]}, ${dt.year}';
    } catch (_) {
      return ts.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final dynamic dbIdVal = args['db_id'] ?? args['id'];
    final int? id = dbIdVal is int ? dbIdVal : int.tryParse(dbIdVal.toString());
    final currentUser = supabase.auth.currentUser;
    final String userRole = currentUser?.userMetadata?['role'] ?? '';

    if (id != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF111D2C),
          elevation: 0,
          title: const Text(
            'Detail Laporan',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: FutureBuilder<LaporanModel>(
          future: LaporanController.getDetailLaporan(id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
              );
            }

            final cleanArgs = Map<String, dynamic>.from(args);
            if (cleanArgs['db_id'] != null) {
              cleanArgs['id'] = cleanArgs['db_id'];
            } else if (cleanArgs['id'] is String && (cleanArgs['id'] as String).startsWith('RPT-')) {
              final parts = (cleanArgs['id'] as String).split('-');
              if (parts.length > 1) {
                cleanArgs['id'] = int.tryParse(parts.last) ?? 0;
              }
            }

            final realLaporan = snapshot.data ?? LaporanModel.fromMap(cleanArgs);
            return _buildContent(context, realLaporan, userRole);
          },
        ),
      );
    }

    final cleanArgs = Map<String, dynamic>.from(args);
    if (cleanArgs['db_id'] != null) {
      cleanArgs['id'] = cleanArgs['db_id'];
    } else if (cleanArgs['id'] is String && (cleanArgs['id'] as String).startsWith('RPT-')) {
      final parts = (cleanArgs['id'] as String).split('-');
      if (parts.length > 1) {
        cleanArgs['id'] = int.tryParse(parts.last) ?? 0;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111D2C),
        elevation: 0,
        title: const Text(
          'Detail Laporan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildContent(context, LaporanModel.fromMap(cleanArgs), userRole),
    );
  }

  Widget _buildContent(BuildContext context, LaporanModel laporan, String userRole) {
    // Resolve status color helper in detail view
    final Color scColor = _resolveStatusColor(laporan.status, null);

    // Retrieve name and NIM from nested user profiles or fallback keys
    String nama = laporan.namaPelapor.isNotEmpty ? laporan.namaPelapor : (laporan.pelapor?.nama ?? '-');
    String nim = laporan.nimPelapor.isNotEmpty ? laporan.nimPelapor : (laporan.pelapor?.nim ?? '-');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // STATUS
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: scColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: scColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  laporan.status,
                  style: TextStyle(
                    color: scColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          if (laporan.hasilMediasi != null && laporan.hasilMediasi!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.handshake_outlined, color: Color(0xFF3B82F6), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Hasil Penanganan Satgas (Mediasi)',
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
                    laporan.hasilMediasi!,
                    style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.4),
                  ),
                ],
              ),
            ),
          ],

          if (laporan.tindakan != null && laporan.tindakan!.isNotEmpty) ...[
            const SizedBox(height: 20),
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
                    laporan.tindakan!,
                    style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.4),
                  ),
                  if (laporan.catatanKaprodi != null &&
                      laporan.catatanKaprodi!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Catatan Tambahan:',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      laporan.catatanKaprodi!,
                      style: const TextStyle(fontSize: 13, color: Color(0xFFCBD5E1), height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // NAMA
          _buildItem(
            'Nama Pelapor',
            nama,
            Icons.person_outline,
          ),

          // NIM
          _buildItem(
            'NIM',
            nim,
            Icons.badge_outlined,
          ),

          // JENIS
          _buildItem(
            'Jenis Perundungan',
            laporan.jenis,
            Icons.warning_amber_rounded,
          ),

          // LOKASI
          _buildItem(
            'Lokasi Kejadian',
            laporan.lokasi,
            Icons.location_on_outlined,
          ),

          // TANGGAL
          _buildItem(
            'Tanggal Kejadian',
            _formatTgl(laporan.tanggalKejadian),
            Icons.calendar_month_outlined,
          ),

          // PELAKU
          _buildItem(
            'Identitas Pelaku',
            laporan.pelaku ?? '-',
            Icons.person_off_outlined,
          ),

          const SizedBox(height: 20),

          // KRONOLOGI
          const Text(
            'Kronologi Kejadian',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2940),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF2D3E55),
              ),
            ),
            child: Text(
              laporan.kronologi,
              style: const TextStyle(
                color: Color(0xFFCBD5E1),
                height: 1.5,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // BUKTI
          const Text(
            'Bukti',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          _buildBuktiWidget(laporan),

          if (userRole == 'Admin' &&
              laporan.status == 'Diproses' &&
              (laporan.hasilMediasi == null || laporan.hasilMediasi!.isEmpty)) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _showFormMediasi(context, laporan.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.edit_note_rounded, size: 20),
                label: const Text(
                  'Input Hasil Penanganan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildBuktiWidget(LaporanModel laporan) {
    final List<BuktiFotoModel>? buktiList = laporan.buktiFoto;

    if (buktiList != null && buktiList.isNotEmpty) {
      return Column(
        children: buktiList.map<Widget>((bukti) {
          final String url = bukti.url;
          final bool isVideo = url.toLowerCase().contains('.mp4') ||
              url.toLowerCase().contains('.mov') ||
              url.toLowerCase().contains('.avi') ||
              url.toLowerCase().contains('.mkv') ||
              url.toLowerCase().contains('.3gp') ||
              url.toLowerCase().contains('/video_');

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: isVideo
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InlineVideoPlayer(url: url),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => launchUrlCompat(url),
                          icon: const Icon(Icons.open_in_browser_rounded, size: 14, color: Color(0xFF64748B)),
                          label: const Text(
                            'Buka di Browser',
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      url,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: double.infinity,
                        height: 220,
                        color: const Color(0xFF1A2940),
                        child: const Icon(Icons.broken_image_outlined, color: Color(0xFF64748B), size: 42),
                      ),
                    ),
                  ),
          );
        }).toList(),
      );
    }

    return _buildNoImagePlaceholder();
  }

  Widget _buildNoImagePlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2940),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF2D3E55),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Color(0xFF64748B),
            size: 42,
          ),
          SizedBox(height: 10),
          Text(
            'Tidak ada bukti gambar',
            style: TextStyle(
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Color _resolveStatusColor(String s, dynamic passedColor) {
    if (passedColor is Color) return passedColor;
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

  Widget _buildItem(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2940),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF2D3E55),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF3B82F6),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFormMediasi(BuildContext context, int id) {
    final hasilCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A2940),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D3E55),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.handshake_outlined, color: Color(0xFF3B82F6), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Input Hasil Penanganan Satgas',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Hasil Mediasi & Penanganan *',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: hasilCtrl,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Tuliskan hasil mediasi atau tindakan penanganan fisik...',
                  hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFF0D1B2A),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2D3E55)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2D3E55)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        side: const BorderSide(color: Color(0xFF2D3E55)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final text = hasilCtrl.text.trim();
                        if (text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Hasil penanganan tidak boleh kosong'),
                              backgroundColor: Color(0xFFEF4444),
                            ),
                          );
                          return;
                        }
                        Navigator.pop(ctx);
                        try {
                          await LaporanController.inputHasilMediasi(id, text);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Hasil penanganan berhasil disimpan'),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal menyimpan: $e'),
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: const Text('Simpan Hasil', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}