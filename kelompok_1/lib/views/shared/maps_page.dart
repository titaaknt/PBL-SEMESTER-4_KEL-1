// ── maps_page.dart ───────────────────────────────────────────
// Menggunakan package: flutter_map + latlong2
// Tile map: OpenStreetMap (tile.openstreetmap.org) — GRATIS, tanpa API key
// ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapsLokasiPage extends StatefulWidget {
  const MapsLokasiPage({super.key});

  @override
  State<MapsLokasiPage> createState() => _MapsLokasiPageState();
}

class _MapsLokasiPageState extends State<MapsLokasiPage> {
  final MapController _mapCtrl = MapController();

  // Koordinat pusat Politeknik Negeri Malang
  static const LatLng _pusatKampus = LatLng(-7.9439, 112.6141);

  String? _selectedNama;

  // ── NAVIGATION METHODS ───────────────────────────────────
  void _goBack() => Navigator.pop(context);

  void _konfirmasi() {
    if (_selectedNama != null) Navigator.pop(context, _selectedNama);
  }
  // ─────────────────────────────────────────────────────────

  // Daftar lokasi di kampus Polinema — koordinat real
  final List<Map<String, dynamic>> _lokasiKampus = [
    {
      'nama': 'Gedung A – Rektorat',
      'lat': -7.9432,
      'lng': 112.6138,
      'icon': Icons.business,
    },
    {
      'nama': 'Gedung B – Teknik Sipil',
      'lat': -7.9437,
      'lng': 112.6133,
      'icon': Icons.engineering,
    },
    {
      'nama': 'Gedung C – Teknik Mesin',
      'lat': -7.9441,
      'lng': 112.6130,
      'icon': Icons.precision_manufacturing,
    },
    {
      'nama': 'Gedung D – Teknologi Informasi',
      'lat': -7.9445,
      'lng': 112.6135,
      'icon': Icons.computer,
    },
    {
      'nama': 'Gedung E – Teknik Elektro',
      'lat': -7.9443,
      'lng': 112.6142,
      'icon': Icons.electrical_services,
    },
    {
      'nama': 'Gedung F – Akuntansi',
      'lat': -7.9448,
      'lng': 112.6148,
      'icon': Icons.account_balance,
    },
    {
      'nama': 'Kantin Kampus',
      'lat': -7.9450,
      'lng': 112.6140,
      'icon': Icons.restaurant,
    },
    {
      'nama': 'Perpustakaan',
      'lat': -7.9435,
      'lng': 112.6145,
      'icon': Icons.local_library,
    },
    {
      'nama': 'Lapangan Olahraga',
      'lat': -7.9455,
      'lng': 112.6135,
      'icon': Icons.sports_soccer,
    },
    {
      'nama': 'Parkiran Utama',
      'lat': -7.9430,
      'lng': 112.6130,
      'icon': Icons.local_parking,
    },
    {
      'nama': 'Masjid Kampus',
      'lat': -7.9428,
      'lng': 112.6143,
      'icon': Icons.mosque,
    },
    {
      'nama': 'Koperasi Mahasiswa',
      'lat': -7.9440,
      'lng': 112.6150,
      'icon': Icons.store,
    },
    {
      'nama': 'Aula / Gedung Serbaguna',
      'lat': -7.9438,
      'lng': 112.6155,
      'icon': Icons.meeting_room,
    },
    {
      'nama': 'Koridor Gedung D',
      'lat': -7.9446,
      'lng': 112.6136,
      'icon': Icons.door_sliding_outlined,
    },
    {
      'nama': 'Toilet Umum Gedung D',
      'lat': -7.9447,
      'lng': 112.6134,
      'icon': Icons.wc_outlined,
    },
  ];

  void _pilihLokasi(Map<String, dynamic> lok) {
    final ll = LatLng(lok['lat'] as double, lok['lng'] as double);
    setState(() {
      _selectedNama = lok['nama'];
    });
    _mapCtrl.move(ll, 18.5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111D2C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: _goBack,
        ),
        title: const Text(
          'Pilih Lokasi Kejadian',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Peta OpenStreetMap ──────────────────────────────
          SizedBox(
            height: 280,
            child: FlutterMap(
              mapController: _mapCtrl,
              options: MapOptions(
                initialCenter: _pusatKampus,
                initialZoom: 17.0,
                minZoom: 15.0,
                maxZoom: 19.0,
              ),
              children: [
                // Tile layer OpenStreetMap — TANPA API KEY
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.safecampus',
                  // maxNativeZoom supaya tidak blur saat zoom in
                  maxNativeZoom: 19,
                ),
                // Marker semua lokasi kampus
                MarkerLayer(
                  markers: _lokasiKampus.map((lok) {
                    final ll = LatLng(
                      lok['lat'] as double,
                      lok['lng'] as double,
                    );
                    final sel = _selectedNama == lok['nama'];
                    return Marker(
                      point: ll,
                      width: sel ? 48 : 38,
                      height: sel ? 48 : 38,
                      child: GestureDetector(
                        onTap: () => _pilihLokasi(lok),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: sel
                                ? const Color(0xFF2563EB)
                                : const Color(0xFF1A2940),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: sel
                                  ? Colors.white
                                  : const Color(0xFF3B82F6),
                              width: sel ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF3B82F6,
                                ).withValues(alpha: sel ? 0.7 : 0.3),
                                blurRadius: sel ? 12 : 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            lok['icon'] as IconData,
                            size: sel ? 22 : 17,
                            color: sel ? Colors.white : const Color(0xFF93C5FD),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // ── Info lokasi terpilih ────────────────────────────
          if (_selectedNama != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.5),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFF3B82F6),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedNama!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 18,
                  ),
                ],
              ),
            ),

          // ── Daftar lokasi ───────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
                  child: Text(
                    'Lokasi di Kampus Polinema',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _lokasiKampus.length,
                    itemBuilder: (_, i) {
                      final lok = _lokasiKampus[i];
                      final sel = _selectedNama == lok['nama'];
                      return GestureDetector(
                        onTap: () => _pilihLokasi(lok),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: sel
                                ? const Color(0xFF1E3A8A)
                                : const Color(0xFF1A2940),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: sel
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFF2D3E55),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: sel
                                      ? const Color(0xFF2563EB).withValues(alpha: 0.3)
                                      : const Color(0xFF0D1B2A),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  lok['icon'] as IconData,
                                  size: 18,
                                  color: sel
                                      ? const Color(0xFF93C5FD)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  lok['nama'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: sel
                                        ? Colors.white
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                              if (sel)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF3B82F6),
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Tombol Pilih ────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF111D2C),
              border: Border(top: BorderSide(color: Color(0xFF2D3E55))),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _selectedNama != null ? _konfirmasi : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF1A2940),
                    disabledForegroundColor: const Color(0xFF64748B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.location_on, size: 18),
                  label: Text(
                    _selectedNama != null
                        ? 'Pilih: $_selectedNama'
                        : 'Pilih lokasi terlebih dahulu',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
