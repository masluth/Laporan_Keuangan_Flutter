import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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

  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final transactions = ref.watch(transactionProvider);

    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final double incomeSum = transactions.where((t) => !t.isExpense).fold(0, (s, t) => s + t.amount);
    final double expenseSum = transactions.where((t) => t.isExpense).fold(0, (s, t) => s + t.amount);
    final double piutangSum = transactions.where((t) => t.status.name == 'belumLunas').fold(0, (s, t) => s + t.amount);

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkNavyBg,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primaryBlue, size: 20.0),
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
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dark Header Hero Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 24.0),
              decoration: const BoxDecoration(
                color: AppColors.darkNavyBg,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.0),
                  bottomRight: Radius.circular(24.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GOOD MORNING,',
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: AppColors.secondaryIndigo,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    (authState.userName ?? 'Alex Thompson').toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Cash Flow Chart inside Dark Header Hero
                  const CashFlowChart(isDarkTheme: true),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Operational Overview',
                    style: AppTextStyles.headlineMedium(),
                  ),
                  const SizedBox(height: 14.0),

                  // 2x2 Grid of Financial Summary Cards
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 1.45,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      FinancialCard(
                        title: 'Total Income',
                        value: 'Rp ${(incomeSum / 1000000).toStringAsFixed(1)}M',
                        icon: Icons.trending_up_rounded,
                        iconColor: AppColors.incomeGreen,
                        iconBgColor: AppColors.incomeGreenBg,
                        subtitle: '+12% bulan ini',
                      ),
                      FinancialCard(
                        title: 'Total Expense',
                        value: 'Rp ${(expenseSum / 1000000).toStringAsFixed(1)}M',
                        icon: Icons.trending_down_rounded,
                        iconColor: AppColors.expenseRed,
                        iconBgColor: AppColors.expenseRedBg,
                        subtitle: '-4% bulan ini',
                      ),
                      FinancialCard(
                        title: 'Total Piutang',
                        value: 'Rp ${(piutangSum / 1000000).toStringAsFixed(1)}M',
                        icon: Icons.account_balance_outlined,
                        iconColor: AppColors.debtAmber,
                        iconBgColor: AppColors.debtAmberBg,
                        subtitle: '2 tagihan aktif',
                      ),
                      FinancialCard(
                        title: 'Transactions',
                        value: '${transactions.length}',
                        icon: Icons.receipt_long_rounded,
                        iconColor: AppColors.primaryBlue,
                        iconBgColor: const Color(0xFFEFF6FF),
                        subtitle: 'Bulan Oktober',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28.0),

                  // Recent Transactions Header & Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: AppTextStyles.headlineMedium(),
                      ),
                      TextButton(
                        onPressed: () => context.go('/transactions'),
                        child: Text(
                          'Lihat Semua',
                          style: GoogleFonts.inter(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),

                  // Transactions List (Top 5)
                  ListView.builder(
                    itemCount: transactions.length > 5 ? 5 : transactions.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = transactions[index];
                      return TransactionTile(
                        title: item.title,
                        date: item.date,
                        amount: currencyFormat.format(item.amount),
                        isExpense: item.isExpense,
                        status: item.status,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionSheet(context),
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Tambah Transaksi',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
