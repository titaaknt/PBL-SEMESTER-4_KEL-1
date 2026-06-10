import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl =
      'https://onvuogdpmqezxexoosgy.supabase.co';

  static const String supabaseAnonKey =
      'sb_publishable_0jNRRe78EgvLraOen4U2ag_rP7ugz7m';
}

// Singleton client
final SupabaseClient supabase = Supabase.instance.client;