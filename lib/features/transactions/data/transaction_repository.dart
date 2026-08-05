import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/widgets/status_chip.dart';
import 'transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore? _firestore;

  TransactionRepository([this._firestore]);

  // Initial Stitch mock transactions
  static final List<TransactionModel> _mockTransactions = [
    TransactionModel(
      id: 'tx_1',
      title: 'Inventory Restock',
      date: '24 Oct 2023',
      amount: 1200000,
      isExpense: true,
      status: TransactionStatus.lunas,
      category: 'Inventaris',
    ),
    TransactionModel(
      id: 'tx_2',
      title: 'Client Payment - Toko Jaya',
      date: '23 Oct 2023',
      amount: 4500000,
      isExpense: false,
      status: TransactionStatus.lunas,
      category: 'Penjualan',
    ),
    TransactionModel(
      id: 'tx_3',
      title: 'Budi Santoso (Piutang)',
      date: '23 Oct 2023',
      amount: 1200000,
      isExpense: false,
      status: TransactionStatus.belumLunas,
      category: 'Piutang',
    ),
    TransactionModel(
      id: 'tx_4',
      title: 'Utility Bills (Listrik & Air)',
      date: '22 Oct 2023',
      amount: 450000,
      isExpense: true,
      status: TransactionStatus.lunas,
      category: 'Operasional',
    ),
    TransactionModel(
      id: 'tx_5',
      title: 'UD Maju Bersama',
      date: '22 Oct 2023',
      amount: 890000,
      isExpense: false,
      status: TransactionStatus.lunas,
      category: 'Penjualan',
    ),
    TransactionModel(
      id: 'tx_6',
      title: 'Daily Sales - Warung Kopi',
      date: '22 Oct 2023',
      amount: 2100000,
      isExpense: false,
      status: TransactionStatus.lunas,
      category: 'Penjualan',
    ),
    TransactionModel(
      id: 'tx_7',
      title: 'Siti Aminah (Tagihan)',
      date: '21 Oct 2023',
      amount: 325000,
      isExpense: false,
      status: TransactionStatus.belumLunas,
      category: 'Piutang',
    ),
    TransactionModel(
      id: 'tx_8',
      title: 'Logistics Fee & Kurir',
      date: '21 Oct 2023',
      amount: 125000,
      isExpense: true,
      status: TransactionStatus.lunas,
      category: 'Logistik',
    ),
  ];

  List<TransactionModel> get mockData => List.unmodifiable(_mockTransactions);

  Future<void> addTransaction(TransactionModel item) async {
    if (_firestore != null) {
      try {
        await _firestore.collection('transactions').add(item.toMap());
        return;
      } catch (e) {
        // Fallback to in-memory list
      }
    }
    _mockTransactions.insert(0, item);
  }
}
