import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../transactions/data/transaction_model.dart';

class PdfExport {
  static Future<Uint8List> generate({
    required String period,
    required List<TransactionModel> transactions,
    required double totalIncome,
    required double totalExpense,
    required double balance,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),

        build: (context) => [

          // ==========================
          // HEADER
          // ==========================

          pw.Center(
            child: pw.Text(
              "REVENANT FINANCE MANAGER",
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.SizedBox(height: 5),

          pw.Center(
            child: pw.Text(
              "Laporan Keuangan",
              style: const pw.TextStyle(
                fontSize: 16,
              ),
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Periode : $period"),
              pw.Text("Dicetak : ${DateTime.now()}"),
            ],
          ),

          pw.Divider(),

          // ==========================
          // RINGKASAN
          // ==========================

          pw.Text(
            "Ringkasan",
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 16,
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [

                pw.Text(
                  "Total Pemasukan : Rp ${totalIncome.toStringAsFixed(0)}",
                ),

                pw.SizedBox(height: 5),

                pw.Text(
                  "Total Pengeluaran : Rp ${totalExpense.toStringAsFixed(0)}",
                ),

                pw.SizedBox(height: 5),

                pw.Text(
                  "Saldo : Rp ${balance.toStringAsFixed(0)}",
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 25),

          // ==========================
          // TABEL
          // ==========================

          pw.Text(
            "Daftar Transaksi",
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          pw.TableHelper.fromTextArray(

            border: pw.TableBorder.all(),

            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),

            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.blueGrey700,
            ),

            headers: const [
              "Tanggal",
              "Judul",
              "Kategori",
              "Jenis",
              "Status",
              "Nominal",
            ],

            data: transactions.map((t) {

              return [

                t.date,

                t.title,

                t.category,

                t.isExpense
                    ? "Pengeluaran"
                    : "Pemasukan",

                t.status.name,

                "Rp ${t.amount.toStringAsFixed(0)}",

              ];

            }).toList(),

          ),

          pw.SizedBox(height: 20),

          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              "Total Data : ${transactions.length} transaksi",
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}