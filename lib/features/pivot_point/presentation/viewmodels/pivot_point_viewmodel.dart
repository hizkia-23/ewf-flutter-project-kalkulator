import 'package:flutter/foundation.dart';

import '../../data/repositories/pivot_point_repository_impl.dart';
import '../../domain/entities/pivot_point_calculation.dart';
import '../../domain/usecases/calculate_pivot_point.dart';
import '../../domain/entities/market_data.dart';
import '../../data/datasources/newsmaker_api_service.dart'; // <-- IMPORT API SERVICE DI SINI
import '../../../../core/database/database_helper.dart';
import '../../data/datasources/pivot_point_local_data_source.dart';

/// ViewModel untuk Pivot Point Calculator.
/// Bertugas memanggil UseCase, menyimpan hasil, dan mengelola loading state.
class PivotPointViewModel extends ChangeNotifier {
  // ── KONSTRUKTOR: Otomatis panggil API saat ViewModel dibuat ──
  PivotPointViewModel({CalculatePivotPoint? calculatePivotPoint})
    : _calculatePivotPoint =
          calculatePivotPoint ??
          CalculatePivotPoint(PivotPointRepositoryImpl()) {
    // Panggil fungsi penarik data dari API Newsmaker
    _initData();
  }

  final CalculatePivotPoint _calculatePivotPoint;

  PivotPointCalculation? result;
  String? errorMessage;
  bool isLoading = false;
  bool isManualMode = true;
  String symbol = 'XAU/USD';
  String lastUpdated = '';

  // 1. Simpan instrumen yang sedang dipilih (Default: Gold)
  String _selectedNewsmakerSymbol = 'Gold';
  String get selectedNewsmakerSymbol => _selectedNewsmakerSymbol;

  // 2. Kosongkan database historis terlebih dahulu (Tidak lagi di-hardcode)
  Map<String, List<MarketData>> _historyDatabase = {
    'Gold': [],
    'Hang Seng': [],
    'Nikkei': [],
  };

  // 3. Ambil list data sesuai instrumen yang dipilih
  List<MarketData> get newsmakerHistories =>
      _historyDatabase[_selectedNewsmakerSymbol] ?? [];

  // Fungsi untuk mendapatkan data terbaru dari instrumen tertentu
  MarketData? getLatestDataFor(String symbol) {
    final list = _historyDatabase[symbol];
    if (list != null && list.isNotEmpty) {
      return list.first;
    }
    return null;
  }

  // Pagination states
  int _currentPage = 0;
  final int _limit = 20;
  bool _hasMoreData = true;
  bool _isFetchingMore = false;

  bool get hasMoreData => _hasMoreData;
  bool get isFetchingMore => _isFetchingMore;
  int get currentPage => _currentPage + 1;

