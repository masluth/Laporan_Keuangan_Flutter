import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;

import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/data/transaction_model.dart';

import 'export_pdf.dart';
import 'export_excel.dart';

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

    void downloadExcel() {
      final bytes = ExcelExport.generate(
        transactions: transactions,
      );

      final blob = html.Blob([bytes]);

      final url = html.Url.createObjectUrlFromBlob(blob);

      html.AnchorElement(href: url)
        ..download = "laporan_keuangan.xlsx"
        ..click();

      html.Url.revokeObjectUrl(url);
    }

    // =======================
    // PDF
    // =======================

    if (format == "PDF") {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Preview PDF"),
        ),
        body: PdfPreview(
          build: (_) => PdfExport.generate(
            period: period,
            transactions: transactions,
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            balance: balance,
          ),
        ),
      );
    }

    // =======================
    // EXCEL PREVIEW
    // =======================

    return Scaffold(
      appBar: AppBar(
        title: const Text("Preview Excel"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    const Text(
                      "Ringkasan Laporan",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                      children: [

                        _summaryItem(
                          "Pemasukan",
                          "Rp ${totalIncome.toStringAsFixed(0)}",
                          Colors.green,
                        ),

                        _summaryItem(
                          "Pengeluaran",
                          "Rp ${totalExpense.toStringAsFixed(0)}",
                          Colors.red,
                        ),

                        _summaryItem(
                          "Saldo",
                          "Rp ${balance.toStringAsFixed(0)}",
                          Colors.blue,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Jumlah Transaksi : ${transactions.length}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor:
                            WidgetStateProperty.all(
                          Colors.blue.shade50,
                        ),
                        columns: const [
                          DataColumn(label: Text("Tanggal")),
                          DataColumn(label: Text("Judul")),
                          DataColumn(label: Text("Kategori")),
                          DataColumn(label: Text("Jenis")),
                          DataColumn(label: Text("Status")),
                          DataColumn(label: Text("Nominal")),
                        ],
                        rows: transactions.map((t) {
                          return DataRow(
                            cells: [

                              DataCell(Text(t.date)),

                              DataCell(Text(t.title)),

                              DataCell(Text(t.category)),

                              DataCell(
                                Text(
                                  t.isExpense
                                      ? "Pengeluaran"
                                      : "Pemasukan",
                                ),
                              ),

                              DataCell(
                                Text(t.status.name),
                              ),

                              DataCell(
                                Text(
                                  "Rp ${t.amount.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    color: t.isExpense
                                        ? Colors.red
                                        : Colors.green,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: downloadExcel,
                icon: const Icon(Icons.download),
                label: const Text(
                  "Download Excel",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(
    String title,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}