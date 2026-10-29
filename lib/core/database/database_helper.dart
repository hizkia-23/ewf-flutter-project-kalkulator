import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Kelas Singleton untuk mengelola koneksi SQLite secara efisien
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static Future<Database>? _initFuture;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _initFuture ??= _initDB('pivot_kalkulator.db');
    _database = await _initFuture!;
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // Mengeksekusi DDL (Data Definition Language) untuk membuat tabel
  Future _createDB(Database db, int version) async {
    // 1. Tabel Riwayat Pivot Point (Data Personal)
    await db.execute('''
      CREATE TABLE pivot_history (
        id TEXT PRIMARY KEY,
        timestamp TEXT NOT NULL,
        high REAL NOT NULL,
        low REAL NOT NULL,
        close REAL NOT NULL,
        openingPrice REAL,
        pp REAL NOT NULL,
        range REAL NOT NULL,
        r1 REAL NOT NULL,
        r2 REAL NOT NULL,
        r3 REAL NOT NULL,
        r4 REAL NOT NULL,
        s1 REAL NOT NULL,
        s2 REAL NOT NULL,
        s3 REAL NOT NULL,
        s4 REAL NOT NULL,
        recommendation TEXT NOT NULL
      )
    ''');

    // 2. Tabel Market Data Newsmaker (Cache Offline untuk Emas Digital, Hang Seng, Nikkei)
    await db.execute('''
      CREATE TABLE market_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT NOT NULL,
        date TEXT NOT NULL,
        open REAL NOT NULL,
        high REAL NOT NULL,
        low REAL NOT NULL,
        close REAL NOT NULL
      )
    ''');

    // 3. Tabel Riwayat Emas Fisik Kalkulator
    await db.execute('''
      CREATE TABLE gold_history (
        id TEXT PRIMARY KEY,
        timestamp TEXT NOT NULL,
        hb REAL NOT NULL,
        hj REAL NOT NULL,
        kurs REAL NOT NULL,
        toz REAL NOT NULL,
        modalAwal REAL NOT NULL,
        hhb REAL NOT NULL,
        hhj REAL NOT NULL,
        selisih REAL NOT NULL,
        gramEmas REAL NOT NULL,
        keuntunganBersih REAL NOT NULL
      )
    ''');

    // 4. Tabel Pengaturan Aplikasi (Tema Gelap/Terang, dll)
    await db.execute('''
      CREATE TABLE app_settings (
        setting_key TEXT PRIMARY KEY,
        setting_value TEXT NOT NULL
      )
    ''');

    // Menyuntikkan nilai default Tema Terang saat database pertama kali dibuat
    await db.insert('app_settings', {
      'setting_key': 'theme_mode',
      'setting_value': 'light'
    });

    // 5. Tabel Riwayat Nest
    await db.execute('''
      CREATE TABLE nest_history (
        id TEXT PRIMARY KEY,
        timestamp TEXT NOT NULL,
        close REAL NOT NULL,
        openingPrice REAL NOT NULL,
        recommendation TEXT NOT NULL
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 1. Buat tabel gold_history jika belum ada
      await db.execute('''
        CREATE TABLE IF NOT EXISTS gold_history (
          id TEXT PRIMARY KEY,
          timestamp TEXT NOT NULL,
          hb REAL NOT NULL,
          hj REAL NOT NULL,
          kurs REAL NOT NULL,
          toz REAL NOT NULL,
          modalAwal REAL NOT NULL,
          hhb REAL NOT NULL,
          hhj REAL NOT NULL,
          selisih REAL NOT NULL,
          gramEmas REAL NOT NULL,
          keuntunganBersih REAL NOT NULL
        )
      ''');

      // 2. Re-create pivot_history agar kolom openingPrice nullable
      await db.execute('DROP TABLE IF EXISTS pivot_history');
      await db.execute('''
        CREATE TABLE pivot_history (
          id TEXT PRIMARY KEY,
          timestamp TEXT NOT NULL,
          high REAL NOT NULL,
          low REAL NOT NULL,
          close REAL NOT NULL,
          openingPrice REAL,
          pp REAL NOT NULL,
          range REAL NOT NULL,
          r1 REAL NOT NULL,
          r2 REAL NOT NULL,
          r3 REAL NOT NULL,
          r4 REAL NOT NULL,
          s1 REAL NOT NULL,
          s2 REAL NOT NULL,
          s3 REAL NOT NULL,
          s4 REAL NOT NULL,
          recommendation TEXT NOT NULL
        )
      ''');

      // 3. Buat tabel nest_history jika belum ada
      await db.execute('''
        CREATE TABLE IF NOT EXISTS nest_history (
          id TEXT PRIMARY KEY,
          timestamp TEXT NOT NULL,
          close REAL NOT NULL,
          openingPrice REAL NOT NULL,
          recommendation TEXT NOT NULL
        )
      ''');

      // 4. Buat tabel market_data jika belum ada
      await db.execute('''
        CREATE TABLE IF NOT EXISTS market_data (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          symbol TEXT NOT NULL,
          date TEXT NOT NULL,
          open REAL NOT NULL,
          high REAL NOT NULL,
          low REAL NOT NULL,
          close REAL NOT NULL
        )
      ''');
    }

    // PERBAIKAN: Jaring pengaman untuk perangkat yang sudah di versi 2
    // tapi tabel pivot_history / nest_history belum ada atau rusak.
    // Menggunakan CREATE TABLE IF NOT EXISTS agar aman dan tidak menghapus data.
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS pivot_history (
          id TEXT PRIMARY KEY,
          timestamp TEXT NOT NULL,
          high REAL NOT NULL,
          low REAL NOT NULL,
          close REAL NOT NULL,
          openingPrice REAL,
          pp REAL NOT NULL,
          range REAL NOT NULL,
          r1 REAL NOT NULL,
          r2 REAL NOT NULL,
          r3 REAL NOT NULL,
          r4 REAL NOT NULL,
          s1 REAL NOT NULL,
          s2 REAL NOT NULL,
          s3 REAL NOT NULL,
          s4 REAL NOT NULL,
          recommendation TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS nest_history (
          id TEXT PRIMARY KEY,
          timestamp TEXT NOT NULL,
          close REAL NOT NULL,
          openingPrice REAL NOT NULL,
          recommendation TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS gold_history (
          id TEXT PRIMARY KEY,
          timestamp TEXT NOT NULL,
          hb REAL NOT NULL,
          hj REAL NOT NULL,
          kurs REAL NOT NULL,
          toz REAL NOT NULL,
          modalAwal REAL NOT NULL,
          hhb REAL NOT NULL,
          hhj REAL NOT NULL,
          selisih REAL NOT NULL,
          gramEmas REAL NOT NULL,
          keuntunganBersih REAL NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS market_data (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          symbol TEXT NOT NULL,
          date TEXT NOT NULL,
          open REAL NOT NULL,
          high REAL NOT NULL,
          low REAL NOT NULL,
          close REAL NOT NULL
        )
      ''');
    }
  }

  /// Menghapus satu baris data dari tabel berdasarkan primary key [id]
  Future<int> deleteById(String table, dynamic id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id.toString()]);
  }

  /// Menghapus data dari tabel dengan klausa WHERE kustom
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
