import 'dart:io';
import 'package:flutter/material.dart';

class DetailLaporanPage extends StatelessWidget {
  const DetailLaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final laporan =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

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

      body: SingleChildScrollView(
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
                color: (laporan['statusColor'] as Color).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: laporan['statusColor'],
                    size: 18,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    laporan['status'],
                    style: TextStyle(
                      color: laporan['statusColor'],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // NAMA
            _buildItem(
              'Nama Pelapor',
              laporan['nama'] ?? '-',
              Icons.person_outline,
            ),

            // NIM
            _buildItem(
              'NIM',
              laporan['nim'] ?? '-',
              Icons.badge_outlined,
            ),

            // JENIS
            _buildItem(
              'Jenis Perundungan',
              laporan['jenis'] ?? '-',
              Icons.warning_amber_rounded,
            ),

            // LOKASI
            _buildItem(
              'Lokasi Kejadian',
              laporan['lokasi'] ?? '-',
              Icons.location_on_outlined,
            ),

            // TANGGAL
            _buildItem(
              'Tanggal Kejadian',
              laporan['tanggal'] ?? '-',
              Icons.calendar_month_outlined,
            ),

            // PELAKU
            _buildItem(
              'Identitas Pelaku',
              laporan['pelaku'] ?? '-',
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
                laporan['kronologi'] ?? '-',
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

            if (laporan['imagePath'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(laporan['imagePath']),
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
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
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
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
}