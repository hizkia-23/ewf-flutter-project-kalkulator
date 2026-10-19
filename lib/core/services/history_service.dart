import 'package:kalkulator_pivot/core/database/database_helper.dart';
import 'package:flutter/foundation.dart';

enum HistoryType { gold, pivot, nest }

class GoldHistoryEntry {
  const GoldHistoryEntry({
    required this.id,
    required this.timestamp,
    required this.hb,
    required this.hj,
    required this.kurs,
    required this.toz,
    required this.modalAwal,
    required this.hhb,
    required this.hhj,
    required this.selisih,
    required this.gramEmas,
    required this.keuntunganBersih,
  });

  final String id;
  final DateTime timestamp;
  final double hb;
  final double hj;
  final double kurs;
  final double toz;
  final double modalAwal;
  final double hhb;
  final double hhj;
  final double selisih;
  final double gramEmas;
  final double keuntunganBersih;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'hb': hb,
      'hj': hj,
      'kurs': kurs,
      'toz': toz,
      'modalAwal': modalAwal,
      'hhb': hhb,
      'hhj': hhj,
      'selisih': selisih,
      'gramEmas': gramEmas,
      'keuntunganBersih': keuntunganBersih,
    };
  }

  factory GoldHistoryEntry.fromMap(Map<String, dynamic> map) {
    return GoldHistoryEntry(
      id: map['id'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      hb: (map['hb'] as num).toDouble(),
      hj: (map['hj'] as num).toDouble(),
      kurs: (map['kurs'] as num).toDouble(),
      toz: (map['toz'] as num).toDouble(),
      modalAwal: (map['modalAwal'] as num).toDouble(),
      hhb: (map['hhb'] as num).toDouble(),
      hhj: (map['hhj'] as num).toDouble(),
      selisih: (map['selisih'] as num).toDouble(),
      gramEmas: (map['gramEmas'] as num).toDouble(),
      keuntunganBersih: (map['keuntunganBersih'] as num).toDouble(),
    );
  }
}

class PivotHistoryEntry {
  const PivotHistoryEntry({
    required this.id,
    required this.timestamp,
    required this.high,
    required this.low,
    required this.close,
    this.openingPrice,
    required this.pp,
    required this.range,
    required this.r1,
    required this.r2,
    required this.r3,
    required this.r4,
    required this.s1,
    required this.s2,
    required this.s3,
    required this.s4,
    required this.recommendation,
  });

  final String id;
  final DateTime timestamp;
  final double high;
  final double low;
  final double close;
  final double? openingPrice;
  final double pp;
  final double range;
  final double r1;
  final double r2;
  final double r3;
  final double r4;
  final double s1;
  final double s2;
  final double s3;
  final double s4;
  final String recommendation;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'high': high,
      'low': low,
      'close': close,
      'openingPrice': openingPrice,
      'pp': pp,
      'range': range,
      'r1': r1,
      'r2': r2,
      'r3': r3,
      'r4': r4,
      's1': s1,
      's2': s2,
      's3': s3,
      's4': s4,
      'recommendation': recommendation,
    };
  }

  factory PivotHistoryEntry.fromMap(Map<String, dynamic> map) {
    return PivotHistoryEntry(
      id: map['id'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      high: (map['high'] as num).toDouble(),
      low: (map['low'] as num).toDouble(),
      close: (map['close'] as num).toDouble(),
      openingPrice: map['openingPrice'] != null
          ? (map['openingPrice'] as num).toDouble()
          : null,
      pp: (map['pp'] as num).toDouble(),
      range: (map['range'] as num).toDouble(),
      r1: (map['r1'] as num).toDouble(),
      r2: (map['r2'] as num).toDouble(),
      r3: (map['r3'] as num).toDouble(),
      r4: (map['r4'] as num).toDouble(),
      s1: (map['s1'] as num).toDouble(),
      s2: (map['s2'] as num).toDouble(),
      s3: (map['s3'] as num).toDouble(),
      s4: (map['s4'] as num).toDouble(),
      recommendation: map['recommendation'] as String,
    );
  }
}

class NestHistoryEntry {
  final String id;
  final DateTime timestamp;
  final double close;
  final double openingPrice;
  final String recommendation;

  NestHistoryEntry({
    required this.id,
    required this.timestamp,
    required this.close,
    required this.openingPrice,
    required this.recommendation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'close': close,
      'openingPrice': openingPrice,
      'recommendation': recommendation,
    };
  }

  factory NestHistoryEntry.fromMap(Map<String, dynamic> map) {
    return NestHistoryEntry(
      id: map['id'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      close: (map['close'] as num).toDouble(),
      openingPrice: (map['openingPrice'] as num).toDouble(),
      recommendation: map['recommendation'] as String,
    );
  }
}

class HistoryService {
  HistoryService._() {
    loadHistory();
  }
  static final HistoryService instance = HistoryService._();

