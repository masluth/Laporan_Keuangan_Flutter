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

  // =========================================================
  // TO MAP
  // =========================================================

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

  // =========================================================
  // FROM MAP
  // =========================================================

  factory TransactionModel.fromMap(
    Map<String, dynamic> map,
  ) {
    String transactionDate = '';

    final rawDate = map['date']?.toString();
    final createdAt = map['created_at']?.toString();

    // -------------------------------------------------------
    // 1. Kalau date sudah berupa tanggal valid
    // -------------------------------------------------------

    if (rawDate != null &&
        rawDate.isNotEmpty &&
        rawDate != 'Hari ini') {
      final parsedDate = DateTime.tryParse(rawDate);

      if (parsedDate != null) {
        transactionDate = _formatDate(parsedDate);
      }
    }

    // -------------------------------------------------------
    // 2. Kalau date = "Hari ini"
    //    gunakan created_at
    // -------------------------------------------------------

    if (transactionDate.isEmpty &&
        createdAt != null &&
        createdAt.isNotEmpty) {
      final parsedCreatedAt =
          DateTime.tryParse(createdAt);

      if (parsedCreatedAt != null) {
        transactionDate =
            _formatDate(parsedCreatedAt);
      }
    }

    // -------------------------------------------------------
    // 3. Fallback terakhir
    // -------------------------------------------------------

    if (transactionDate.isEmpty) {
      transactionDate = _formatDate(DateTime.now());
    }

    return TransactionModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Transaksi',
      date: transactionDate,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      isExpense:
          map['is_expense'] as bool? ?? false,
      status:
          map['status']?.toString().toLowerCase() ==
                  'lunas'
              ? TransactionStatus.lunas
              : TransactionStatus.belumLunas,
      category:
          map['category']?.toString() ?? 'Umum',
    );
  }

  // =========================================================
  // FORMAT DATE
  // =========================================================

  static String _formatDate(DateTime date) {
    final year =
        date.year.toString().padLeft(4, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    final day =
        date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}