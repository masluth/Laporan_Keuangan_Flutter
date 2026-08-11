import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/status_chip.dart';
import '../data/transaction_model.dart';
import '../providers/transaction_provider.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  final TransactionModel? transaction;

  const AddTransactionSheet({
    super.key,
    this.transaction,
  });

  bool get isEdit => transaction != null;

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState
    extends ConsumerState<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;

  bool _isExpense = true;

  // Default transaksi baru = Lunas.
  // User tetap dapat mengubahnya menjadi Belum Lunas.
  TransactionStatus _status = TransactionStatus.lunas;

  String _category = 'Operasional';

  bool _isSaving = false;

  // =========================================================
  // TANGGAL TRANSAKSI
  // =========================================================

  late DateTime _selectedDate;

  final List<String> _categories = [
    'Operasional',
    'Penjualan',
    'Inventaris',
    'Piutang',
    'Logistik',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();

    final transaction = widget.transaction;

    _titleController = TextEditingController(
      text: transaction?.title ?? '',
    );

    _amountController = TextEditingController(
      text: transaction != null
          ? transaction.amount.toStringAsFixed(0)
          : '',
    );

    // =======================================================
    // SET TANGGAL
    // =======================================================

    if (transaction != null) {
      _selectedDate =
          DateTime.tryParse(transaction.date) ?? DateTime.now();
    } else {
      _selectedDate = DateTime.now();
    }

    if (transaction != null) {
      _isExpense = transaction.isExpense;
      _status = transaction.status;

      _category = _categories.contains(transaction.category)
          ? transaction.category
          : 'Lainnya';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // =========================================================
  // FORMAT TANGGAL UNTUK SUPABASE
  // =========================================================

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  // =========================================================
  // FORMAT TANGGAL UNTUK DITAMPILKAN
  // =========================================================

  String _formatDisplayDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  // =========================================================
  // DATE PICKER
  // =========================================================

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  // =========================================================
  // SAVE / UPDATE
  // =========================================================

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();

    final amount = double.tryParse(
          _amountController.text.replaceAll('.', ''),
        ) ??
        0.0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Jumlah transaksi harus lebih dari 0',
          ),
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // =====================================================
      // MODE EDIT
      // =====================================================

      if (widget.isEdit) {
        final oldTransaction = widget.transaction!;

        final updatedTransaction = TransactionModel(
          // ID tetap
          id: oldTransaction.id,

          // User tetap
          userId: oldTransaction.userId,

          // Data baru
          title: title,

          // Tanggal bisa diubah oleh user
          date: _formatDate(_selectedDate),

          amount: amount,

          isExpense: _isExpense,

          // Status bisa diubah ketika edit
          status: _status,

          category: _category,
        );

        await ref
            .read(transactionProvider.notifier)
            .updateTransaction(
              updatedTransaction,
            );

        if (!mounted) return;

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Transaksi berhasil diperbarui!',
            ),
          ),
        );

        return;
      }

      // =====================================================
      // MODE TAMBAH
      // =====================================================

      final user =
          Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception(
          'User belum login. Silakan login terlebih dahulu.',
        );
      }

      final newTransaction = TransactionModel(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',

        // UID user yang sedang login
        userId: user.id,

        title: title,

        // Tanggal sesuai pilihan user
        date: _formatDate(_selectedDate),

        amount: amount,

        isExpense: _isExpense,

        // Status sesuai pilihan user
        status: _status,

        category: _category,
      );

      await ref
          .read(transactionProvider.notifier)
          .addTransaction(
            newTransaction,
          );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Transaksi berhasil ditambahkan!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      debugPrint(
        'ERROR SAVE TRANSACTION: $e',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit
                ? 'Gagal memperbarui transaksi: $e'
                : 'Gagal menambahkan transaksi: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom + 20.0,
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
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              // =================================================
              // HANDLE
              // =================================================

              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.lightBorder,
                    borderRadius:
                        BorderRadius.circular(2.0),
                  ),
                ),
              ),

              const SizedBox(height: 16.0),

              // =================================================
              // TITLE
              // =================================================

              Text(
                widget.isEdit
                    ? 'Edit Transaction'
                    : 'Add Transaction',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),

              const SizedBox(height: 20.0),

              // =================================================
              // TRANSACTION TYPE
              // =================================================

              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Center(
                        child: Text(
                          'Pemasukan (+)',
                          style: TextStyle(
                            color: !_isExpense
                                ? Colors.white
                                : AppColors.incomeGreen,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                      selected: !_isExpense,
                      selectedColor:
                          AppColors.incomeGreen,
                      backgroundColor:
                          AppColors.incomeGreenBg,
                      onSelected: (_) {
                        setState(() {
                          _isExpense = false;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 12.0),

                  Expanded(
                    child: ChoiceChip(
                      label: Center(
                        child: Text(
                          'Pengeluaran (-)',
                          style: TextStyle(
                            color: _isExpense
                                ? Colors.white
                                : AppColors.expenseRed,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                      selected: _isExpense,
                      selectedColor:
                          AppColors.expenseRed,
                      backgroundColor:
                          AppColors.expenseRedBg,
                      onSelected: (_) {
                        setState(() {
                          _isExpense = true;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16.0),

              // =================================================
              // TITLE INPUT
              // =================================================

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText:
                      'Deskripsi / Nama Transaksi',
                  hintText:
                      'Contoh: Restock Kopi, Pembayaran Klien',
                ),
                validator: (val) {
                  if (val == null ||
                      val.trim().isEmpty) {
                    return 'Deskripsi wajib diisi';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14.0),

              // =================================================
              // AMOUNT INPUT
              // =================================================

              TextFormField(
                controller: _amountController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Jumlah Uang (Rp)',
                  prefixText: 'Rp ',
                ),
                validator: (val) {
                  if (val == null ||
                      val.trim().isEmpty) {
                    return 'Jumlah wajib diisi';
                  }

                  final amount =
                      double.tryParse(
                    val.replaceAll('.', ''),
                  );

                  if (amount == null ||
                      amount <= 0) {
                    return 'Jumlah tidak valid';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14.0),

              // =================================================
              // TANGGAL TRANSAKSI
              // =================================================

              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: _formatDisplayDate(
                    _selectedDate,
                  ),
                ),
                decoration:
                    const InputDecoration(
                  labelText: 'Tanggal Transaksi',
                  suffixIcon: Icon(
                    Icons.calendar_today_outlined,
                  ),
                ),
                onTap: _selectDate,
              ),

              const SizedBox(height: 14.0),

              // =================================================
              // CATEGORY
              // =================================================

              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration:
                    const InputDecoration(
                  labelText: 'Kategori',
                ),
                items:
                    _categories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _category = val;
                    });
                  }
                },
              ),

              const SizedBox(height: 14.0),

              // =================================================
              // STATUS
              // =================================================

              Text(
                'Status Pembayaran',
                style: GoogleFonts.inter(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                  color:
                      AppColors.textSecondaryLight,
                ),
              ),

              const SizedBox(height: 8.0),

              Row(
                children: [
                  // ================================
                  // LUNAS
                  // ================================

                  Expanded(
                    child: OutlinedButton(
                      style:
                          OutlinedButton.styleFrom(
                        backgroundColor:
                            _status ==
                                    TransactionStatus
                                        .lunas
                                ? AppColors
                                    .incomeGreenBg
                                : Colors.transparent,
                        side: BorderSide(
                          color: _status ==
                                  TransactionStatus
                                      .lunas
                              ? AppColors
                                  .incomeGreen
                              : AppColors
                                  .lightBorder,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            10.0,
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _status =
                              TransactionStatus.lunas;
                        });
                      },
                      child: const Text(
                        'Lunas',
                        style: TextStyle(
                          color: Color(0xFF047857),
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12.0),

                  // ================================
                  // BELUM LUNAS
                  // ================================

                  Expanded(
                    child: OutlinedButton(
                      style:
                          OutlinedButton.styleFrom(
                        backgroundColor:
                            _status ==
                                    TransactionStatus
                                        .belumLunas
                                ? AppColors
                                    .debtAmberBg
                                : Colors.transparent,
                        side: BorderSide(
                          color: _status ==
                                  TransactionStatus
                                      .belumLunas
                              ? AppColors.debtAmber
                              : AppColors
                                  .lightBorder,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            10.0,
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _status =
                              TransactionStatus
                                  .belumLunas;
                        });
                      },
                      child: const Text(
                        'Belum Lunas',
                        style: TextStyle(
                          color: Color(0xFFB45309),
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24.0),

              // =================================================
              // SAVE / UPDATE BUTTON
              // =================================================

              ElevatedButton(
                onPressed:
                    _isSaving ? null : _save,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primaryBlue,
                  minimumSize:
                      const Size.fromHeight(50),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12.0,
                    ),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.isEdit
                            ? 'Update Transaksi'
                            : 'Simpan Transaksi',
                        style:
                            GoogleFonts.inter(
                          fontSize: 16.0,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}