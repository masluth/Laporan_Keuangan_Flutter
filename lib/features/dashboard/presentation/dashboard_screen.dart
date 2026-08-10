import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/financial_card.dart';
import '../../../shared/widgets/transaction_tile.dart';
import '../../auth/providers/auth_provider.dart';
import '../../transactions/presentation/add_transaction_sheet.dart';
import '../../transactions/providers/transaction_provider.dart';
import 'cash_flow_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  // =========================================================
  // NAMA BULAN INDONESIA
  // Tidak menggunakan DateFormat agar tidak membutuhkan
  // initializeDateFormatting().
  // =========================================================

  String _getCurrentMonthName() {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final now = DateTime.now();

    return months[now.month - 1];
  }

  // =========================================================
  // ADD TRANSACTION
  // =========================================================

  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionSheet(),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final authState = ref.watch(authProvider);
    final transactions = ref.watch(transactionProvider);

    // =======================================================
    // CURRENT MONTH
    // =======================================================

    final currentMonthName = _getCurrentMonthName();

    // =======================================================
    // FINANCIAL CALCULATION
    // =======================================================

    final double incomeSum = transactions
        .where((t) => !t.isExpense)
        .fold(
          0.0,
          (sum, t) => sum + t.amount,
        );

    final double expenseSum = transactions
        .where((t) => t.isExpense)
        .fold(
          0.0,
          (sum, t) => sum + t.amount,
        );

    final double piutangSum = transactions
        .where(
          (t) => t.status.name == 'belumLunas',
        )
        .fold(
          0.0,
          (sum, t) => sum + t.amount,
        );

    // =======================================================
    // JUMLAH PIUTANG AKTIF
    // Tidak lagi hardcode "2 tagihan aktif".
    // =======================================================

    final int activePiutangCount = transactions
        .where(
          (t) => t.status.name == 'belumLunas',
        )
        .length;

    // =======================================================
    // USER NAME
    // =======================================================

    final String displayName =
        authState.userName?.trim().isNotEmpty == true
            ? authState.userName!.trim()
            : 'User';

    return Scaffold(
      backgroundColor: AppColors.lightBg,

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        backgroundColor: AppColors.darkNavyBg,
        elevation: 0,

        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(
                  alpha: 0.2,
                ),
                borderRadius:
                    BorderRadius.circular(10.0),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: AppColors.primaryBlue,
                size: 20.0,
              ),
            ),

            const SizedBox(width: 10.0),

            Text(
              'Revenant Finance',
              style: GoogleFonts.inter(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
            onPressed: () {},
          ),

          IconButton(
            icon: const Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              context.go('/profile');
            },
          ),
        ],
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            // =================================================
            // DARK HEADER / HERO
            // =================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                20.0,
                10.0,
                20.0,
                24.0,
              ),
              decoration: const BoxDecoration(
                color: AppColors.darkNavyBg,
                borderRadius: BorderRadius.only(
                  bottomLeft:
                      Radius.circular(24.0),
                  bottomRight:
                      Radius.circular(24.0),
                ),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    'GOOD MORNING,',
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color:
                          AppColors.secondaryIndigo,
                    ),
                  ),

                  const SizedBox(height: 4.0),

                  // =================================================
                  // USER NAME DARI SUPABASE
                  // =================================================

                  Text(
                    displayName.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  // =================================================
                  // CASH FLOW CHART
                  // =================================================

                  const CashFlowChart(
                    isDarkTheme: true,
                  ),
                ],
              ),
            ),

            // =====================================================
            // MAIN CONTENT
            // =====================================================

            Padding(
              padding:
                  const EdgeInsets.all(20.0),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  // =================================================
                  // OPERATIONAL OVERVIEW
                  // =================================================

                  Text(
                    'Operational Overview',
                    style:
                        AppTextStyles.headlineMedium(),
                  ),

                  const SizedBox(height: 14.0),

                  // =================================================
                  // FINANCIAL CARDS
                  // =================================================

                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 1.45,
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),

                    children: [

                      // =================================================
                      // TOTAL INCOME
                      // =================================================

                      FinancialCard(
                        title: 'Total Income',
                        value:
                            'Rp ${(incomeSum / 1000000).toStringAsFixed(1)}M',
                        icon:
                            Icons.trending_up_rounded,
                        iconColor:
                            AppColors.incomeGreen,
                        iconBgColor:
                            AppColors.incomeGreenBg,
                        subtitle:
                            '$currentMonthName ${DateTime.now().year}',
                      ),

                      // =================================================
                      // TOTAL EXPENSE
                      // =================================================

                      FinancialCard(
                        title: 'Total Expense',
                        value:
                            'Rp ${(expenseSum / 1000000).toStringAsFixed(1)}M',
                        icon:
                            Icons.trending_down_rounded,
                        iconColor:
                            AppColors.expenseRed,
                        iconBgColor:
                            AppColors.expenseRedBg,
                        subtitle:
                            '$currentMonthName ${DateTime.now().year}',
                      ),

                      // =================================================
                      // TOTAL PIUTANG
                      // =================================================

                      FinancialCard(
                        title: 'Total Piutang',
                        value:
                            'Rp ${(piutangSum / 1000000).toStringAsFixed(1)}M',
                        icon:
                            Icons.account_balance_outlined,
                        iconColor:
                            AppColors.debtAmber,
                        iconBgColor:
                            AppColors.debtAmberBg,

                        // Dinamis berdasarkan database
                        subtitle:
                            activePiutangCount == 0
                                ? 'Tidak ada tagihan aktif'
                                : '$activePiutangCount tagihan aktif',
                      ),

                      // =================================================
                      // TOTAL TRANSACTIONS
                      // =================================================

                      FinancialCard(
                        title: 'Transactions',
                        value:
                            '${transactions.length}',
                        icon:
                            Icons.receipt_long_rounded,
                        iconColor:
                            AppColors.primaryBlue,
                        iconBgColor:
                            const Color(0xFFEFF6FF),

                        // Tidak lagi hardcode Oktober
                        subtitle:
                            '$currentMonthName ${DateTime.now().year}',
                      ),
                    ],
                  ),

                  const SizedBox(height: 28.0),

                  // =================================================
                  // RECENT TRANSACTIONS HEADER
                  // =================================================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [

                      Text(
                        'Recent Transactions',
                        style:
                            AppTextStyles.headlineMedium(),
                      ),

                      TextButton(
                        onPressed: () {
                          context.go(
                            '/transactions',
                          );
                        },
                        child: Text(
                          'Lihat Semua',
                          style: GoogleFonts.inter(
                            color:
                                AppColors.primaryBlue,
                            fontWeight:
                                FontWeight.w600,
                            fontSize: 13.0,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10.0),

                  // =================================================
                  // TRANSACTION LIST
                  // =================================================

                  if (transactions.isEmpty)

                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(16.0),
                        border: Border.all(
                          color:
                              AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        children: [

                          const Icon(
                            Icons.receipt_long_outlined,
                            size: 42,
                            color:
                                AppColors.textMutedLight,
                          ),

                          const SizedBox(height: 12.0),

                          Text(
                            'Belum ada transaksi',
                            style:
                                GoogleFonts.inter(
                              fontSize: 15.0,
                              fontWeight:
                                  FontWeight.w600,
                              color:
                                  AppColors.textPrimaryLight,
                            ),
                          ),

                          const SizedBox(height: 4.0),

                          Text(
                            'Tambahkan transaksi untuk melihatnya di sini.',
                            textAlign:
                                TextAlign.center,
                            style:
                                GoogleFonts.inter(
                              fontSize: 12.0,
                              color:
                                  AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    )

                  else

                    ListView.builder(
                      itemCount:
                          transactions.length > 5
                              ? 5
                              : transactions.length,

                      shrinkWrap: true,

                      physics:
                          const NeverScrollableScrollPhysics(),

                      itemBuilder:
                          (context, index) {

                        final item =
                            transactions[index];

                        return TransactionTile(
                          title: item.title,
                          date: item.date,
                          amount:
                              'Rp ${item.amount.toStringAsFixed(0)}',
                          isExpense:
                              item.isExpense,
                          status:
                              item.status,
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),

      // =====================================================
      // FLOATING ACTION BUTTON
      // =====================================================

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          _showAddTransactionSheet(context);
        },

        backgroundColor:
            AppColors.primaryBlue,

        icon: const Icon(
          Icons.add_rounded,
          color: Colors.white,
        ),

        label: Text(
          'Tambah Transaksi',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}