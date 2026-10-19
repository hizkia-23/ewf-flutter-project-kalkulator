import '../entities/market_data.dart';
import '../entities/pivot_point_calculation.dart';
import '../repositories/pivot_point_repository.dart';

class CalculatePivotPoint {
  const CalculatePivotPoint(this.repository);

  final PivotPointRepository repository;

  /// Formula:
  /// PP = (High + Low + Close) ÷ 3
  /// Range = High − Low
  /// R1 = (2 × PP) − Low, R2 = PP + Range, R3 = PP + 2Range, R4 = PP + 3Range
  /// S1 = (2 × PP) − High, S2 = PP − Range, S3 = PP − 2Range, S4 = PP − 3Range
  /// Recommendation: PP > OP = BUY, PP < OP = SELL, PP = OP = NEUTRAL
  PivotPointCalculation call({
    required double high,
    required double low,
    required double close,
    double? openingPrice,
  }) {
    final pp = (high + low + close) / 3;
    final range = high - low;

    final r1 = (2 * pp) - low;
    final r2 = pp + range;
    final r3 = pp + (2 * range);
    final r4 = pp + (3 * range);

    final s1 = (2 * pp) - high;
    final s2 = pp - range;
    final s3 = pp - (2 * range);
    final s4 = pp - (3 * range);

    String recommendation;
    if (openingPrice == null) {
      recommendation = '-';
    } else if (pp > openingPrice) {
      recommendation = 'BUY';
    } else if (pp < openingPrice) {
      recommendation = 'SELL';
    } else {
      recommendation = 'NEUTRAL';
    }

    return PivotPointCalculation(
      high: high,
      low: low,
      close: close,
      openingPrice: openingPrice,
      pp: pp,
      range: range,
      r1: r1,
      r2: r2,
      r3: r3,
      r4: r4,
      s1: s1,
      s2: s2,
      s3: s3,
      s4: s4,
      recommendation: recommendation,
    );
  }

  Future<({PivotPointCalculation calculation, MarketData marketData})>
      fetchAndCalculate(String targetUrl) async {
    final marketData = await repository.fetchMarketData(targetUrl);
    final calculation = call(
      high: marketData.high,
      low: marketData.low,
      close: marketData.close,
      openingPrice: marketData.open,
    );

    return (calculation: calculation, marketData: marketData);
  }
}
