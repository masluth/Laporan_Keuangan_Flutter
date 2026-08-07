import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:convert';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/data/transaction_model.dart';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'export_pdf.dart';
import 'export_csv.dart';
import 'package:universal_html/html.dart' as html;

class ReportPreviewScreen extends ConsumerWidget {
  final String format;
  final String period;

  const ReportPreviewScreen({
    super.key,
    required this.format,
    required this.period,
  });
  @override
Widget build(BuildContext context, WidgetRef ref) {
final List<TransactionModel> transactions =
    ref.watch(transactionProvider);
    final totalIncome = transactions
    .where((e) => !e.isExpense)
    .fold<double>(0, (sum, e) => sum + e.amount);

final totalExpense = transactions
    .where((e) => e.isExpense)
    .fold<double>(0, (sum, e) => sum + e.amount);

final balance = totalIncome - totalExpense;

void downloadCsv() {
  final csv = CsvExport.generate(
    transactions: transactions,
  );

  final bytes = utf8.encode(csv);

  final blob = html.Blob([bytes]);

  final url = html.Url.createObjectUrlFromBlob(blob);

  html.AnchorElement(href: url)
    ..download = "laporan_keuangan.csv"
    ..click();

  html.Url.revokeObjectUrl(url);
}

    if (format == "PDF") {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Preview PDF"),
        ),
        body: PdfPreview(
        build: (format) => PdfExport.generate(
          period: period,
          transactions: transactions,
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          balance: balance,

          ),        
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Preview CSV"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const Text(
              "Preview Data CSV",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    DataColumn(label: Text("Tanggal")),
                    DataColumn(label: Text("Kategori")),
                    DataColumn(label: Text("Jenis")),
                    DataColumn(label: Text("Nominal")),
                  ],
                  rows: transactions.map((t) {
                    return DataRow(
                      cells: [
                        DataCell(Text(t.date)),
                        DataCell(Text(t.category)),
                        DataCell(
                          Text(
                            t.isExpense ? "Pengeluaran" : "Pemasukan",
                          ),
                        ),
                        DataCell(
                          Text(
                            "Rp ${t.amount.toStringAsFixed(0)}",
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: 
              FilledButton.icon(
                onPressed: downloadCsv,
                icon: const Icon(Icons.download),
                label: const Text("Download CSV"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}