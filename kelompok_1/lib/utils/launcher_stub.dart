import 'package:url_launcher/url_launcher.dart';

void launchUrlCompat(String url) {
  final Uri uri = Uri.parse(url);
  launchUrl(uri, mode: LaunchMode.externalApplication).catchError((e) {
    // ignore: avoid_print
    print('Gagal memutar/membuka URL: $e');
    return false;
  });
}