  // ── FUNGSI MENARIK DATA (CACHE-THEN-NETWORK DENGAN PAGINATION) ──
  Future<void> _initData() async {
    try {
      if (kDebugMode) print('--- FASE 1: MEMUAT CACHE SQLITE (INSTAN) ---');

      final apiService = NewsmakerApiService();
      final dbHelper = DatabaseHelper.instance;
      final localDataSource = PivotPointLocalDataSourceImpl(dbHelper);

      // 1. Reset state pagination
      _currentPage = 0;
      _hasMoreData = true;
      _isFetchingMore = false;

      // 2. LANGSUNG TARIK DARI SQLITE (Tanpa nunggu API)
      final goldPage = await localDataSource.getMarketDataBySymbol(
        'Gold',
        limit: _limit,
        offset: 0,
      );
      final hangsengPage = await localDataSource.getMarketDataBySymbol(
        'Hang Seng',
        limit: _limit,
        offset: 0,
      );
      final nikkeiPage = await localDataSource.getMarketDataBySymbol(
        'Nikkei',
        limit: _limit,
        offset: 0,
      );

      _historyDatabase = {
        'Gold': goldPage,
        'Hang Seng': hangsengPage,
        'Nikkei': nikkeiPage,
      };

      // BERITAHU UI SEKARANG! Tabel akan langsung terisi dalam 0.1 detik
      notifyListeners();

      // =================================================================
      // 3. FASE 2: SINKRONISASI API SILENT DI BELAKANG LAYAR
      // =================================================================
      if (kDebugMode) print('--- FASE 2: MENGAMBIL DATA API TERBARU ---');
      try {
        final goldData = await apiService.fetchMarketDataByCategory(
          'LGD Daily',
        );
        final hangsengData = await apiService.fetchMarketDataByCategory(
          'HSI Daily',
        );
        final nikkeiData = await apiService.fetchMarketDataByCategory(
          'SNI Daily',
        );

        if (goldData.isNotEmpty) {
          // Timpa data lama dengan data baru
          await localDataSource.saveMarketData('Gold', goldData);
          await localDataSource.saveMarketData('Hang Seng', hangsengData);
          await localDataSource.saveMarketData('Nikkei', nikkeiData);

          // Bersihkan data di atas 1 tahun
          await localDataSource.clearOldMarketData();

          // TARIK ULANG HALAMAN PERTAMA DARI SQLITE (Karena datanya baru di-update)
          final freshGoldPage = await localDataSource.getMarketDataBySymbol(
            'Gold',
            limit: _limit,
            offset: 0,
          );
          final freshHangsengPage = await localDataSource.getMarketDataBySymbol(
            'Hang Seng',
            limit: _limit,
            offset: 0,
          );
          final freshNikkeiPage = await localDataSource.getMarketDataBySymbol(
            'Nikkei',
            limit: _limit,
            offset: 0,
          );

          _historyDatabase = {
            'Gold': freshGoldPage,
            'Hang Seng': freshHangsengPage,
            'Nikkei': freshNikkeiPage,
          };

          // BERITAHU UI SEKALI LAGI! Angka di tabel otomatis berkedip menjadi harga hari ini.
          notifyListeners();
          if (kDebugMode)
            print(
              '--- SINKRONISASI API SUKSES, UI DIPERBARUI SECARA DIAM-DIAM ---',
            );
        }
      } catch (e) {
        if (kDebugMode)
          print('!!! API Gagal/Offline. Tetap aman pakai data cache !!!');
      }
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print('!!! KESALAHAN FATAL PADA INIT DATA !!!');
        print('Error Detail: $e');
      }
    }
  }

  void setManualMode(bool manual) {
    if (isManualMode == manual) return;
    isManualMode = manual;
    resetResults();
    notifyListeners();
  }

  Future<void> calculateManual({
    required double high,
    required double low,
    required double close,
    required double openingPrice,
  }) async {
    if (!_validateInputs(high, low, close, openingPrice)) {
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      result = _calculatePivotPoint.call(
        high: high,
        low: low,
        close: close,
        openingPrice: openingPrice,
      );
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Error dalam kalkulasi: $e';
      result = null;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> calculateNewsmaker({
    required String symbolInput,
    required double open,
    required double high,
    required double low,
    required double close,
  }) async {
    symbol = symbolInput.trim().isEmpty ? 'XAU/USD' : symbolInput.trim();

    if (!_validateInputs(high, low, close, open)) {
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      result = _calculatePivotPoint.call(
        high: high,
        low: low,
        close: close,
        openingPrice: open,
      );
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Error dalam kalkulasi: $e';
      result = null;
    }

    isLoading = false;
    notifyListeners();
  }

  bool _validateInputs(
    double high,
    double low,
    double close,
    double openingPrice,
  ) {
    if (high <= 0 || low <= 0 || close <= 0 || openingPrice <= 0) {
      errorMessage = 'Semua nilai harus berupa angka positif';
      return false;
    }
    errorMessage = null;
    return true;
  }

  void resetResults() {
    result = null;
    errorMessage = null;
    notifyListeners();
  }

  void reset() {
    symbol = 'XAU/USD';
    lastUpdated = '';
    isLoading = false;
    isManualMode = true;
    resetResults();
  }

  // 4. Fungsi untuk mengganti instrumen dari UI
  Future<void> changeNewsmakerSymbol(String newSymbol) async {
    if (_selectedNewsmakerSymbol != newSymbol) {
      _selectedNewsmakerSymbol = newSymbol;

      // Reset pagination states
      _currentPage = 0;
      _hasMoreData = true;
      _isFetchingMore = false;

      // Load first page for new symbol to reset list length
      final localDataSource = PivotPointLocalDataSourceImpl(
        DatabaseHelper.instance,
      );
      final firstPage = await localDataSource.getMarketDataBySymbol(
        _selectedNewsmakerSymbol,
        limit: _limit,
        offset: 0,
      );
      _historyDatabase[_selectedNewsmakerSymbol] = firstPage;

      notifyListeners();
    }
  }

  // 5. Fungsi Pagination
  Future<void> nextPage() async {
    if (_isFetchingMore || !_hasMoreData) return;

    _isFetchingMore = true;
    notifyListeners();

    try {
      final localDataSource = PivotPointLocalDataSourceImpl(
        DatabaseHelper.instance,
      );
      _currentPage++;
      final offset = _currentPage * _limit;

      final newData = await localDataSource.getMarketDataBySymbol(
        _selectedNewsmakerSymbol,
        limit: _limit,
        offset: offset,
      );

      if (newData.isEmpty) {
        _hasMoreData = false;
        _currentPage--; // rollback
      } else {
        _historyDatabase[_selectedNewsmakerSymbol] = newData;
        if (newData.length < _limit) {
          _hasMoreData = false; // Reached end of local data
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error loading next page: $e');
      _currentPage--; // rollback on error
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> previousPage() async {
    if (_isFetchingMore || _currentPage == 0) return;

    _isFetchingMore = true;
    notifyListeners();

    try {
      final localDataSource = PivotPointLocalDataSourceImpl(
        DatabaseHelper.instance,
      );
      _currentPage--;
      final offset = _currentPage * _limit;

      final newData = await localDataSource.getMarketDataBySymbol(
        _selectedNewsmakerSymbol,
        limit: _limit,
        offset: offset,
      );

      _historyDatabase[_selectedNewsmakerSymbol] = newData;
      _hasMoreData =
          true; // Jika kembali ke belakang, pasti ada halaman selanjutnya
    } catch (e) {
      if (kDebugMode) print('Error loading prev page: $e');
      _currentPage++; // rollback on error
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  // 6. Fungsi hitung tabel
  void calculateFromHistory(MarketData data) {
    calculateNewsmaker(
      symbolInput: '$_selectedNewsmakerSymbol (${data.date})',
      open: data.open,
      high: data.high,
      low: data.low,
      close: data.close,
    );
  }
}
