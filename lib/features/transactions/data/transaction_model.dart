import '../../../shared/widgets/status_chip.dart';

class TransactionModel {
  final String id;
  final String userId;
  final String title;
  final String date;
  final double amount;
  final bool isExpense;
  final TransactionStatus status;
  final String category;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.date,
    required this.amount,
    required this.isExpense,
    required this.status,
    this.category = 'Umum',
  });

  // Convert model ke format yang sesuai dengan kolom Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'date': date,
      'amount': amount,
      'is_expense': isExpense,
      'status': status == TransactionStatus.lunas
          ? 'Lunas'
          : 'Belum Lunas',
      'category': category,
    };
  }

  // Convert data dari Supabase ke TransactionModel
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Transaksi',
      date: map['date']?.toString() ?? 'Hari ini',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      isExpense: map['is_expense'] as bool? ?? false,
      status: map['status'] == 'Lunas'
          ? TransactionStatus.lunas
          : TransactionStatus.belumLunas,
      category: map['category']?.toString() ?? 'Umum',
    );
  }
}