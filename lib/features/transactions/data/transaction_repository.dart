import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'transaction_model.dart';

class TransactionRepository {
  final SupabaseClient _supabase;

  TransactionRepository([SupabaseClient? supabase])
      : _supabase =
            supabase ?? Supabase.instance.client;

  // =========================================================
  // CURRENT USER
  // =========================================================

  User _requireUser() {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User belum login.');
    }

    return user;
  }

  // =========================================================
  // READ
  // =========================================================

  Future<List<TransactionModel>> getTransactions() async {
    final user = _requireUser();

    debugPrint(
      'CURRENT SUPABASE USER: ${user.id}',
    );

    debugPrint(
      'CURRENT SUPABASE EMAIL: ${user.email}',
    );

    final response = await _supabase
        .from('transactions')
        .select()
        .eq('user_id', user.id)
        .order(
          'created_at',
          ascending: false,
        );

    debugPrint(
      'TRANSACTIONS FOUND: ${response.length}',
    );

    return (response as List)
        .map(
          (item) => TransactionModel.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // =========================================================
  // CREATE
  // =========================================================

  Future<void> addTransaction(
    TransactionModel item,
  ) async {
    final user = _requireUser();

    final data = item.toMap();

    // UID selalu berasal dari session Supabase
    data['user_id'] = user.id;

    debugPrint(
      'INSERT TRANSACTION USER ID: ${user.id}',
    );

    await _supabase
        .from('transactions')
        .insert(data);
  }

  // =========================================================
  // UPDATE
  // =========================================================

  Future<void> updateTransaction(
    TransactionModel item,
  ) async {
    final user = _requireUser();

    final data = item.toMap();

    // User ID selalu berasal dari session
    data['user_id'] = user.id;

    await _supabase
        .from('transactions')
        .update(data)
        .eq('id', item.id)
        .eq('user_id', user.id);
  }

  // =========================================================
  // DELETE
  // =========================================================

  Future<void> deleteTransaction(
    String id,
  ) async {
    final user = _requireUser();

    await _supabase
        .from('transactions')
        .delete()
        .eq('id', id)
        .eq('user_id', user.id);
  }
}