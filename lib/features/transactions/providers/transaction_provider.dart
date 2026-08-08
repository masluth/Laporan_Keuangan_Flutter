import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/status_chip.dart';
import '../data/transaction_model.dart';
import '../data/transaction_repository.dart';

final transactionRepositoryProvider =
    Provider((ref) {
  return TransactionRepository();
});

class TransactionNotifier
    extends StateNotifier<List<TransactionModel>> {
  final TransactionRepository _repository;

  TransactionNotifier(this._repository) : super([]) {
    loadTransactions();
  }

  // =========================
  // READ
  // =========================

  Future<void> loadTransactions() async {
    try {
      final transactions =
          await _repository.getTransactions();

      state = transactions;
    } catch (e) {
      state = [];

      debugPrint(
        'Gagal mengambil transaksi dari Supabase: $e',
      );
    }
  }

  // =========================
  // CREATE
  // =========================

  Future<void> addTransaction(
    TransactionModel item,
  ) async {
    await _repository.addTransaction(item);

    state = [
      item,
      ...state,
    ];
  }

  // =========================
  // UPDATE
  // =========================

  Future<void> updateTransaction(
    TransactionModel item,
  ) async {
    await _repository.updateTransaction(item);

    state = state.map((transaction) {
      if (transaction.id == item.id) {
        return item;
      }

      return transaction;
    }).toList();
  }

  // =========================
  // DELETE
  // =========================

  Future<void> deleteTransaction(
    String id,
  ) async {
    await _repository.deleteTransaction(id);

    state = state
        .where(
          (transaction) => transaction.id != id,
        )
        .toList();
  }

  // =========================
  // TOTAL INCOME
  // =========================

  double get totalIncome {
    return state
        .where((t) => !t.isExpense)
        .fold(
          0.0,
          (sum, t) => sum + t.amount,
        );
  }

  // =========================
  // TOTAL EXPENSE
  // =========================

  double get totalExpense {
    return state
        .where((t) => t.isExpense)
        .fold(
          0.0,
          (sum, t) => sum + t.amount,
        );
  }

  // =========================
  // TOTAL PIUTANG
  // =========================

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

final transactionProvider =
    StateNotifierProvider<
      TransactionNotifier,
      List<TransactionModel>
    >(
  (ref) {
    final repo =
        ref.watch(transactionRepositoryProvider);

    return TransactionNotifier(repo);
  },
);