import 'dart:typed_data';

import 'package:excel/excel.dart';

import '../../transactions/data/transaction_model.dart';

class ExcelExport {
  static Uint8List generate({
    required List<TransactionModel> transactions,
  }) {
    final excel = Excel.createExcel();

    final sheet = excel['Laporan Keuangan'];

    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    double totalIncome = 0;
    double totalExpense = 0;

    for (final t in transactions) {
      if (t.isExpense) {
        totalExpense += t.amount;
      } else {
        totalIncome += t.amount;
      }
    }

    final balance = totalIncome - totalExpense;

    // ===========================
    // STYLE
    // ===========================

    final titleStyle = CellStyle(
      bold: true,
      fontSize: 18,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final subTitleStyle = CellStyle(
      bold: true,
      fontSize: 14,
      horizontalAlign: HorizontalAlign.Center,
    );

    final sectionStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.blueGrey50,
    );

    final headerStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.blue,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    final moneyStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Right,
    );

    // ===========================
    // JUDUL
    // ===========================

    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0),
    );

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .value = TextCellValue("REVENANT FINANCE MANAGER");

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .cellStyle = titleStyle;

    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 1),
    );

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
        .value = TextCellValue("Laporan Keuangan");

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
        .cellStyle = subTitleStyle;

    // ===========================
    // RINGKASAN
    // ===========================

    sheet.appendRow([]);

    sheet.appendRow([
      TextCellValue("Ringkasan"),
    ]);

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3))
        .cellStyle = sectionStyle;

    sheet.appendRow([
      TextCellValue("Total Pemasukan"),
      TextCellValue("Rp ${totalIncome.toStringAsFixed(0)}"),
    ]);

    sheet.appendRow([
      TextCellValue("Total Pengeluaran"),
      TextCellValue("Rp ${totalExpense.toStringAsFixed(0)}"),
    ]);

    sheet.appendRow([
      TextCellValue("Saldo"),
      TextCellValue("Rp ${balance.toStringAsFixed(0)}"),
    ]);

    sheet.appendRow([]);

    // ===========================
    // HEADER
    // ===========================

    sheet.appendRow([
      TextCellValue("Tanggal"),
      TextCellValue("Judul"),
      TextCellValue("Kategori"),
      TextCellValue("Jenis"),
      TextCellValue("Status"),
      TextCellValue("Nominal"),
    ]);

    for (int i = 0; i < 6; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 8))
          .cellStyle = headerStyle;
    }

    // ===========================
    // DATA
    // ===========================

    int row = 9;

    for (final t in transactions) {
      sheet.appendRow([
        TextCellValue(t.date),
        TextCellValue(t.title),
        TextCellValue(t.category),
        TextCellValue(
          t.isExpense ? "Pengeluaran" : "Pemasukan",
        ),
        TextCellValue(
          t.status.name == "lunas"
              ? "Lunas"
              : "Belum Lunas",
        ),
        TextCellValue(
          "Rp ${t.amount.toStringAsFixed(0)}",
        ),
      ]);

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
          .cellStyle = moneyStyle;

      row++;
    }

    // ===========================
    // LEBAR KOLOM
    // ===========================

    sheet.setColumnWidth(0, 18);
    sheet.setColumnWidth(1, 35);
    sheet.setColumnWidth(2, 22);
    sheet.setColumnWidth(3, 18);
    sheet.setColumnWidth(4, 18);
    sheet.setColumnWidth(5, 22);

    return Uint8List.fromList(excel.encode()!);
  }
}