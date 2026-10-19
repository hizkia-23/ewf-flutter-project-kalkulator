import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 👇 Ubah dari 2 jadi 3 tab
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goldHistory = HistoryService.instance.goldHistory;
    final pivotHistory = HistoryService.instance.pivotHistory;
    final nestHistory = HistoryService.instance.nestHistory; // 👇 Tarik data Nest

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  _BackButton(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Riwayat Transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: context.cardBg,
                          title: Text(
                            'Hapus Semua Riwayat',
                            style: TextStyle(color: context.textPrimary),
                          ),
                          content: Text(
                            'Semua riwayat perhitungan akan dihapus. Lanjutkan?',
                            style: TextStyle(color: context.textSecondary),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Batal', style: TextStyle(color: context.textMuted)),
                            ),
                            TextButton(
                              onPressed: () {
                                HistoryService.instance.clearAll();
                                Navigator.pop(context);
                                setState(() {});
                              },
                              child: const Text(
                                'Hapus',
                                style: TextStyle(color: AppColors.negative),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: context.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── TAB BAR ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: context.isDarkMode ? AppColors.darkSurface : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: context.isDarkMode ? AppColors.darkBorder : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      if (!context.isDarkMode)
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: context.textPrimary,
                  unselectedLabelColor: context.textSecondary,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.diamond_outlined, size: 16),
                          const SizedBox(width: 4),
                          const Text('Gold'),
                          if (goldHistory.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(40),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${goldHistory.length}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.candlestick_chart_rounded, size: 16),
                          const SizedBox(width: 4),
                          const Text('Pivot'),
                          if (pivotHistory.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withAlpha(40),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${pivotHistory.length}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF3B82F6),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // 👇 TAB BARU UNTUK NEST
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.hub_outlined, size: 16),
                          const SizedBox(width: 4),
                          const Text('Nest'),
                          if (nestHistory.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withAlpha(40), // Emerald Green
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${nestHistory.length}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── TAB VIEWS ────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _GoldHistoryTab(
                    goldHistory: goldHistory,
                    onTap: (entry) => Navigator.of(context).pushNamed(AppRoutes.goldDetail, arguments: entry),
                    onDelete: (entry) async {
                      await HistoryService.instance.deleteGoldItem(entry.id);
                      setState(() {});
                    },
                  ),
                  _PivotHistoryTab(
                    pivotHistory: pivotHistory,
                    onTap: (entry) => Navigator.of(context).pushNamed(AppRoutes.pivotDetail, arguments: entry),
                    onDelete: (entry) async {
                      await HistoryService.instance.deletePivotItem(entry.id);
                      setState(() {});
                    },
                  ),
                  _NestHistoryTab(
                    nestHistory: nestHistory,
                    onTap: (entry) => Navigator.of(context).pushNamed(AppRoutes.nestDetail, arguments: entry),
                    onDelete: (entry) async {
                      await HistoryService.instance.deleteNestItem(entry.id);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── GOLD HISTORY TAB ─────────────────────────────────────────────────────────
class _GoldHistoryTab extends StatelessWidget {
  const _GoldHistoryTab({required this.goldHistory, required this.onTap, required this.onDelete});

  final List<GoldHistoryEntry> goldHistory;
  final void Function(GoldHistoryEntry) onTap;
  final Future<void> Function(GoldHistoryEntry) onDelete;

  @override
  Widget build(BuildContext context) {
    if (goldHistory.isEmpty) {
      return const _EmptyState(
        icon: Icons.diamond_outlined,
        message: 'Belum ada riwayat\nKalkulator Emas Fisik.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: goldHistory.length,
      itemBuilder: (context, index) {
        final entry = goldHistory[index];
        final isPos = entry.keuntunganBersih >= 0;
        return Dismissible(
          key: ValueKey(entry.id),
          direction: DismissDirection.endToStart,
          background: _DismissBackground(),
          confirmDismiss: (_) => _confirmDelete(context),
          onDismissed: (_) => onDelete(entry),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderColor),
              boxShadow: [
                if (!context.isDarkMode)
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onTap(entry),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: context.isDarkMode ? AppColors.primary.withAlpha(35) : const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.diamond_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDateTime(entry.timestamp),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'HB \$${entry.hb.toStringAsFixed(2)}   |   HJ \$${entry.hj.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: context.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: context.textMuted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Divider(height: 0, color: context.dividerColor),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Net Profit',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.textSecondary,
                            ),
                          ),
                          Text(
                            _formatCurrency(entry.keuntunganBersih),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isPos ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} • $h:$m';
  }

  String _formatCurrency(double value) {
    final isNeg = value < 0;
    final intPart = value.abs().truncate().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return '${isNeg ? '-' : ''}Rp$intPart';
  }
}

// ─── PIVOT HISTORY TAB ────────────────────────────────────────────────────────
class _PivotHistoryTab extends StatelessWidget {
  const _PivotHistoryTab({required this.pivotHistory, required this.onTap, required this.onDelete});

  final List<PivotHistoryEntry> pivotHistory;
  final void Function(PivotHistoryEntry) onTap;
  final Future<void> Function(PivotHistoryEntry) onDelete;

  Color _signalColor(String rec) {
    if (rec == 'BUY') return const Color(0xFF16A34A);
    if (rec == 'SELL') return const Color(0xFFDC2626);
    return const Color(0xFF64748B);
  }

  Color _signalBg(String rec, BuildContext context) {
    if (rec == 'BUY') {
      return context.isDarkMode ? const Color(0xFF16A34A).withAlpha(40) : const Color(0xFFDCFCE7);
    }
    if (rec == 'SELL') {
      return context.isDarkMode ? const Color(0xFFDC2626).withAlpha(40) : const Color(0xFFFEE2E2);
    }
    return context.isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
  }

  @override
  Widget build(BuildContext context) {
    if (pivotHistory.isEmpty) {
      return const _EmptyState(
        icon: Icons.candlestick_chart_rounded,
        message: 'Belum ada riwayat\nAnalisa Pivot Point.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: pivotHistory.length,
      itemBuilder: (context, index) {
        final entry = pivotHistory[index];
        return Dismissible(
          key: ValueKey(entry.id),
          direction: DismissDirection.endToStart,
          background: _DismissBackground(),
          confirmDismiss: (_) => _confirmDelete(context),
          onDismissed: (_) => onDelete(entry),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderColor),
              boxShadow: [
                if (!context.isDarkMode)
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onTap(entry),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: context.isDarkMode
                                  ? const Color(0xFF3B82F6).withAlpha(35)
                                  : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.candlestick_chart_rounded,
                              size: 18,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDateTime(entry.timestamp),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'XAU/USD',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: context.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: context.textMuted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Divider(height: 0, color: context.dividerColor),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PP ${entry.pp.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _signalBg(entry.recommendation, context),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              entry.recommendation,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _signalColor(entry.recommendation),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} • $h:$m';
  }
}

// 👇 ─── NEST HISTORY TAB (BARU!) ──────────────────────────────────────────────
class _NestHistoryTab extends StatelessWidget {
  const _NestHistoryTab({required this.nestHistory, required this.onTap, required this.onDelete});

  final List<NestHistoryEntry> nestHistory;
  final void Function(NestHistoryEntry) onTap;
  final Future<void> Function(NestHistoryEntry) onDelete;

  Color _signalColor(String rec) {
    if (rec == 'BUY') return const Color(0xFF16A34A);
    if (rec == 'SELL') return const Color(0xFFDC2626);
    return const Color(0xFF64748B);
  }

  Color _signalBg(String rec, BuildContext context) {
    if (rec == 'BUY') {
      return context.isDarkMode ? const Color(0xFF16A34A).withAlpha(40) : const Color(0xFFDCFCE7);
    }
    if (rec == 'SELL') {
      return context.isDarkMode ? const Color(0xFFDC2626).withAlpha(40) : const Color(0xFFFEE2E2);
    }
    return context.isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
  }

  @override
  Widget build(BuildContext context) {
    if (nestHistory.isEmpty) {
      return const _EmptyState(
        icon: Icons.hub_outlined,
        message: 'Belum ada riwayat\nAnalisa Konsep Nest.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: nestHistory.length,
      itemBuilder: (context, index) {
        final entry = nestHistory[index];
        return Dismissible(
          key: ValueKey(entry.id),
          direction: DismissDirection.endToStart,
          background: _DismissBackground(),
          confirmDismiss: (_) => _confirmDelete(context),
          onDismissed: (_) => onDelete(entry),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderColor),
              boxShadow: [
                if (!context.isDarkMode)
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onTap(entry),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: context.isDarkMode
                                  ? const Color(0xFF10B981).withAlpha(35)
                                  : const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.hub_outlined,
                              size: 18,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDateTime(entry.timestamp),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'XAU/USD',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: context.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: context.textMuted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Divider(height: 0, color: context.dividerColor),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'C: \$${entry.close.toStringAsFixed(2)} | O: \$${entry.openingPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _signalBg(entry.recommendation, context),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              entry.recommendation,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _signalColor(entry.recommendation),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} • $h:$m';
  }
}

// ─── SHARED DISMISS HELPERS ───────────────────────────────────────────────────

/// Dialog konfirmasi sebelum menghapus item riwayat
Future<bool?> _confirmDelete(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: context.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Hapus Riwayat',
        style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w700),
      ),
      content: Text(
        'Apakah Anda yakin ingin menghapus riwayat ini?',
        style: TextStyle(color: context.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Batal', style: TextStyle(color: context.textMuted)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Hapus',
            style: TextStyle(color: AppColors.negative),
          ),
        ),
      ],
    ),
  );
}

/// Latar belakang merah dengan ikon hapus saat kartu di-swipe
class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
          SizedBox(height: 4),
          Text(
            'Hapus',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── EMPTY STATE ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.chipBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 36, color: context.textMuted),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: context.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── BACK BUTTON ─────────────────────────────────────────────────────────────
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
            if (!context.isDarkMode)
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