import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'transaction_model.dart';

class TransactionRepository {
  final SupabaseClient _supabase;

  TransactionRepository([SupabaseClient? supabase])
      : _supabase = supabase ?? Supabase.instance.client;

  Future<List<TransactionModel>> getTransactions() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User belum login.');
    }

    debugPrint('CURRENT SUPABASE USER: ${user.id}');
    debugPrint('CURRENT SUPABASE EMAIL: ${user.email}');

    final response = await _supabase
        .from('transactions')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map(
          (item) => TransactionModel.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<void> addTransaction(TransactionModel item) async {
    await _supabase.from('transactions').insert(item.toMap());
  }

  Future<void> updateTransaction(TransactionModel item) async {
    await _supabase
        .from('transactions')
        .update(item.toMap())
        .eq('id', item.id);
  }

  Future<void> deleteTransaction(String id) async {
    await _supabase
        .from('transactions')
        .delete()
        .eq('id', id);
  }
}