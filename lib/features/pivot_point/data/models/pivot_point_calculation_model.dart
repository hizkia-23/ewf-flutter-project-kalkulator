import '../../domain/entities/pivot_point_calculation.dart';

class PivotPointCalculationModel extends PivotPointCalculation {
  const PivotPointCalculationModel({
    required super.high,
    required super.low,
    required super.close,
    super.openingPrice,
    required super.pp,
    required super.range,
    required super.r1,
    required super.r2,
    required super.r3,
    required super.r4,
    required super.s1,
    required super.s2,
    required super.s3,
    required super.s4,
    required super.recommendation,
  });

  factory PivotPointCalculationModel.fromCalculation(
    PivotPointCalculation calculation,
  ) {
    return PivotPointCalculationModel(
      high: calculation.high,
      low: calculation.low,
      close: calculation.close,
      openingPrice: calculation.openingPrice,
      pp: calculation.pp,
      range: calculation.range,
      r1: calculation.r1,
      r2: calculation.r2,
      r3: calculation.r3,
      r4: calculation.r4,
      s1: calculation.s1,
      s2: calculation.s2,
      s3: calculation.s3,
      s4: calculation.s4,
      recommendation: calculation.recommendation,
    );
  }
}
