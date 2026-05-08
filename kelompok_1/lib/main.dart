import 'package:flutter/material.dart';
import 'splash.dart';
import 'login.dart';
import 'dashboard.dart';
import 'form-laporan.dart';
import 'status.dart';
import 'notifikasi.dart';
import 'profil.dart';
import 'dashboard_admin.dart';
import 'dashboard_kaprodi.dart';
import 'daftar_laporan_page.dart';
import 'detail_laporan.dart';

void main() {
  runApp(const SafeCampusApp());
}

class SafeCampusApp extends StatelessWidget {
  const SafeCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeCampus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/form-laporan': (context) => const FormLaporanPage(),
        '/status-laporan': (context) => const StatusLaporanPage(),
        '/notifikasi': (context) => const NotifikasiPage(),
        '/profil': (context) => const ProfilPage(),
        '/dashboard-admin': (context) => const DashboardAdminPage(),
        '/dashboard-kaprodi': (context) => const DashboardKaprodiPage(),
        '/daftar-laporan': (context) => const DaftarLaporanPage(),
        '/detail-laporan': (context) => DetailLaporanPage(),
      },
    );
  }
}
