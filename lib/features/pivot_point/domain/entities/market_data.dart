class MarketData {
  const MarketData({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  final String date;
  final double open;
  final double high;
  final double low;
  final double close;

  /// Kebal terhadap obfuscation R8 (ProGuard) & parsing aman int/double dari SQLite
  factory MarketData.fromMap(Map<String, dynamic> map) {
    return MarketData(
      date: map['date']?.toString() ?? '',
      open: (map['open'] as num?)?.toDouble() ?? 0.0,
      high: (map['high'] as num?)?.toDouble() ?? 0.0,
      low: (map['low'] as num?)?.toDouble() ?? 0.0,
      close: (map['close'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
    };
  }
}

