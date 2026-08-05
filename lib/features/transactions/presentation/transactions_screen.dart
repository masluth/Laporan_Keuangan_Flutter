import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/transaction_tile.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_sheet.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  final List<String> _filters = ['Semua', 'Lunas', 'Belum Lunas', 'Pemasukan', 'Pengeluaran'];

  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Filter logic
    final filteredTransactions = transactions.where((t) {
      final matchesSearch = t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.category.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      if (_selectedFilter == 'Lunas') return t.status == TransactionStatus.lunas;
      if (_selectedFilter == 'Belum Lunas') return t.status == TransactionStatus.belumLunas;
      if (_selectedFilter == 'Pemasukan') return !t.isExpense;
      if (_selectedFilter == 'Pengeluaran') return t.isExpense;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        title: Text(
          'Transactions',
          style: AppTextStyles.headlineMedium(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primaryBlue),
            onPressed: () => _showAddTransactionSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Column(
              children: [
                // Search Field
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Cari transaksi...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondaryLight),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: AppColors.lightBorder),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),

                // Filter Chips List
                SizedBox(
                  height: 36.0,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8.0),
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = _selectedFilter == filter;
                      return ChoiceChip(
                        label: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textSecondaryLight,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primaryBlue,
                        backgroundColor: Colors.white,
                        onSelected: (val) => setState(() => _selectedFilter = filter),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(
                            color: isSelected ? AppColors.primaryBlue : AppColors.lightBorder,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),

          // Transactions List
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 56.0, color: AppColors.textMutedLight),
                        const SizedBox(height: 12.0),
                        Text(
                          'Tidak ada transaksi ditemukan',
                          style: AppTextStyles.bodyMedium(color: AppColors.textMutedLight),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final item = filteredTransactions[index];
                      return TransactionTile(
                        title: item.title,
                        date: item.date,
                        amount: currencyFormat.format(item.amount),
                        isExpense: item.isExpense,
                        status: item.status,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionSheet(context),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
