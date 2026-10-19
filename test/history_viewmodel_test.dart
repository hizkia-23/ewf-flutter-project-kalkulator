import 'package:flutter_test/flutter_test.dart';
import 'package:kalkulator_pivot/core/services/history_service.dart';
import 'package:kalkulator_pivot/features/history/presentation/viewmodels/history_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HistoryViewModel', () {
    test('deleteItem updates local state lists and notifies listeners', () async {
      final viewModel = HistoryViewModel();
      int notifyCount = 0;
      viewModel.addListener(() {
        notifyCount++;
      });

      // Simulasikan data lokal
      viewModel.goldHistoryList.add(
        GoldHistoryEntry(
          id: 'test_gold_1',
          timestamp: DateTime.now(),
          hb: 2000,
          hj: 2100,
          kurs: 15000,
          toz: 31.1,
          modalAwal: 100000000,
          hhb: 1000000,
          hhj: 1050000,
          selisih: 50000,
          gramEmas: 100,
          keuntunganBersih: 5000000,
        ),
      );

      viewModel.pivotHistoryList.add(
        PivotHistoryEntry(
          id: 'test_pivot_1',
          timestamp: DateTime.now(),
          high: 2100,
          low: 2000,
          close: 2050,
          openingPrice: 2040,
          pp: 2050,
          range: 100,
          r1: 2100,
          r2: 2150,
          r3: 2200,
          r4: 2250,
          s1: 2000,
          s2: 1950,
          s3: 1900,
          s4: 1850,
          recommendation: 'BUY',
        ),
      );

      viewModel.nestHistoryList.add(
        NestHistoryEntry(
          id: 'test_nest_1',
          timestamp: DateTime.now(),
          close: 2050,
          openingPrice: 2040,
          recommendation: 'BUY',
        ),
      );

      expect(viewModel.goldHistoryList.length, 1);
      expect(viewModel.pivotHistoryList.length, 1);
      expect(viewModel.nestHistoryList.length, 1);

      // Hapus Gold
      await viewModel.deleteItem('test_gold_1', 'gold');
      expect(viewModel.goldHistoryList.any((e) => e.id == 'test_gold_1'), false);
      expect(notifyCount, greaterThan(0));

      // Hapus Pivot
      final previousCount = notifyCount;
      await viewModel.deleteItem('test_pivot_1', 'pivot');
      expect(viewModel.pivotHistoryList.any((e) => e.id == 'test_pivot_1'), false);
      expect(notifyCount, greaterThan(previousCount));

      // Hapus Nest
      final beforeNest = notifyCount;
      await viewModel.deleteItem('test_nest_1', 'nest');
      expect(viewModel.nestHistoryList.any((e) => e.id == 'test_nest_1'), false);
      expect(notifyCount, greaterThan(beforeNest));
    });
  });
}
