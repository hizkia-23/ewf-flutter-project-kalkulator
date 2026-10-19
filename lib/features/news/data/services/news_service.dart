import 'dart:io'; // <-- 1. Tambahkan ini di bagian atas
import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';
import '../models/news_model.dart';

class NewsService {
  // KITA GANTI SEMENTARA KE CNBC INDONESIA UNTUK TESTING
  static const String _rssUrl = 'https://www.cnbcindonesia.com/market/rss';

  Future<List<NewsModel>> fetchNews() async {
    try {
      print('Mencoba mengambil berita dari: $_rssUrl');

      final response = await http.get(
        Uri.parse(_rssUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'application/rss+xml, application/xml, text/xml',
        },
      );

      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final rssFeed = RssFeed.parse(response.body);
        final items = rssFeed.items ?? [];
        return items.map((item) => NewsModel.fromRssItem(item)).toList();
      } else {
        throw Exception('Gagal memuat. Status Code: ${response.statusCode}');
      }
    } on SocketException {
      // <-- 2. Tangkapan khusus jika internet mati/tidak ada kuota
      throw Exception('Tidak ada koneksi internet.');
    } catch (e) {
      print('ERROR NYATA: $e');
      // <-- 3. Pesan error disederhanakan agar UI tetap rapi
      throw Exception('Gagal memuat berita hari ini.');
    }
  }
}
