import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/status_chip.dart';
import '../data/transaction_model.dart';
import '../providers/transaction_provider.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isExpense = true;
  TransactionStatus _status = TransactionStatus.lunas;
  String _category = 'Operasional';

  final List<String> _categories = ['Operasional', 'Penjualan', 'Inventaris', 'Piutang', 'Logistik', 'Lainnya'];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0.0;

    final newTransaction = TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      date: 'Hari ini',
      amount: amount,
      isExpense: _isExpense,
      status: _status,
      category: _category,
    );

    ref.read(transactionProvider.notifier).addTransaction(newTransaction);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berhasil ditambahkan!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
        top: 20.0,
        left: 20.0,
        right: 20.0,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Add Transaction',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 20.0),

              // Transaction Type Selector (Income / Expense)
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Center(
                        child: Text(
                          'Pemasukan (+)',
                          style: TextStyle(
                            color: !_isExpense ? Colors.white : AppColors.incomeGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      selected: !_isExpense,
                      selectedColor: AppColors.incomeGreen,
                      backgroundColor: AppColors.incomeGreenBg,
                      onSelected: (val) => setState(() => _isExpense = false),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: ChoiceChip(
                      label: Center(
                        child: Text(
                          'Pengeluaran (-)',
                          style: TextStyle(
                            color: _isExpense ? Colors.white : AppColors.expenseRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      selected: _isExpense,
                      selectedColor: AppColors.expenseRed,
                      backgroundColor: AppColors.expenseRedBg,
                      onSelected: (val) => setState(() => _isExpense = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Title input
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi / Nama Transaksi',
                  hintText: 'Contoh: Restock Kopi, Pembayaran Klien',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 14.0),

              // Amount input
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Uang (Rp)',
                  prefixText: 'Rp ',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Jumlah wajib diisi' : null,
              ),
              const SizedBox(height: 14.0),

              // Category dropdown
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
              const SizedBox(height: 14.0),

              // Status Selector (Lunas / Belum Lunas)
              Text(
                'Status Pembayaran',
                style: GoogleFonts.inter(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _status == TransactionStatus.lunas ? AppColors.incomeGreenBg : Colors.transparent,
                        side: BorderSide(
                          color: _status == TransactionStatus.lunas ? AppColors.incomeGreen : AppColors.lightBorder,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      onPressed: () => setState(() => _status = TransactionStatus.lunas),
                      child: const Text('Lunas', style: TextStyle(color: Color(0xFF047857), fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _status == TransactionStatus.belumLunas ? AppColors.debtAmberBg : Colors.transparent,
                        side: BorderSide(
                          color: _status == TransactionStatus.belumLunas ? AppColors.debtAmber : AppColors.lightBorder,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      onPressed: () => setState(() => _status = TransactionStatus.belumLunas),
                      child: const Text('Belum Lunas', style: TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // Save Button
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
                child: Text(
                  'Simpan Transaksi',
                  style: GoogleFonts.inter(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
