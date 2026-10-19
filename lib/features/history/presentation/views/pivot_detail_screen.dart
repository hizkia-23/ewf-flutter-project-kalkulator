import 'package:flutter/material.dart';

import '../../../../core/services/history_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart'; // <-- Pastikan import ini ditambahkan

class PivotDetailScreen extends StatelessWidget {
  const PivotDetailScreen({super.key});

  String _formatDateTime(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} • $h:$m';
  }

  Color _signalColor(String rec) {
    if (rec == 'BUY') return AppColors.positive;
    if (rec == 'SELL') return AppColors.negative;
    return AppColors.gray;
  }

  @override
  Widget build(BuildContext context) {
    final entry = ModalRoute.of(context)?.settings.arguments;
    if (entry is! PivotHistoryEntry) {
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Data tidak ditemukan', style: TextStyle(color: context.textPrimary)),
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

    final recommendation = entry.recommendation;
    final signalColor = _signalColor(recommendation);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ───────────────────────────────────────────────────
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
                      'Detail Pivot Point',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(entry.timestamp),
                      style: TextStyle(fontSize: 13, color: context.textSecondary),
                    ),

                    const SizedBox(height: 24),

                    // OHLC Inputs Card
                    Container(
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _detailRow(context, 'High', entry.high.toStringAsFixed(2)),
                          _divider(context),
                          _detailRow(context, 'Low', entry.low.toStringAsFixed(2)),
                          _divider(context),
                          _detailRow(context, 'Close', entry.close.toStringAsFixed(2)),
                          _divider(context),
                          _detailRow(
                            context,
                            'Open (OP)',
                            entry.openingPrice != null
                                ? entry.openingPrice!.toStringAsFixed(2)
                                : '-',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // PP & Range row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.chipBg,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Titik Pivot (PP)',
                                  style: TextStyle(fontSize: 11, color: context.textSecondary),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  entry.pp.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: context.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.chipBg,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rentang Harian',
                                  style: TextStyle(fontSize: 11, color: context.textSecondary),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  entry.range.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: context.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Recommendation Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: signalColor, // Tetap menggunakan warna sinyal (merah/hijau)
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'REKOMENDASI',
                            style: TextStyle(
                              color: Colors.white70, // Teks di atas warna solid tetap putih
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            recommendation,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Resistance & Support levels
                    Container(
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(8),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _levelRow(context, 'R4', entry.r4, AppColors.negative),
                          _levelDivider(context),
                          _levelRow(context, 'R3', entry.r3, AppColors.negative),
                          _levelDivider(context),
                          _levelRow(context, 'R2', entry.r2, AppColors.negative),
                          _levelDivider(context),
                          _levelRow(context, 'R1', entry.r1, AppColors.negative),
                          _levelDivider(context),
                          _levelRow(context, 'PP', entry.pp, context.textPrimary, isPivot: true),
                          _levelDivider(context),
                          _levelRow(context, 'S1', entry.s1, AppColors.positive),
                          _levelDivider(context),
                          _levelRow(context, 'S2', entry.s2, AppColors.positive),
                          _levelDivider(context),
                          _levelRow(context, 'S3', entry.s3, AppColors.positive),
                          _levelDivider(context),
                          _levelRow(context, 'S4', entry.s4, AppColors.positive),
                        ],
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

  // Tambahkan parameter BuildContext agar bisa mengakses AppThemeExtension
  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: context.textSecondary)),
          Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) => Divider(height: 0, color: context.dividerColor, indent: 16, endIndent: 16);
  Widget _levelDivider(BuildContext context) => Divider(height: 0, color: context.dividerColor);

  Widget _levelRow(BuildContext context, String label, double value, Color color, {bool isPivot = false}) {
    return Container(
      color: isPivot ? context.chipBg : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isPivot ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              value.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
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
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 6, offset: const Offset(0, 1)),
          ],
        ),
        child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: context.textPrimary),
      ),
    );
  }
}