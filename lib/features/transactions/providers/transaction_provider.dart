import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/status_chip.dart';
import '../data/transaction_model.dart';
import '../data/transaction_repository.dart';

// =========================================================
// TRANSACTION REPOSITORY PROVIDER
// =========================================================

final transactionRepositoryProvider =
    Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

// =========================================================
// TRANSACTION NOTIFIER
// =========================================================

class TransactionNotifier
    extends StateNotifier<List<TransactionModel>> {
  final TransactionRepository _repository;

  TransactionNotifier(this._repository)
      : super(const []) {
    loadTransactions();
  }

  // =========================================================
  // READ
  // =========================================================

  Future<void> loadTransactions() async {
    try {
      final transactions =
          await _repository.getTransactions();

      // Jangan update state kalau notifier
      // sudah tidak digunakan lagi.
      if (!mounted) return;

      state = transactions;
    } catch (e) {
      if (!mounted) return;

      state = const [];

      debugPrint(
        'Gagal mengambil transaksi dari Supabase: $e',
      );
    }
  }

  // =========================================================
  // CLEAR STATE
  // =========================================================

  void clearTransactions() {
    state = const [];
  }

  // =========================================================
  // CREATE
  // =========================================================

  Future<void> addTransaction(
    TransactionModel item,
  ) async {
    await _repository.addTransaction(item);

    if (!mounted) return;

    state = [
      item,
      ...state,
    ];
  }

  // =========================================================
  // UPDATE
  // =========================================================

  Future<void> updateTransaction(
    TransactionModel item,
  ) async {
    await _repository.updateTransaction(item);

    if (!mounted) return;

    state = state.map((transaction) {
      if (transaction.id == item.id) {
        return item;
      }

      return transaction;
    }).toList();
  }

  // =========================================================
  // DELETE
  // =========================================================

  Future<void> deleteTransaction(
    String id,
  ) async {
    await _repository.deleteTransaction(id);

    if (!mounted) return;

    state = state
        .where(
          (transaction) =>
              transaction.id != id,
        )
        .toList();
  }

  // =========================================================
  // TOTAL INCOME
  // =========================================================

  double get totalIncome {
    return state
        .where((t) => !t.isExpense)
        .fold(
          0.0,
          (sum, t) => sum + t.amount,
        );
  }

  // =========================================================
  // TOTAL EXPENSE
  // =========================================================

  double get totalExpense {
    return state
        .where((t) => t.isExpense)
        .fold(
          0.0,
          (sum, t) => sum + t.amount,
        );
  }

  // =========================================================
  // TOTAL PIUTANG
  // =========================================================

  double get totalPiutang {
    return state
        .where(
          (t) =>
              t.status ==
              TransactionStatus.belumLunas,
        )
        .fold(
          0.0,
          (sum, t) => sum + t.amount,
        );
  }
}

// =========================================================
// TRANSACTION PROVIDER
// =========================================================

final transactionProvider = StateNotifierProvider<
    TransactionNotifier,
    List<TransactionModel>>(
  (ref) {
    final repository =
        ref.watch(transactionRepositoryProvider);

    return TransactionNotifier(repository);
  },
);