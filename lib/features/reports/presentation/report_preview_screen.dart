import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;
import 'package:intl/intl.dart';

import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/data/transaction_model.dart';

import 'export_pdf.dart';
import 'export_excel.dart';

class ReportPreviewScreen extends ConsumerStatefulWidget {
  final String format;
  final String period;

  const ReportPreviewScreen({
    super.key,
    required this.format,
    required this.period,
  });

  @override
  ConsumerState<ReportPreviewScreen> createState() =>
      _ReportPreviewScreenState();
}

class _ReportPreviewScreenState
    extends ConsumerState<ReportPreviewScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(transactionProvider.notifier)
          .loadTransactions();
    });
  }

  // =========================================================
  // PARSE TANGGAL TRANSAKSI
  // =========================================================

  DateTime? _parseTransactionDate(String value) {
    try {
      final cleanValue = value.trim();

      // Format ISO:
      // 2026-08-09
      // 2026-08-09T10:30:00
      if (cleanValue.contains('-')) {
        return DateTime.tryParse(cleanValue);
      }

      // Format:
      // 09/08/2026
      if (cleanValue.contains('/')) {
        final parts = cleanValue.split('/');

        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);

          if (day != null &&
              month != null &&
              year != null) {
            return DateTime(
              year,
              month,
              day,
            );
          }
        }
      }

      // Format:
      // 09-08-2026
      if (cleanValue.contains('-')) {
        final parts = cleanValue.split('-');

        if (parts.length == 3) {
          final day = int.tryParse(parts[0]);
          final month = int.tryParse(parts[1]);
          final year = int.tryParse(parts[2]);

          if (day != null &&
              month != null &&
              year != null &&
              year > 2000) {
            return DateTime(
              year,
              month,
              day,
            );
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint(
        'Gagal parsing tanggal: $value | $e',
      );

      return null;
    }
  }

  // =========================================================
  // FORMAT TANGGAL UNTUK PREVIEW
  // =========================================================

  String _formatTransactionDate(String value) {
    final date = _parseTransactionDate(value);

    if (date == null) {
      return value;
    }

    return DateFormat(
      'dd MMMM yyyy',
      'id_ID',
    ).format(date);
  }

  // =========================================================
  // FILTER PERIODE
  // =========================================================

  List<TransactionModel> _filterTransactions(
    List<TransactionModel> transactions,
  ) {
    final now = DateTime.now();

    DateTime startDate;
    DateTime endDate;

    // =======================================================
    // BULAN INI
    // =======================================================

    if (widget.period.startsWith('Bulan Ini')) {
      startDate = DateTime(
        now.year,
        now.month,
        1,
      );

      endDate = DateTime(
        now.year,
        now.month + 1,
        1,
      );

    // =======================================================
    // BULAN LALU
    // =======================================================

    } else if (widget.period.startsWith('Bulan Lalu')) {
      startDate = DateTime(
        now.year,
        now.month - 1,
        1,
      );

      endDate = DateTime(
        now.year,
        now.month,
        1,
      );

    // =======================================================
    // TAHUN INI
    // =======================================================

    } else if (widget.period.startsWith('Tahun Ini')) {
      startDate = DateTime(
        now.year,
        1,
        1,
      );

      endDate = DateTime(
        now.year + 1,
        1,
        1,
      );

    // =======================================================
    // DEFAULT
    // =======================================================

    } else {
      return transactions;
    }

    final filtered = transactions.where((transaction) {
      final transactionDate =
          _parseTransactionDate(transaction.date);

      if (transactionDate == null) {
        debugPrint(
          'Tanggal tidak bisa dibaca: ${transaction.date}',
        );

        return false;
      }

      final dateOnly = DateTime(
        transactionDate.year,
        transactionDate.month,
        transactionDate.day,
      );

      return !dateOnly.isBefore(startDate) &&
          dateOnly.isBefore(endDate);
    }).toList();

    return filtered;
  }

  // =========================================================
  // DOWNLOAD EXCEL
  // =========================================================

  void _downloadExcel(
    List<TransactionModel> transactions,
  ) {
    final bytes = ExcelExport.generate(
      transactions: transactions,
    );

    final blob = html.Blob([bytes]);

    final url =
        html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..download = "laporan_keuangan.xlsx"
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final allTransactions =
        ref.watch(transactionProvider);

    // =======================================================
    // FILTER TRANSAKSI BERDASARKAN PERIODE
    // =======================================================

    final transactions =
        _filterTransactions(
      allTransactions,
    );

    // =======================================================
    // DEBUG
    // =======================================================

    debugPrint(
      '======================================',
    );

    debugPrint(
      'REPORT PREVIEW',
    );

    debugPrint(
      'PERIOD : ${widget.period}',
    );

    debugPrint(
      'ALL TRANSACTIONS : ${allTransactions.length}',
    );

    debugPrint(
      'FILTERED TRANSACTIONS : ${transactions.length}',
    );

    for (final transaction in transactions) {
      debugPrint(
        'PREVIEW: '
        '${transaction.title} | '
        '${transaction.date}',
      );
    }

    debugPrint(
      '======================================',
    );

    // =======================================================
    // SUMMARY
    // =======================================================

    final totalIncome = transactions
        .where((e) => !e.isExpense)
        .fold<double>(
          0,
          (sum, e) => sum + e.amount,
        );

    final totalExpense = transactions
        .where((e) => e.isExpense)
        .fold<double>(
          0,
          (sum, e) => sum + e.amount,
        );

    final balance =
        totalIncome - totalExpense;

    // =======================================================
    // PDF
    // =======================================================

    if (widget.format == 'PDF') {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Preview PDF',
          ),
        ),
        body: PdfPreview(
          build: (_) {
            return PdfExport.generate(
              period: widget.period,
              transactions: transactions,
              totalIncome: totalIncome,
              totalExpense: totalExpense,
              balance: balance,
            );
          },
        ),
      );
    }

    // =======================================================
    // EXCEL
    // =======================================================

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Preview Excel',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // =================================================
            // PERIOD
            // =================================================

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        widget.period,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // =================================================
            // SUMMARY
            // =================================================

            Card(
              elevation: 2,
              child: Padding(
                padding:
                    const EdgeInsets.all(16),
                child: Column(
                  children: [

                    const Text(
                      'Ringkasan Laporan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceAround,
                      children: [

                        _summaryItem(
                          'Pemasukan',
                          'Rp ${totalIncome.toStringAsFixed(0)}',
                          Colors.green,
                        ),

                        _summaryItem(
                          'Pengeluaran',
                          'Rp ${totalExpense.toStringAsFixed(0)}',
                          Colors.red,
                        ),

                        _summaryItem(
                          'Saldo',
                          'Rp ${balance.toStringAsFixed(0)}',
                          Colors.blue,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Text(
                      'Jumlah Transaksi : ${transactions.length}',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // =================================================
            // TABLE
            // =================================================

            Expanded(
              child: Card(
                elevation: 2,
                child: transactions.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Icon(
                              Icons
                                  .receipt_long_outlined,
                              size: 48,
                              color:
                                  Colors.grey,
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Text(
                              'Tidak ada transaksi pada periode ini.',
                              textAlign:
                                  TextAlign.center,
                              style:
                                  TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding:
                            const EdgeInsets.all(
                          10,
                        ),
                        child:
                            SingleChildScrollView(
                          scrollDirection:
                              Axis.vertical,
                          child:
                              SingleChildScrollView(
                            scrollDirection:
                                Axis.horizontal,
                            child: DataTable(
                              headingRowColor:
                                  WidgetStateProperty
                                      .all(
                                Colors
                                    .blue
                                    .shade50,
                              ),
                              columns:
                                  const [
                                DataColumn(
                                  label: Text(
                                    'Tanggal',
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Judul',
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Kategori',
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Jenis',
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Status',
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Nominal',
                                  ),
                                ),
                              ],
                              rows:
                                  transactions
                                      .map(
                                (t) {
                                  return DataRow(
                                    cells: [

                                      DataCell(
                                        Text(
                                          _formatTransactionDate(
                                            t.date,
                                          ),
                                        ),
                                      ),

                                      DataCell(
                                        Text(
                                          t.title,
                                        ),
                                      ),

                                      DataCell(
                                        Text(
                                          t.category,
                                        ),
                                      ),

                                      DataCell(
                                        Text(
                                          t.isExpense
                                              ? 'Pengeluaran'
                                              : 'Pemasukan',
                                        ),
                                      ),

                                      DataCell(
                                        Text(
                                          t.status
                                              .name,
                                        ),
                                      ),

                                      DataCell(
                                        Text(
                                          'Rp ${t.amount.toStringAsFixed(0)}',
                                          style:
                                              TextStyle(
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
                                },
                              ).toList(),
                            ),
                          ),
                        ),
                      ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // =================================================
            // DOWNLOAD EXCEL
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed:
                    transactions.isEmpty
                        ? null
                        : () =>
                            _downloadExcel(
                              transactions,
                            ),
                icon: const Icon(
                  Icons.download,
                ),
                label: const Text(
                  'Download Excel',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // SUMMARY ITEM
  // =========================================================

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
        const SizedBox(
          height: 6,
        ),
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