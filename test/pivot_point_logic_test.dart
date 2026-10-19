import 'package:flutter_test/flutter_test.dart';
import 'package:kalkulator_pivot/features/pivot_point/data/repositories/pivot_point_repository_impl.dart';
import 'package:kalkulator_pivot/features/pivot_point/domain/usecases/calculate_pivot_point.dart';

void main() {
  group('CalculatePivotPoint', () {
    late CalculatePivotPoint useCase;

    setUp(() {
      useCase = CalculatePivotPoint(PivotPointRepositoryImpl());
    });

    test('calculates pivot values correctly', () {
      final result = useCase.call(
        high: 4150,
        low: 4100,
        close: 4130,
        openingPrice: 4120,
      );

      expect(result.pp, closeTo(4126.6666666667, 0.0001));
      expect(result.range, 50);
      expect(result.r1, closeTo(4153.3333333333, 0.0001));
      expect(result.r2, closeTo(4176.6666666667, 0.0001));
      expect(result.r3, closeTo(4226.6666666667, 0.0001));
      expect(result.r4, closeTo(4276.6666666667, 0.0001));
      expect(result.s1, closeTo(4103.3333333333, 0.0001));
      expect(result.s2, closeTo(4076.6666666667, 0.0001));
      expect(result.s3, closeTo(4026.6666666667, 0.0001));
      expect(result.s4, closeTo(3976.6666666667, 0.0001));
      expect(result.recommendation, 'BUY');
    });

    test('returns SELL when PP is below OP', () {
      final result = useCase.call(
        high: 4100,
        low: 4000,
        close: 4050,
        openingPrice: 4200,
      );

      expect(result.recommendation, 'SELL');
    });

    test('returns NEUTRAL when PP is equal to OP', () {
      final result = useCase.call(
        high: 4150,
        low: 4100,
        close: 4125,
        openingPrice: 4125,
      );

      expect(result.recommendation, 'NEUTRAL');
    });

    test('calculates pivot values correctly and returns "-" recommendation when OP is null', () {
      final result = useCase.call(
        high: 4150,
        low: 4100,
        close: 4130,
      );

      expect(result.pp, closeTo(4126.6666666667, 0.0001));
      expect(result.range, 50);
      expect(result.r1, closeTo(4153.3333333333, 0.0001));
      expect(result.r2, closeTo(4176.6666666667, 0.0001));
      expect(result.s1, closeTo(4103.3333333333, 0.0001));
      expect(result.s2, closeTo(4076.6666666667, 0.0001));
      expect(result.openingPrice, isNull);
      expect(result.recommendation, '-');
    });
  });
}
