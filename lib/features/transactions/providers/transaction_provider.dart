import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/status_chip.dart';
import '../data/transaction_model.dart';
import '../data/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  final TransactionRepository _repository;

  TransactionNotifier(this._repository) : super([]) {
    loadTransactions();
  }

  void loadTransactions() {
    state = List.from(_repository.mockData);
  }

  Future<void> addTransaction(TransactionModel item) async {
    await _repository.addTransaction(item);
    state = [item, ...state];
  }

  double get totalIncome => state
      .where((t) => !t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => state
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalPiutang => state
      .where((t) => t.status == TransactionStatus.belumLunas)
      .fold(0.0, (sum, t) => sum + t.amount);
}

final transactionProvider = StateNotifierProvider<TransactionNotifier, List<TransactionModel>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return TransactionNotifier(repo);
});
