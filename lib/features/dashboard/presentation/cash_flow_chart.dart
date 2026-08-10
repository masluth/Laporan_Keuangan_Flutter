import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../transactions/providers/transaction_provider.dart';

class CashFlowChart extends ConsumerWidget {
  final bool isDarkTheme;

  const CashFlowChart({
    super.key,
    this.isDarkTheme = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // =========================================================
    // AMBIL TRANSAKSI SECARA REAL-TIME
    // =========================================================

    final transactions = ref.watch(transactionProvider);

    // =========================================================
    // WARNA
    // =========================================================

    final cardBg =
        isDarkTheme ? AppColors.darkSlateCard : Colors.white;

    final borderColor =
        isDarkTheme ? AppColors.darkSlateBorder : AppColors.lightBorder;

    // Income dibuat hijau agar lebih mudah dibaca.
    final incomeColor = AppColors.incomeGreen;

    // Expense dibuat merah agar langsung terbaca sebagai pengeluaran.
    final expenseColor = AppColors.expenseRed;

    // =========================================================
    // SIAPKAN DATA CHART
    // =========================================================

    final chartData = _buildChartData(transactions);

    final incomeSpots = chartData.incomeSpots;
    final expenseSpots = chartData.expenseSpots;
    final labels = chartData.labels;

    // Cari nilai terbesar untuk menentukan tinggi Y secara otomatis.
    final maxValue = _getMaxValue(
      incomeSpots,
      expenseSpots,
    );

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =====================================================
          // HEADER
          // =====================================================

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CASH FLOW TREND',
                style: GoogleFonts.inter(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isDarkTheme
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),

              Row(
                children: [
                  _buildLegendDot(
                    incomeColor,
                    'Income',
                  ),
                  const SizedBox(width: 12),
                  _buildLegendDot(
                    expenseColor,
                    'Expense',
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20.0),

          // =====================================================
          // CHART
          // =====================================================

          SizedBox(
            height: 160.0,
            child: transactions.isEmpty
                ? _buildEmptyChart()
                : LineChart(
                    LineChartData(
                      // -------------------------------------------------
                      // GRID
                      // -------------------------------------------------

                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval:
                            _getHorizontalInterval(maxValue),
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: isDarkTheme
                                ? AppColors.darkSlateBorder
                                : AppColors.lightBorder,
                            strokeWidth: 0.8,
                          );
                        },
                      ),

                      // -------------------------------------------------
                      // TITLES
                      // -------------------------------------------------

                      titlesData: FlTitlesData(
                        show: true,

                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),

                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),

                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),

                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();

                              if (index < 0 ||
                                  index >= labels.length) {
                                return const SizedBox.shrink();
                              }

                              return Padding(
                                padding:
                                    const EdgeInsets.only(
                                  top: 8.0,
                                ),
                                child: Text(
                                  labels[index],
                                  style: TextStyle(
                                    color: isDarkTheme
                                        ? AppColors.textMutedDark
                                        : AppColors
                                            .textMutedLight,
                                    fontSize: 9.0,
                                    fontWeight:
                                        FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // -------------------------------------------------
                      // BORDER
                      // -------------------------------------------------

                      borderData: FlBorderData(
                        show: false,
                      ),

                      // -------------------------------------------------
                      // RANGE
                      // -------------------------------------------------

                      minX: 0,
                      maxX: 6,
                      minY: 0,
                      maxY: maxValue,

                      // -------------------------------------------------
                      // TOUCH
                      // -------------------------------------------------

                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData:
                            LineTouchTooltipData(
                          getTooltipColor: (_) {
                            return isDarkTheme
                                ? AppColors.darkNavyBg
                                : Colors.white;
                          },
                          getTooltipItems:
                              (touchedSpots) {
                            return touchedSpots.map(
                              (spot) {
                                final isIncome =
                                    spot.barIndex == 0;

                                return LineTooltipItem(
                                  '${isIncome ? 'Income' : 'Expense'}\n'
                                  '${_formatCurrency(spot.y)}',
                                  TextStyle(
                                    color: isIncome
                                        ? incomeColor
                                        : expenseColor,
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                );
                              },
                            ).toList();
                          },
                        ),
                      ),

                      // -------------------------------------------------
                      // LINES
                      // -------------------------------------------------

                      lineBarsData: [
                        // =================================================
                        // INCOME
                        // =================================================

                        LineChartBarData(
                          spots: incomeSpots,
                          isCurved: true,
                          curveSmoothness: 0.25,
                          color: incomeColor,
                          barWidth: 3,
                          isStrokeCapRound: true,

                          dotData: const FlDotData(
                            show: false,
                          ),

                          belowBarData: BarAreaData(
                            show: true,
                            color: incomeColor.withValues(
                              alpha: 0.12,
                            ),
                          ),
                        ),

                        // =================================================
                        // EXPENSE
                        // =================================================

                        LineChartBarData(
                          spots: expenseSpots,
                          isCurved: true,
                          curveSmoothness: 0.25,
                          color: expenseColor,
                          barWidth: 3,
                          isStrokeCapRound: true,

                          dotData: const FlDotData(
                            show: false,
                          ),

                          belowBarData: BarAreaData(
                            show: true,
                            color: expenseColor.withValues(
                              alpha: 0.08,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // BUILD CHART DATA
  // =============================================================

  _ChartData _buildChartData(
    List transactions,
  ) {
    // Kalau tidak ada transaksi
    if (transactions.isEmpty) {
      return _ChartData(
        incomeSpots: const [
          FlSpot(0, 0),
          FlSpot(1, 0),
          FlSpot(2, 0),
          FlSpot(3, 0),
          FlSpot(4, 0),
          FlSpot(5, 0),
          FlSpot(6, 0),
        ],
        expenseSpots: const [
          FlSpot(0, 0),
          FlSpot(1, 0),
          FlSpot(2, 0),
          FlSpot(3, 0),
          FlSpot(4, 0),
          FlSpot(5, 0),
          FlSpot(6, 0),
        ],
        labels: const [
          '',
          '',
          '',
          '',
          '',
          '',
          '',
        ],
      );
    }

    // =========================================================
    // PARSE SEMUA TANGGAL TRANSAKSI
    // =========================================================

    final parsedDates = transactions
        .map((transaction) {
          final date = _parseDate(transaction.date);

          if (date == null) {
            return null;
          }

          return DateTime(
            date.year,
            date.month,
            date.day,
          );
        })
        .whereType<DateTime>()
        .toList();

    // Kalau semua tanggal gagal diparse
    if (parsedDates.isEmpty) {
      return _ChartData(
        incomeSpots: List.generate(
          7,
          (index) => FlSpot(index.toDouble(), 0),
        ),
        expenseSpots: List.generate(
          7,
          (index) => FlSpot(index.toDouble(), 0),
        ),
        labels: List.generate(
          7,
          (_) => '',
        ),
      );
    }

    // =========================================================
    // CARI TANGGAL TERBARU
    // =========================================================

    parsedDates.sort();

    final latestDate = parsedDates.last;

    // Chart menggunakan 7 hari terakhir
    final startDate = latestDate.subtract(
      const Duration(days: 6),
    );

    // =========================================================
    // GROUP DATA PER HARI
    // =========================================================

    final incomeByDay = <DateTime, double>{};
    final expenseByDay = <DateTime, double>{};

    for (final transaction in transactions) {
      final parsedDate =
          _parseDate(transaction.date);

      if (parsedDate == null) {
        continue;
      }

      final date = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
      );

      // Hanya ambil 7 hari terakhir
      if (date.isBefore(startDate) ||
          date.isAfter(latestDate)) {
        continue;
      }

      if (transaction.isExpense) {
        expenseByDay[date] =
            (expenseByDay[date] ?? 0) +
                transaction.amount;
      } else {
        incomeByDay[date] =
            (incomeByDay[date] ?? 0) +
                transaction.amount;
      }
    }

    // =========================================================
    // BUAT SPOT
    // =========================================================

    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];
    final labels = <String>[];

    final dateFormatter = DateFormat(
      'dd MMM',
      'id_ID',
    );

    for (int i = 0; i < 7; i++) {
      final date = startDate.add(
        Duration(days: i),
      );

      final income =
          incomeByDay[date] ?? 0;

      final expense =
          expenseByDay[date] ?? 0;

      incomeSpots.add(
        FlSpot(
          i.toDouble(),
          income,
        ),
      );

      expenseSpots.add(
        FlSpot(
          i.toDouble(),
          expense,
        ),
      );

      labels.add(
        dateFormatter.format(date),
      );
    }

    return _ChartData(
      incomeSpots: incomeSpots,
      expenseSpots: expenseSpots,
      labels: labels,
    );
  }

  // =============================================================
  // PARSE DATE
  // =============================================================

  DateTime? _parseDate(String value) {
    // Format ISO dari Supabase
    final isoDate = DateTime.tryParse(value);

    if (isoDate != null) {
      return isoDate;
    }

    // Format seperti:
    // 24 Oct 2023
    // 24 Oktober 2023

    final formats = [
      'dd MMM yyyy',
      'dd MMMM yyyy',
      'dd-MM-yyyy',
      'dd/MM/yyyy',
      'yyyy-MM-dd',
    ];

    for (final format in formats) {
      try {
        return DateFormat(
          format,
          'id_ID',
        ).parse(value);
      } catch (_) {
        // Coba format berikutnya
      }
    }

    return null;
  }

  // =============================================================
  // MAX VALUE
  // =============================================================

  double _getMaxValue(
    List<FlSpot> income,
    List<FlSpot> expense,
  ) {
    double maxValue = 0;

    for (final spot in income) {
      if (spot.y > maxValue) {
        maxValue = spot.y;
      }
    }

    for (final spot in expense) {
      if (spot.y > maxValue) {
        maxValue = spot.y;
      }
    }

    // Kalau nilainya kecil
    if (maxValue <= 0) {
      return 100;
    }

    // Tambahkan ruang 20% di atas grafik
    final calculatedMax = maxValue * 1.2;

    return calculatedMax;
  }

  // =============================================================
  // GRID INTERVAL
  // =============================================================

  double _getHorizontalInterval(
    double maxValue,
  ) {
    if (maxValue <= 100) {
      return 20;
    }

    if (maxValue <= 1000) {
      return 200;
    }

    if (maxValue <= 10000) {
      return 2000;
    }

    if (maxValue <= 100000) {
      return 20000;
    }

    if (maxValue <= 1000000) {
      return 200000;
    }

    if (maxValue <= 10000000) {
      return 2000000;
    }

    return maxValue / 5;
  }

  // =============================================================
  // EMPTY CHART
  // =============================================================

  Widget _buildEmptyChart() {
    return Center(
      child: Text(
        'Belum ada data transaksi',
        style: GoogleFonts.inter(
          fontSize: 12,
          color: isDarkTheme
              ? AppColors.textMutedDark
              : AppColors.textMutedLight,
        ),
      ),
    );
  }

  // =============================================================
  // LEGEND
  // =============================================================

  Widget _buildLegendDot(
    Color color,
    String label,
  ) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: isDarkTheme
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontSize: 11.0,
          ),
        ),
      ],
    );
  }

  // =============================================================
  // FORMAT CURRENCY
  // =============================================================

  String _formatCurrency(
    double value,
  ) {
    if (value >= 1000000000) {
      return 'Rp ${(value / 1000000000).toStringAsFixed(1)} M';
    }

    if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)} jt';
    }

    if (value >= 1000) {
      return 'Rp ${(value / 1000).toStringAsFixed(0)} rb';
    }

    return 'Rp ${value.toStringAsFixed(0)}';
  }
}

// ===============================================================
// CHART DATA MODEL
// ===============================================================

class _ChartData {
  final List<FlSpot> incomeSpots;
  final List<FlSpot> expenseSpots;
  final List<String> labels;

  const _ChartData({
    required this.incomeSpots,
    required this.expenseSpots,
    required this.labels,
  });
}