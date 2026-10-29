import '../../../../core/database/database_helper.dart'; // Sesuaikan jika lokasi database_helper Anda berbeda
import '../../domain/entities/market_data.dart'; // Sesuaikan jika path entitas Anda berbeda

abstract class PivotPointLocalDataSource {
  // Kontrak fungsi untuk menyimpan riwayat market data (offline cache)
  Future<void> saveMarketData(String symbol, List<MarketData> data);

  // Kontrak fungsi untuk menarik data saat HP tidak ada internet (dengan pagination)
  Future<List<MarketData>> getMarketDataBySymbol(String symbol, {int limit = 20, int offset = 0});

  // Kontrak fungsi untuk bersih-bersih data lama
  Future<void> clearOldMarketData();
}

class PivotPointLocalDataSourceImpl implements PivotPointLocalDataSource {
  final DatabaseHelper dbHelper;
  PivotPointLocalDataSourceImpl(this.dbHelper);

  @override
  Future<void> saveMarketData(String symbol, List<MarketData> data) async {
    final db = await dbHelper.database;

    // Hapus data lama untuk simbol ini agar tidak duplikat saat ditarik tiap hari
    await db.delete('market_data', where: 'symbol = ?', whereArgs: [symbol]);

    // Gunakan batch agar proses insert ratusan data menjadi sangat cepat (mencegah lag)
    final batch = db.batch();
    for (var item in data) {
      batch.insert('market_data', {
        'symbol': symbol,
        ...item.toMap(),
      });
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<List<MarketData>> getMarketDataBySymbol(String symbol, {int limit = 20, int offset = 0}) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'market_data',
      where: 'symbol = ?',
      whereArgs: [symbol],
      orderBy: 'date DESC', // Pastikan tanggal terbaru ada di atas
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => MarketData.fromMap(map)).toList();
  }

  @override
  Future<void> clearOldMarketData() async {
    final db = await dbHelper.database;

    // Mengambil tanggal hari ini mundur 1 tahun ke belakang
    // Jika kode ini dijalankan hari ini (16 Sep 2026), maka oneYearAgo adalah '2025-09-16'
    final String oneYearAgo = DateTime.now()
        .subtract(const Duration(days: 365))
        .toIso8601String()
        .substring(0, 10);

    // SQLite akan menghapus semua baris yang tanggalnya lebih tua dari 1 tahun yang lalu
    await db.delete('market_data', where: 'date < ?', whereArgs: [oneYearAgo]);
  }
}
