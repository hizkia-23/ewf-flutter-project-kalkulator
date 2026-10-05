import 'package:flutter/foundation.dart';
import 'package:kalkulator_pivot/features/pivot_point/domain/entities/market_data.dart';
import 'package:kalkulator_pivot/features/pivot_point/data/datasources/newsmaker_api_service.dart';
import 'package:kalkulator_pivot/features/pivot_point/data/datasources/pivot_point_local_data_source.dart';
import 'package:kalkulator_pivot/core/database/database_helper.dart';

// ── ENTITAS HASIL NEST ──
class NestCalculation {
  final double close; // Close hari sebelumnya
  final double openingPrice; // Open hari ini
  final String recommendation;

  NestCalculation({
    required this.close,
    required this.openingPrice,
    required this.recommendation,
  });
}

/// ViewModel untuk Nest Calculator.
class NestViewModel extends ChangeNotifier {
  NestViewModel() {
    _initData();
  }

  NestCalculation? result;
  String? errorMessage;
  bool isLoading = false;
  bool isManualMode = true;
  String symbol = 'XAU/USD';
  String lastUpdated = '';

  String _selectedNewsmakerSymbol = 'Gold';
  String get selectedNewsmakerSymbol => _selectedNewsmakerSymbol;

  Map<String, List<MarketData>> _historyDatabase = {
    'Gold': [],
    'Hang Seng': [],
    'Nikkei': [],
  };

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

  // ── FUNGSI MENARIK DATA (CACHE-THEN-NETWORK) ──
  Future<void> _initData() async {
    try {
      final apiService = NewsmakerApiService();
      final dbHelper = DatabaseHelper.instance;
      final localDataSource = PivotPointLocalDataSourceImpl(dbHelper);

      _currentPage = 0;
      _hasMoreData = true;
      _isFetchingMore = false;

      // 1. LANGSUNG TARIK DARI SQLITE
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

      notifyListeners();

      // 2. SINKRONISASI API SILENT DI BELAKANG LAYAR
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
          await localDataSource.saveMarketData('Gold', goldData);
          await localDataSource.saveMarketData('Hang Seng', hangsengData);
          await localDataSource.saveMarketData('Nikkei', nikkeiData);
          await localDataSource.clearOldMarketData();

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

          notifyListeners();
        }
      } catch (e) {
        if (kDebugMode)
          print('API Nest Gagal/Offline. Tetap aman pakai cache.');
      }
    } catch (e) {
      if (kDebugMode) print('Kesalahan saat inisialisasi data Nest: $e');
    }
  }

  void setManualMode(bool manual) {
    if (isManualMode == manual) return;
    isManualMode = manual;
    resetResults();
    notifyListeners();
  }

  // ── LOGIKA UTAMA PERHITUNGAN NEST ──
  Future<void> calculateManual({
    required double close,
    required double openingPrice,
  }) async {
    if (!_validateInputs(close, openingPrice)) {
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      String rec;
      if (openingPrice < close) {
        rec = 'BUY';
      } else if (openingPrice > close) {
        rec = 'SELL';
      } else {
        rec = 'WAIT / HOLD';
      }

      result = NestCalculation(
        close: close,
        openingPrice: openingPrice,
        recommendation: rec,
      );

      errorMessage = null;
    } catch (e) {
      errorMessage = 'Error dalam kalkulasi Nest: $e';
      result = null;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> calculateNewsmaker({
    required String symbolInput,
    required double open,
    required double close,
  }) async {
    symbol = symbolInput.trim().isEmpty ? 'XAU/USD' : symbolInput.trim();

    await calculateManual(
      close: close,
      openingPrice: open,
    );
  }

  bool _validateInputs(
    double close,
    double openingPrice,
  ) {
    if (close <= 0 || openingPrice <= 0) {
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

  // ── PAGINATION & GANTI SIMBOL ──
  Future<void> changeNewsmakerSymbol(String newSymbol) async {
    if (_selectedNewsmakerSymbol != newSymbol) {
      _selectedNewsmakerSymbol = newSymbol;
      _currentPage = 0;
      _hasMoreData = true;
      _isFetchingMore = false;

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
        _currentPage--;
      } else {
        _historyDatabase[_selectedNewsmakerSymbol] = newData;
        if (newData.length < _limit) _hasMoreData = false;
      }
    } catch (e) {
      _currentPage--;
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
      _hasMoreData = true;
    } catch (e) {
      _currentPage++;
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }
}