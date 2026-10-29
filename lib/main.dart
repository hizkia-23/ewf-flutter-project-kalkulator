import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'app.dart';
import 'core/database/database_helper.dart';
import 'core/services/history_service.dart';

void main() async {
  // 1. Memastikan binding Flutter terinisialisasi sebelum interaksi platform channel / database
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Database SQLite & HistoryService dengan proteksi try-catch
  try {
    // Membuka koneksi database SQLite terlebih dahulu
    await DatabaseHelper.instance.database;
    // Memuat riwayat data ke dalam cache memori
    await HistoryService.instance.loadHistory();
  } catch (e, stack) {
    if (kDebugMode) {
      print('Gagal melakukan inisialisasi database di main(): $e');
      print(stack);
    }
  }

  // 3. Menjalankan aplikasi setelah database siap
  runApp(const App());
}