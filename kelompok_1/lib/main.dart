import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'views/auth/splash.dart';
import 'views/auth/login.dart';
import 'views/mahasiswa/dashboard.dart';
import 'views/mahasiswa/form_laporan.dart';
import 'views/mahasiswa/status.dart';
import 'views/shared/notifikasi.dart';
import 'views/shared/profil.dart';
import 'views/admin/dashboard_admin.dart';
import 'views/kaprodi/dashboard_kaprodi.dart';
import 'views/shared/daftar_laporan_page.dart';
import 'views/shared/detail_laporan.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── INISIALISASI SUPABASE ──────────────────────────────
  await Supabase.initialize(
    url  : 'https://onvuogdpmqezxexoosgy.supabase.co',       
    anonKey: 'sb_publishable_0jNRRe78EgvLraOen4U2ag_rP7ugz7m',  
  );

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
        '/detail-laporan': (context) => const DetailLaporanPage(),
      },
    );
  }
}