import 'package:flutter/foundation.dart';
import '../../../../core/services/history_service.dart';

/// ViewModel untuk mengelola state riwayat perhitungan (Gold, Pivot, Nest)
class HistoryViewModel extends ChangeNotifier {
  final HistoryService _historyService;

  List<GoldHistoryEntry> _goldHistoryList = [];
  List<PivotHistoryEntry> _pivotHistoryList = [];
  List<NestHistoryEntry> _nestHistoryList = [];

  List<GoldHistoryEntry> get goldHistoryList => _goldHistoryList;
  List<PivotHistoryEntry> get pivotHistoryList => _pivotHistoryList;
  List<NestHistoryEntry> get nestHistoryList => _nestHistoryList;

  HistoryViewModel({HistoryService? historyService})
      : _historyService = historyService ?? HistoryService.instance {
    loadData();
  }

  /// Memuat data dari HistoryService ke state lokal.
  /// PERBAIKAN: Selalu panggil loadHistory(forceReload: true) untuk memastikan
  /// data dari database SQLite selalu sinkron, terutama setelah insert baru
  /// dari halaman Pivot/Nest.
  void loadData() {
    // Langsung ambil data yang sudah ada di memori (untuk tampilan instan)
    _goldHistoryList = List.from(_historyService.goldHistory);
    _pivotHistoryList = List.from(_historyService.pivotHistory);
    _nestHistoryList = List.from(_historyService.nestHistory);
    notifyListeners();

    // Kemudian reload dari database untuk memastikan data terbaru
    _historyService.loadHistory(forceReload: true).then((_) {
      _goldHistoryList = List.from(_historyService.goldHistory);
      _pivotHistoryList = List.from(_historyService.pivotHistory);
      _nestHistoryList = List.from(_historyService.nestHistory);
      notifyListeners();
    });
  }

  /// Menghapus satu item riwayat berdasarkan [id] dan [type] ('gold', 'pivot', 'nest').
  /// Menghapus dari database melalui HistoryService, lalu menghapus dari list lokal,
  /// dan memanggil notifyListeners() agar UI langsung ter-update tanpa reload ulang database.
  Future<void> deleteItem(dynamic id, String type) async {
    final strId = id.toString();
    final lowerType = type.trim().toLowerCase();

    if (lowerType == 'gold') {
      await _historyService.deleteGoldItem(strId);
      _goldHistoryList.removeWhere((item) => item.id == strId || item.id == id.toString());
    } else if (lowerType == 'pivot') {
      await _historyService.deletePivotItem(strId);
      _pivotHistoryList.removeWhere((item) => item.id == strId || item.id == id.toString());
    } else if (lowerType == 'nest') {
      await _historyService.deleteNestItem(strId);
      _nestHistoryList.removeWhere((item) => item.id == strId || item.id == id.toString());
    }
    notifyListeners();
  }

  /// Helper spesifik untuk hapus riwayat Gold
  Future<void> deleteGoldItem(dynamic id) => deleteItem(id, 'gold');

  /// Helper spesifik untuk hapus riwayat Pivot
  Future<void> deletePivotItem(dynamic id) => deleteItem(id, 'pivot');

  /// Helper spesifik untuk hapus riwayat Nest
  Future<void> deleteNestItem(dynamic id) => deleteItem(id, 'nest');

  /// Menghapus semua riwayat sekaligus
  Future<void> clearAll() async {
    await _historyService.clearAll();
    _goldHistoryList.clear();
    _pivotHistoryList.clear();
    _nestHistoryList.clear();
    notifyListeners();
  }
}
