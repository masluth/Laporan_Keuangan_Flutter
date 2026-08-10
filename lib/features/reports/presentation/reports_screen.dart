import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/status_chip.dart';

import '../../transactions/data/transaction_model.dart';
import '../../transactions/providers/transaction_provider.dart';

import 'export_report_sheet.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  void _showExportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ExportReportSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);

    // =========================
    // FINANCIAL CALCULATION
    // =========================

    final totalIncome = transactions
        .where((t) => !t.isExpense)
        .fold<double>(
          0,
          (sum, t) => sum + t.amount,
        );

    final totalExpense = transactions
        .where((t) => t.isExpense)
        .fold<double>(
          0,
          (sum, t) => sum + t.amount,
        );

    final balance = totalIncome - totalExpense;

    // =========================
    // PROFIT MARGIN
    // =========================

    final profitMargin = totalIncome > 0
        ? ((totalIncome - totalExpense) / totalIncome) * 100
        : 0.0;

    // =========================
    // HEALTH SCORE
    // =========================

    double healthScore = 0;

    if (totalIncome > 0) {
      if (profitMargin >= 70) {
        healthScore = 95;
      } else if (profitMargin >= 50) {
        healthScore = 85;
      } else if (profitMargin >= 30) {
        healthScore = 75;
      } else if (profitMargin > 0) {
        healthScore = 60;
      } else {
        healthScore = 30;
      }
    }

    // =========================
    // CATEGORY BREAKDOWN
    // =========================

    final Map<String, double> categoryTotals = {};

    for (final transaction in transactions) {
      if (!transaction.isExpense) continue;

      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0) +
              transaction.amount;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(a.value),
      );

    return Scaffold(
      backgroundColor: AppColors.lightBg,

      // =========================
      // APP BAR
      // =========================

      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        title: Text(
          'Reports',
          style: AppTextStyles.headlineMedium(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.file_download_outlined,
              color: AppColors.primaryBlue,
            ),
            onPressed: () => _showExportSheet(context),
          ),
        ],
      ),

      // =========================
      // BODY
      // =========================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // EXPORT BANNER
            // =========================

            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primaryBlueDark,
                    AppColors.primaryBlue,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(
                      alpha: 0.3,
                    ),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export Report Data',
                          style: GoogleFonts.inter(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 6.0),

                        Text(
                          'Unduh rekap keuangan UMKM lengkap dalam format PDF & Excel.',
                          style: GoogleFonts.inter(
                            fontSize: 13.0,
                            color: Colors.white.withValues(
                              alpha: 0.85,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16.0),

                        ElevatedButton.icon(
                          onPressed: () =>
                              _showExportSheet(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor:
                                AppColors.primaryBlueDark,
                            elevation: 0,
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 10.0,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                10.0,
                              ),
                            ),
                          ),
                          icon: const Icon(
                            Icons.download_rounded,
                            size: 18.0,
                          ),
                          label: Text(
                            'Export Report',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12.0),

                  const Icon(
                    Icons.assessment_rounded,
                    size: 64.0,
                    color: Colors.white24,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28.0),

            // =========================
            // OVERVIEW TITLE
            // =========================

            Text(
              'Recent Reports Overview',
              style: AppTextStyles.headlineMedium(),
            ),

            const SizedBox(height: 14.0),

            // =========================
            // METRIC CARDS
            // =========================

            Row(
              children: [
                Expanded(
                  child: _buildReportMetricCard(
                    title: 'Health Score',
                    value:
                        '${healthScore.toStringAsFixed(0)}%',
                    trend: _getHealthStatus(healthScore),
                    icon: Icons.favorite_rounded,
                    color: AppColors.incomeGreen,
                  ),
                ),

                const SizedBox(width: 12.0),

                Expanded(
                  child: _buildReportMetricCard(
                    title: 'Profit Margin',
                    value:
                        '${profitMargin.toStringAsFixed(1)}%',
                    trend: profitMargin >= 0
                        ? 'Margin keuntungan'
                        : 'Mengalami kerugian',
                    icon: Icons.pie_chart_rounded,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24.0),

            // =========================
            // SUMMARY
            // =========================

            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringkasan Keuangan',
                    style: GoogleFonts.inter(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color:
                          AppColors.textPrimaryLight,
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  _buildSummaryRow(
                    'Total Pemasukan',
                    totalIncome,
                    AppColors.incomeGreen,
                  ),

                  const SizedBox(height: 12.0),

                  _buildSummaryRow(
                    'Total Pengeluaran',
                    totalExpense,
                    AppColors.expenseRed,
                  ),

                  const SizedBox(height: 12.0),

                  const Divider(),

                  const SizedBox(height: 12.0),

                  _buildSummaryRow(
                    'Saldo Bersih',
                    balance,
                    balance >= 0
                        ? AppColors.primaryBlue
                        : AppColors.expenseRed,
                  ),

                  const SizedBox(height: 12.0),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jumlah Transaksi',
                        style: GoogleFonts.inter(
                          fontSize: 13.0,
                          color: AppColors
                              .textSecondaryLight,
                        ),
                      ),
                      Text(
                        '${transactions.length}',
                        style: GoogleFonts.inter(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color:
                              AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24.0),

            // =========================
            // CATEGORY BREAKDOWN
            // =========================

            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alokasi Pengeluaran',
                    style: GoogleFonts.inter(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color:
                          AppColors.textPrimaryLight,
                    ),
                  ),

                  const SizedBox(height: 6.0),

                  Text(
                    'Distribusi pengeluaran berdasarkan kategori transaksi.',
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      color:
                          AppColors.textSecondaryLight,
                    ),
                  ),

                  const SizedBox(height: 18.0),

                  if (sortedCategories.isEmpty)
                    _buildEmptyCategoryState()
                  else
                    ...sortedCategories.map(
                      (entry) {
                        final percentage =
                            totalExpense > 0
                                ? entry.value /
                                    totalExpense
                                : 0.0;

                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 14.0,
                          ),
                          child: _buildProgressItem(
                            entry.key,
                            percentage,
                            entry.value,
                            _getCategoryColor(
                              entry.key,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24.0),

            // =========================
            // TRANSACTION STATUS
            // =========================

            _buildStatusCard(transactions),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // METRIC CARD
  // =========================================================

  Widget _buildReportMetricCard({
    required String title,
    required String value,
    required String trend,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: AppTextStyles.labelMedium(),
                ),
              ),
              Icon(
                icon,
                color: color,
                size: 20.0,
              ),
            ],
          ),

          const SizedBox(height: 10.0),

          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),

          const SizedBox(height: 4.0),

          Text(
            trend,
            style: AppTextStyles.bodySmall(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SUMMARY ROW
  // =========================================================

  Widget _buildSummaryRow(
    String label,
    double amount,
    Color color,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.0,
            color: AppColors.textSecondaryLight,
          ),
        ),
        Text(
          _formatRupiah(amount),
          style: GoogleFonts.inter(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // CATEGORY PROGRESS
  // =========================================================

  Widget _buildProgressItem(
    String label,
    double percentage,
    double amount,
    Color color,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              _formatRupiah(amount),
              style: GoogleFonts.inter(
                fontSize: 13.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6.0),

        ClipRRect(
          borderRadius:
              BorderRadius.circular(4.0),
          child: LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0),
            minHeight: 8.0,
            backgroundColor:
                AppColors.lightSurfaceLow,
            valueColor:
                AlwaysStoppedAnimation(color),
          ),
        ),

        const SizedBox(height: 4.0),

        Text(
          '${(percentage * 100).toStringAsFixed(1)}%',
          style: GoogleFonts.inter(
            fontSize: 11.0,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // EMPTY CATEGORY
  // =========================================================

  Widget _buildEmptyCategoryState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 24.0,
      ),
      child: Column(
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 40.0,
            color: AppColors.textMutedLight,
          ),
          const SizedBox(height: 10.0),
          Text(
            'Belum ada data pengeluaran.',
            style: GoogleFonts.inter(
              fontSize: 13.0,
              color:
                  AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // STATUS CARD
  // =========================================================

  Widget _buildStatusCard(
    List<TransactionModel> transactions,
  ) {
    final paid = transactions
        .where(
          (t) =>
              t.status ==
              TransactionStatus.lunas,
        )
        .length;

    final unpaid = transactions
        .where(
          (t) =>
              t.status ==
              TransactionStatus.belumLunas,
        )
        .length;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Status Transaksi',
            style: GoogleFonts.inter(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),

          const SizedBox(height: 16.0),

          Row(
            children: [
              Expanded(
                child: _buildStatusItem(
                  'Lunas',
                  paid,
                  AppColors.incomeGreen,
                  AppColors.incomeGreenBg,
                ),
              ),

              const SizedBox(width: 12.0),

              Expanded(
                child: _buildStatusItem(
                  'Belum Lunas',
                  unpaid,
                  AppColors.debtAmber,
                  AppColors.debtAmberBg,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    String label,
    int count,
    Color color,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Icon(
            label == 'Lunas'
                ? Icons.check_circle_rounded
                : Icons.pending_rounded,
            color: color,
            size: 22.0,
          ),

          const SizedBox(width: 10.0),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    color: color,
                  ),
                ),
                Text(
                  '$count transaksi',
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CATEGORY COLOR
  // =========================================================

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Operasional':
        return AppColors.debtAmber;

      case 'Penjualan':
        return AppColors.primaryBlue;

      case 'Inventaris':
        return AppColors.secondaryIndigo;

      case 'Piutang':
        return AppColors.incomeGreen;

      case 'Logistik':
        return AppColors.expenseRed;

      default:
        return AppColors.textSecondaryLight;
    }
  }

  // =========================================================
  // HEALTH STATUS
  // =========================================================

  String _getHealthStatus(double score) {
    if (score >= 90) {
      return 'Sangat sehat';
    }

    if (score >= 75) {
      return 'Sehat';
    }

    if (score >= 60) {
      return 'Perlu perhatian';
    }

    return 'Perlu evaluasi';
  }

  // =========================================================
  // RUPIAH FORMAT
  // =========================================================

  String _formatRupiah(double amount) {
    final value = amount.toStringAsFixed(0);
    final chars = value.split('');

    String result = '';
    int count = 0;

    for (int i = chars.length - 1; i >= 0; i--) {
      result = chars[i] + result;
      count++;

      if (count == 3 && i != 0) {
        result = '.$result';
        count = 0;
      }
    }

    return 'Rp $result';
  }
}