import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/market_data.dart';

class NewsmakerApiService {
  static const String _url = 'https://www.newsmaker.id/api/historical-data';

  Future<List<MarketData>> fetchMarketDataByCategory(
    String categoryName,
  ) async {
    try {
      final uri = Uri.parse(_url).replace(queryParameters: {
        'category': categoryName.trim(),
      });
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> allData =
            jsonResponse['data'] as List<dynamic>? ?? [];

        // Menggunakan batas waktu yang lebih toleran (5 tahun)
        // agar data tetap muncul jika API belum di-update
        final DateTime thresholdDate = DateTime.now().subtract(
          const Duration(days: 365 * 5),
        );

        final filteredList = allData.where((item) {
          // 1. Filter nama kategori jika field category ada
          final String itemCat = item['category']?.toString().trim() ?? '';
          final String targetCat = categoryName.trim();
          if (itemCat.isNotEmpty &&
              itemCat.toLowerCase() != targetCat.toLowerCase()) {
            return false;
          }

          // Abaikan hari libur perbankan / pasar tanpa harga
          if (item['isBankHoliday'] == true) return false;

          // 2. Filter tanggal
          final String itemDateStr = item['tanggal']?.toString() ?? '';
          if (itemDateStr.isEmpty) return false;

          try {
            DateTime itemDate;
            if (itemDateStr.contains('/')) {
              // Menangani jika sewaktu-waktu API mereturn DD/MM/YYYY
              final parts = itemDateStr.split('/');
              itemDate = DateTime.parse('${parts[2]}-${parts[1]}-${parts[0]}');
            } else {
              itemDate = DateTime.parse(itemDateStr);
            }

            return itemDate.isAfter(thresholdDate);
          } catch (e) {
            return false; // Abaikan jika format tanggal server rusak
          }
        }).toList();

        // Ambil maksimal 100 data terbaru (API mengembalikan urutan ASC, reversed menempatkan yang terbaru di awal)
        final limitedList = filteredList.reversed.take(100).toList();

        // Mapping ke model MarketData
        return limitedList
            .map(
              (item) => MarketData(
                date: item['tanggal'].toString(),
                open: double.tryParse(item['open']?.toString() ?? '') ?? 0.0,
                high: double.tryParse(item['high']?.toString() ?? '') ?? 0.0,
                low: double.tryParse(item['low']?.toString() ?? '') ?? 0.0,
                close: double.tryParse(item['close']?.toString() ?? '') ?? 0.0,
              ),
            )
            .toList();
      } else {
        throw Exception('Gagal memuat data: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan atau parsing: $e');
    }
  }
}
