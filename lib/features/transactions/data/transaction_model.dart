import '../../../shared/widgets/status_chip.dart';

class TransactionModel {
  final String id;
  final String title;
  final String date;
  final double amount;
  final bool isExpense;
  final TransactionStatus status;
  final String category;

  TransactionModel({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.isExpense,
    required this.status,
    this.category = 'Umum',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'amount': amount,
      'isExpense': isExpense,
      'status': status == TransactionStatus.lunas ? 'Lunas' : 'Belum Lunas',
      'category': category,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, String docId) {
    return TransactionModel(
      id: docId,
      title: map['title'] ?? 'Transaksi',
      date: map['date'] ?? 'Hari ini',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      isExpense: map['isExpense'] ?? false,
      status: map['status'] == 'Lunas' ? TransactionStatus.lunas : TransactionStatus.belumLunas,
      category: map['category'] ?? 'Umum',
    );
  }
}
