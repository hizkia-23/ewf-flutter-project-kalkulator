import 'package:flutter/material.dart';
import '../../domain/entities/market_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class NewsmakerTableWidget extends StatefulWidget {
  // ── PARAMETER DINAMIS ──
  final List<MarketData> histories;
  final String selectedSymbol;
  final bool isLoading;
  final int currentPage;
  final bool isFetchingMore;
  final bool hasMoreData;
  final void Function(String) onChangeSymbol;
  
  // Dibuat nullable agar kolom Aksi bisa disembunyikan (misal: di halaman Nest)
  final void Function(MarketData)? onCalculate; 
  
  final VoidCallback onNextPage;
  final VoidCallback onPrevPage;

  const NewsmakerTableWidget({
    super.key,
    required this.histories,
    required this.selectedSymbol,
    required this.isLoading,
    required this.currentPage,
    required this.isFetchingMore,
    required this.hasMoreData,
    required this.onChangeSymbol,
    this.onCalculate, // Hapus 'required'
    required this.onNextPage,
    required this.onPrevPage,
  });

  @override
  State<NewsmakerTableWidget> createState() => _NewsmakerTableWidgetState();
}

class _NewsmakerTableWidgetState extends State<NewsmakerTableWidget> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildHeaderCell(String text, BuildContext context, {double width = 80}) {
    return Container(
      width: width,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: context.textSecondary,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, BuildContext context, {double width = 80, bool isBold = false}) {
    return Container(
      width: width,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          color: context.textPrimary, 
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final symbols = ['Gold', 'Hang Seng', 'Nikkei'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── CHIP FILTER INSTRUMEN ──
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: symbols.map((sym) {
              final isSelected = widget.selectedSymbol == sym;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(sym),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      widget.onChangeSymbol(sym);
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(0);
                      }
                    }
                  },
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  backgroundColor: context.chipBg, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : context.borderColor, 
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : context.textSecondary, 
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // ── TABEL DATA HISTORIS (PAGINATED) ──
        if (widget.histories.isEmpty && widget.isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Memuat data historis...',
                    style: TextStyle(color: context.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          )
        else if (widget.histories.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Belum ada data historis',
                style: TextStyle(color: context.textSecondary),
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.cardBg, 
              borderRadius: BorderRadius.circular(16),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: 650, 
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        color: context.isDarkMode 
                            ? Colors.white.withAlpha(10) 
                            : const Color(0xFFF8FAFC),
                        child: Row(
                          children: [
                            _buildHeaderCell('Tanggal', context, width: 120),
                            _buildHeaderCell('High', context, width: 85),
                            _buildHeaderCell('Low', context, width: 85),
                            _buildHeaderCell('Close', context, width: 85),
                            _buildHeaderCell('Open', context, width: 85),
                            // Sembunyikan Header Aksi jika onCalculate null
                            if (widget.onCalculate != null)
                              _buildHeaderCell('Aksi', context, width: 110),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      
                      Container(
                        constraints: const BoxConstraints(maxHeight: 400),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: widget.histories.length,
                          itemBuilder: (context, index) {
                            final data = widget.histories[index];
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: context.dividerColor), 
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildDataCell(data.date, context, width: 120, isBold: true),
                                  _buildDataCell(data.high.toStringAsFixed(2), context, width: 85),
                                  _buildDataCell(data.low.toStringAsFixed(2), context, width: 85),
                                  _buildDataCell(data.close.toStringAsFixed(2), context, width: 85),
                                  _buildDataCell(data.open.toStringAsFixed(2), context, width: 85),
                                  
                                  // Sembunyikan Tombol Hitung jika onCalculate null
                                  if (widget.onCalculate != null)
                                    Container(
                                      width: 110,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: ElevatedButton(
                                        onPressed: () => widget.onCalculate!(data),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          'Hitung',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
        if (widget.histories.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: widget.currentPage > 1 && !widget.isFetchingMore 
                    ? widget.onPrevPage 
                    : null,
                icon: const Icon(Icons.chevron_left, size: 20),
                label: const Text('Sebelumnya', style: TextStyle(fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  disabledForegroundColor: Colors.grey,
                ),
              ),
              if (widget.isFetchingMore)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Text(
                  'Halaman ${widget.currentPage}',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                ),
              TextButton(
                onPressed: widget.hasMoreData && !widget.isFetchingMore 
                    ? widget.onNextPage 
                    : null,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  disabledForegroundColor: Colors.grey,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Selanjutnya', style: TextStyle(fontWeight: FontWeight.bold)),
                    Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}