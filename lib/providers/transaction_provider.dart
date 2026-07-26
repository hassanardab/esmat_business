//lib/providers/transaction_provider.dart
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import 'package:collection/collection.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  Future<void> loadTransactions({String? projectId}) async {
    _transactions = StorageService.getTransactions(projectId: projectId);
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await StorageService.addTransaction(transaction);
    await loadTransactions(projectId: transaction.projectId);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await StorageService.updateTransaction(transaction);
    await loadTransactions(projectId: transaction.projectId);
  }

  Future<void> deleteTransaction(String id) async {
    final transaction = _transactions.firstWhereOrNull((t) => t.id == id);

    if (transaction != null) {
      await StorageService.deleteTransaction(id);
      await loadTransactions(projectId: transaction.projectId);
    }
  }

  List<Transaction> getTransactionsByProject(String projectId) {
    return _transactions.where((t) => t.projectId == projectId).toList();
  }
}
