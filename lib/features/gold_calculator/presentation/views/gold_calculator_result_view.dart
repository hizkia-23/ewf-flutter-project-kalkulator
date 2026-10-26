import 'package:flutter/material.dart';

import '../../../../core/services/history_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../viewmodels/gold_calculator_viewmodel.dart';

class GoldCalculatorResultView extends StatefulWidget {
  const GoldCalculatorResultView({super.key});

  @override
  State<GoldCalculatorResultView> createState() =>
      _GoldCalculatorResultViewState();
}

class _GoldCalculatorResultViewState extends State<GoldCalculatorResultView> {
  bool _isSaved = false;

  String _formatCurrency(double value) {
    if (value.isNaN || value.isInfinite) return 'Rp0';
    final isNeg = value < 0;
    final intPart = value.abs().truncate().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return '${isNeg ? '-Rp' : 'Rp'}$intPart';
  }

  String _formatGram(double value) {
    if (value.isNaN || value.isInfinite) return '0,00 gram';
    final abs = value.abs();
    final str = abs.toStringAsFixed(2);
    final parts = str.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return '$intPart,${parts[1]} gram';
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is! Map<String, dynamic>) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Data hasil kalkulasi tidak ditemukan'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final vm = arguments['viewModel'] as GoldCalculatorViewModel?;
    final isSaved = _isSaved || (vm?.isSaved ?? false);

    final hb = (arguments['hb'] as num?)?.toDouble() ?? 0.0;
    final hj = (arguments['hj'] as num?)?.toDouble() ?? 0.0;
    final modalAwal = (arguments['modalAwal'] as num?)?.toDouble() ?? 0.0;
    final kurs = (arguments['kurs'] as num?)?.toDouble() ?? 18000.0;
    final hhb = (arguments['hhb'] as num?)?.toDouble() ?? 0.0;
    final hhj = (arguments['hhj'] as num?)?.toDouble() ?? 0.0;
    final selisih = (arguments['selisih'] as num?)?.toDouble() ?? 0.0;
    final gramEmas = (arguments['gramEmas'] as num?)?.toDouble() ?? 0.0;
    final keuntunganBersih =
        (arguments['keuntunganBersih'] as num?)?.toDouble() ?? 0.0;
    final isPos = keuntunganBersih >= 0;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [_BackButton()]),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Hasil Perhitungan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTimeNow(),
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textMuted,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── RESULT ROWS CARD ──────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: context.borderColor),
                        boxShadow: [
                          if (!context.isDarkMode)
                            BoxShadow(
                              color: Colors.black.withAlpha(8),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _resultRow(
                            'Harga Beli (HB)',
                            '\$${hb.toStringAsFixed(2)}',
                            context,
                          ),
                          _divider(context),
                          _resultRow(
                            'Harga Jual (HJ)',
                            '\$${hj.toStringAsFixed(2)}',
                            context,
                          ),
                          _divider(context),
                          _resultRow(
                            'Harga Hitung Beli (HHB)',
                            '${_formatCurrency(hhb)} / gram',
                            context,
                          ),
                          _divider(context),
                          _resultRow(
                            'Harga Hitung Jual (HHJ)',
                            '${_formatCurrency(hhj)} / gram',
                            context,
                          ),
                          _divider(context),
                          _resultRow(
                            'Selisih Harga',
                            '${_formatCurrency(selisih)} / gram',
                            context,
                          ),
                          _divider(context),
                          _resultRow(
                            'Estimasi Gram Emas',
                            _formatGram(gramEmas),
                            context,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── NET PROFIT CARD ───────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isPos
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPos ? 'KEUNTUNGAN BERSIH' : 'KERUGIAN',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${isPos ? '+' : ''}${_formatCurrency(keuntunganBersih)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── PARAMETERS CARD ───────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.isDarkMode ? AppColors.darkSurface : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PARAMETER DIGUNAKAN',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.textSecondary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _paramChip(
                                  'Modal Awal',
                                  _formatCurrency(modalAwal),
                                  context,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _paramChip(
                                  'Kurs USD',
                                  _formatCurrency(kurs),
                                  context,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: _paramChip('TOZ', '31.1', context)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── ACTION BUTTONS ────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isSaved
                            ? null
                            : () => _saveToHistory(arguments, vm),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSaved
                              ? (context.isDarkMode
                                  ? const Color(0xFF16A34A).withAlpha(40)
                                  : const Color(0xFFDCFCE7))
                              : (context.isDarkMode
                                  ? AppColors.primary
                                  : const Color(0xFF0F172A)),
                          foregroundColor:
                              isSaved ? const Color(0xFF16A34A) : Colors.white,
                          disabledBackgroundColor: context.isDarkMode
                              ? const Color(0xFF16A34A).withAlpha(35)
                              : const Color(0xFFDCFCE7),
                          disabledForegroundColor: const Color(0xFF16A34A),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: isSaved
                                ? const BorderSide(
                                    color: Color(0xFF16A34A),
                                    width: 1.5,
                                  )
                                : BorderSide.none,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isSaved
                                  ? Icons.check_circle_rounded
                                  : Icons.bookmark_outline_rounded,
                              size: 18,
                              color: isSaved
                                  ? const Color(0xFF16A34A)
                                  : Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isSaved ? 'Tersimpan' : 'Simpan ke Riwayat',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isSaved
                                    ? const Color(0xFF16A34A)
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),


                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Text(
                        'Perhitungan berdasarkan spread pasar. Pastikan konfirmasi dengan kantor cabang sebelum transaksi.',
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textMuted,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveToHistory(
    Map<String, dynamic> data,
    GoldCalculatorViewModel? viewModel,
  ) async {
    if (_isSaved || (viewModel?.isSaved ?? false)) return;

    if (viewModel != null) {
      await viewModel.saveToHistory();
    } else {
      final entry = GoldHistoryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        hb: (data['hb'] as num).toDouble(),
        hj: (data['hj'] as num).toDouble(),
        kurs: (data['kurs'] as num).toDouble(),
        toz: (data['toz'] as num?)?.toDouble() ?? 31.1,
        modalAwal: (data['modalAwal'] as num).toDouble(),
        hhb: (data['hhb'] as num).toDouble(),
        hhj: (data['hhj'] as num).toDouble(),
        selisih: (data['selisih'] as num).toDouble(),
        gramEmas: (data['gramEmas'] as num).toDouble(),
        keuntunganBersih: (data['keuntunganBersih'] as num).toDouble(),
      );
      await HistoryService.instance.addGold(entry);
    }

    if (!mounted) return;
    setState(() {
      _isSaved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perhitungan berhasil disimpan ke riwayat'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF16A34A),
      ),
    );
  }

  Widget _resultRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: context.textSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Divider(
    height: 0,
    color: context.dividerColor,
    indent: 16,
    endIndent: 16,
  );

  Widget _paramChip(String label, String value, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: context.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatDateTimeNow() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '${now.day} ${months[now.month - 1]} ${now.year} • $h:$m';
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: context.textPrimary,
        ),
      ),
    );
  }
}
