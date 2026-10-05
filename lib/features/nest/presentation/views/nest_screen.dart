import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:kalkulator_pivot/features/pivot_point/presentation/widgets/newsmaker_table_widget.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/number_formatter.dart';
import '../viewmodels/nest_viewmodel.dart';
import 'package:kalkulator_pivot/core/services/history_service.dart';
import '../../../../core/services/image_capture_service.dart';
class NestScreen extends StatelessWidget {
  const NestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NestViewModel(),
      child: const _NestView(),
    );
  }
}

class _NestView extends StatefulWidget {
  const _NestView();

  @override
  State<_NestView> createState() => _NestViewState();
}

class _NestViewState extends State<_NestView>
    with SingleTickerProviderStateMixin {
  late TextEditingController closeController;
  late TextEditingController opController;
  late TabController _tabController;
  late ScrollController _mainScrollController;
  bool _isManual = true;

  NestViewModel? _viewModelRef;
  bool _hasInjectedInitialData = false;
  final GlobalKey _resultKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    closeController = TextEditingController();
    opController = TextEditingController();
    _mainScrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModelRef = context.read<NestViewModel>();
      _viewModelRef?.addListener(_onViewModelUpdated);
    });

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      setState(() => _isManual = _tabController.index == 0);
      context.read<NestViewModel>().setManualMode(_isManual);
    });
  }

  void _onViewModelUpdated() {
    if (_hasInjectedInitialData || _viewModelRef == null) return;

    if (_viewModelRef!.newsmakerHistories.isNotEmpty) {
      final latestScrapedData = _viewModelRef!.newsmakerHistories.first;

      setState(() {
        closeController.text = latestScrapedData.close.toStringAsFixed(2);
      });
      _hasInjectedInitialData = true;
    }
  }

  @override
  void dispose() {
    _viewModelRef?.removeListener(_onViewModelUpdated);
    closeController.dispose();
    opController.dispose();
    _tabController.dispose();
    _mainScrollController.dispose();
    super.dispose();
  }

  Color _signalColor(String rec) {
    if (rec == 'BUY') return const Color(0xFF16A34A);
    if (rec == 'SELL') return const Color(0xFFDC2626);
    return const Color(0xFF64748B);
  }

  // ── FUNGSI AUTO SCROLL KE BAWAH ──
  void _scrollToBottom() {
    if (_mainScrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _mainScrollController.animateTo(
          _mainScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _calculate(NestViewModel viewModel) async {
    if (_isManual) {
      await viewModel.calculateManual(
        close: parseDecimal(closeController.text),
        openingPrice: parseDecimal(opController.text),
      );
    }

    if (!mounted) return;
    if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage!),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.negative,
        ),
      );
    } else {
      // Panggil scroll jika perhitungan sukses tanpa error
      _scrollToBottom();
    }
  }

  void _saveToHistory(NestViewModel viewModel) {
    final data = viewModel.result;
    if (data == null) return;

    final entry = NestHistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      close: data.close,
      openingPrice: data.openingPrice,
      recommendation: data.recommendation,
    );

    HistoryService.instance.addNest(entry);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hasil Nest berhasil disimpan ke riwayat'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF16A34A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NestViewModel>();

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [_BackButton()]),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                controller: _mainScrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Konsep Nest',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Konsep Nest membandingkan harga ',
                          ),
                          TextSpan(
                            text: 'Pembukaan (Open) hari ini ',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: context.textPrimary,
                            ),
                          ),
                          const TextSpan(text: 'dengan harga '),
                          TextSpan(
                            text: 'Penutupan (Close) kemarin ',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: context.textPrimary,
                            ),
                          ),
                          const TextSpan(
                            text:
                                'untuk menentukan aksi beli dan jual secara ringkas.\n\n',
                          ),
                          const TextSpan(
                            text: '\u2022  Open < Close  \u2192  ',
                          ),
                          const TextSpan(
                            text: 'BUY\n',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                          const TextSpan(
                            text: '\u2022  Open > Close  \u2192  ',
                          ),
                          const TextSpan(
                            text: 'SELL',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      height: 44,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: context.isDarkMode
                            ? AppColors.darkSurface
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          // 👇 Warna kotak aktif disesuaikan biar gak nyaru sama background
                          color: context.isDarkMode ? AppColors.darkBorder : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            // 👇 Shadow dimatikan pas mode gelap
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
                        tabs: const [
                          Tab(text: 'Manual'),
                          Tab(text: 'Data Historis'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    _isManual
                        ? Container(
                            decoration: BoxDecoration(
                              color: context.cardBg,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: context.borderColor),
                              boxShadow: [
                                // 👇 Shadow container input dimatikan pas mode gelap
                                if (!context.isDarkMode)
                                  BoxShadow(
                                    color: Colors.black.withAlpha(8),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: _buildManualInputs(context),
                            ),
                          )
                        : NewsmakerTableWidget(
                            histories: viewModel.newsmakerHistories,
                            selectedSymbol: viewModel.selectedNewsmakerSymbol,
                            isLoading: viewModel.isLoading,
                            currentPage: viewModel.currentPage,
                            isFetchingMore: viewModel.isFetchingMore,
                            hasMoreData: viewModel.hasMoreData,
                            onChangeSymbol: viewModel.changeNewsmakerSymbol,
                            onNextPage: viewModel.nextPage,
                            onPrevPage: viewModel.previousPage,
                          ),

                    if (_isManual) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: viewModel.isLoading
                              ? null
                              : () => _calculate(viewModel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: viewModel.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'HITUNG NEST',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                        ),
                      ),
                    ],

                    if (viewModel.result != null) ...[
                      const SizedBox(height: 24),
                      _buildResults(context, viewModel),
                    ],

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

  Widget _buildManualInputs(BuildContext context) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 8.0,
          children: [
            ActionChip(
              label: const Text('Gold', style: TextStyle(fontSize: 11)),
              onPressed: () {
                final data = context.read<NestViewModel>().getLatestDataFor('Gold');
                if (data != null) {
                  setState(() {
                    closeController.text = data.close.toStringAsFixed(2);
                  });
                }
              },
            ),
            ActionChip(
              label: const Text('Hang Seng', style: TextStyle(fontSize: 11)),
              onPressed: () {
                final data = context.read<NestViewModel>().getLatestDataFor('Hang Seng');
                if (data != null) {
                  setState(() {
                    closeController.text = data.close.toStringAsFixed(2);
                  });
                }
              },
            ),
            ActionChip(
              label: const Text('Nikkei', style: TextStyle(fontSize: 11)),
              onPressed: () {
                final data = context.read<NestViewModel>().getLatestDataFor('Nikkei');
                if (data != null) {
                  setState(() {
                    closeController.text = data.close.toStringAsFixed(2);
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        _inputField(
          context: context,
          label: 'CLOSE (KEMARIN)',
          hint: '',
          controller: closeController,
        ),
        const SizedBox(height: 20),
        _inputField(
          context: context,
          label: 'OPEN (HARI INI)',
          hint: '',
          controller: opController,
        ),
      ],
    );
  }

  Widget _inputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: context.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        Container(
          // 👇 const dihapus, border bottom pakai warna dinamis
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: context.borderColor, width: 1.5),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
            ],
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: context.textMuted,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults(BuildContext context, NestViewModel viewModel) {
    final data = viewModel.result!;
    final rec = data.recommendation;
    final signalColor = _signalColor(rec);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RepaintBoundary(
          key: _resultKey,
          child: Container(
            color: context.scaffoldBg,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? AppColors.darkSurface
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(14),
                  border: context.isDarkMode
                      ? Border.all(color: context.borderColor)
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Open (Hari Ini)',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatNumber(data.openingPrice),
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
                  color: context.isDarkMode
                      ? AppColors.darkSurface
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(14),
                  border: context.isDarkMode
                      ? Border.all(color: context.borderColor)
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Close (Kemarin)',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatNumber(data.close),
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
        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: signalColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'REKOMENDASI ACTION',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                rec,
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
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: context.isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'Konsep Nest membandingkan harga '),
                      TextSpan(
                        text: 'Pembukaan (Open) hari ini ',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                      const TextSpan(text: 'dengan harga '),
                      TextSpan(
                        text: 'Penutupan (Close) kemarin ',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                      const TextSpan(
                        text: 'untuk menentukan aksi beli dan jual secara ringkas.\n\n',
                      ),
                      const TextSpan(text: '\u2022  Open < Close  \u2192  '),
                      const TextSpan(
                        text: 'BUY\n',
                        style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF16A34A)),
                      ),
                      const TextSpan(text: '\u2022  Open > Close  \u2192  '),
                      const TextSpan(
                        text: 'SELL',
                        style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFDC2626)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => _saveToHistory(viewModel),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.textPrimary,
              side: BorderSide(color: context.borderColor),
              backgroundColor: context.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_rounded, size: 18),
                SizedBox(width: 8),
                Text(
                  'Simpan ke Riwayat',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () async {
              final success = await ImageCaptureService.captureAndSave(_resultKey, "Nest");
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? 'Gambar berhasil disimpan ke galeri' : 'Gagal menyimpan gambar'),
                  backgroundColor: success ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.image_outlined, size: 18),
            label: const Text(
              'Simpan sebagai Gambar',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
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