  final List<GoldHistoryEntry> _goldHistory = [];
  final List<PivotHistoryEntry> _pivotHistory = [];
  final List<NestHistoryEntry> _nestHistory = [];

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  List<GoldHistoryEntry> get goldHistory =>
      List.unmodifiable(_goldHistory.reversed.toList());
  List<PivotHistoryEntry> get pivotHistory =>
      List.unmodifiable(_pivotHistory.reversed.toList());
  List<NestHistoryEntry> get nestHistory =>
      List.unmodifiable(_nestHistory.reversed.toList());

  /// Memuat semua riwayat dari database SQLite ke dalam memori
  Future<void> loadHistory() async {
    try {
      final db = await DatabaseHelper.instance.database;

      final goldMaps = await db.query('gold_history', orderBy: 'timestamp ASC');
      _goldHistory
        ..clear()
        ..addAll(goldMaps.map(GoldHistoryEntry.fromMap));

      final pivotMaps = await db.query('pivot_history', orderBy: 'timestamp ASC');
      _pivotHistory
        ..clear()
        ..addAll(pivotMaps.map(PivotHistoryEntry.fromMap));

      final nestMaps = await db.query('nest_history', orderBy: 'timestamp ASC');
      _nestHistory
        ..clear()
        ..addAll(nestMaps.map(NestHistoryEntry.fromMap));

      _isLoaded = true;
      if (kDebugMode) {
        print(
          'Riwayat berhasil dimuat: Emas (${_goldHistory.length}), Pivot (${_pivotHistory.length}), Nest (${_nestHistory.length})',
        );
      }
    } catch (e) {
      if (kDebugMode) print('Gagal memuat riwayat dari SQLite: $e');
    }
  }

  Future<void> addGold(GoldHistoryEntry entry) async {
    _goldHistory.add(entry);
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert('gold_history', entry.toMap());
    } catch (e) {
      if (kDebugMode) print('Gagal menyimpan riwayat Emas ke SQLite: $e');
    }
  }

  Future<void> addPivot(PivotHistoryEntry entry) async {
    _pivotHistory.add(entry);
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert('pivot_history', entry.toMap());
    } catch (e) {
      if (kDebugMode) print('Gagal menyimpan riwayat Pivot ke SQLite: $e');
    }
  }

  Future<void> addNest(NestHistoryEntry entry) async {
    _nestHistory.add(entry);
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert('nest_history', entry.toMap());
    } catch (e) {
      if (kDebugMode) print('Gagal menyimpan riwayat Nest ke SQLite: $e');
    }
  }

  // ── Individual delete methods ──────────────────────────────────────────────

  Future<void> deleteGoldItem(dynamic id) async {
    final strId = id.toString();
    _goldHistory.removeWhere((e) => e.id == strId);
    try {
      await DatabaseHelper.instance.deleteById('gold_history', strId);
    } catch (e) {
      if (kDebugMode) print('Gagal menghapus item Emas dari SQLite: $e');
    }
  }

  Future<void> deletePivotItem(dynamic id) async {
    final strId = id.toString();
    _pivotHistory.removeWhere((e) => e.id == strId);
    try {
      await DatabaseHelper.instance.deleteById('pivot_history', strId);
    } catch (e) {
      if (kDebugMode) print('Gagal menghapus item Pivot dari SQLite: $e');
    }
  }

  Future<void> deleteNestItem(dynamic id) async {
    final strId = id.toString();
    _nestHistory.removeWhere((e) => e.id == strId);
    try {
      await DatabaseHelper.instance.deleteById('nest_history', strId);
    } catch (e) {
      if (kDebugMode) print('Gagal menghapus item Nest dari SQLite: $e');
    }
  }

  Future<void> deleteItem(dynamic id, dynamic type) async {
    final typeStr = type.toString().toLowerCase();
    if (typeStr.contains('gold')) {
      await deleteGoldItem(id);
    } else if (typeStr.contains('pivot')) {
      await deletePivotItem(id);
    } else if (typeStr.contains('nest')) {
      await deleteNestItem(id);
    }
  }

  // ── Clear all ─────────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    _goldHistory.clear();
    _pivotHistory.clear();
    _nestHistory.clear();
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('gold_history');
      await db.delete('pivot_history');
      await db.delete('nest_history');
    } catch (e) {
      if (kDebugMode) print('Gagal menghapus riwayat dari SQLite: $e');
    }
  }

  // Untuk dashboard: gabungan terbaru (3 item)
  List<Map<String, dynamic>> getRecentCombined({int limit = 3}) {
    final combined = <Map<String, dynamic>>[];

    for (final g in _goldHistory) {
      combined.add({
        'type': HistoryType.gold,
        'entry': g,
        'timestamp': g.timestamp,
      });
    }
    for (final p in _pivotHistory) {
      combined.add({
        'type': HistoryType.pivot,
        'entry': p,
        'timestamp': p.timestamp,
      });
    }
    for (final n in _nestHistory) {
      combined.add({
        'type': HistoryType.nest,
        'entry': n,
        'timestamp': n.timestamp,
      });
    }

    combined.sort(
      (a, b) =>
          (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime),
    );
    return combined.take(limit).toList();
  }
}