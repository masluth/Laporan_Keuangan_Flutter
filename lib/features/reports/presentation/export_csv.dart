import 'package:csv/csv.dart';

import '../../transactions/data/transaction_model.dart';

class CsvExport {
  static String generate({
    required List<TransactionModel> transactions,
  }) {
    final rows = <List<dynamic>>[];

    rows.add([
      "Tanggal",
      "Judul",
      "Kategori",
      "Jenis",
      "Status",
      "Nominal",
    ]);

    for (final t in transactions) {
      rows.add([
        t.date,
        t.title,
        t.category,
        t.isExpense ? "Pengeluaran" : "Pemasukan",
        t.status.name,
        t.amount,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }
}