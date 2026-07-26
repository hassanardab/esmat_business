//lib/providers/bill_provider.dart
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../models/bill.dart';
import '../services/storage_service.dart';

class BillProvider with ChangeNotifier {
  List<Bill> _bills = [];

  List<Bill> get bills => _bills;

  Future<void> loadBills({String? projectId}) async {
    _bills = StorageService.getBills(projectId: projectId);
    notifyListeners();
  }

  Future<void> addBill(Bill bill) async {
    await StorageService.addBill(bill);
    await loadBills(projectId: bill.projectId);
  }

  Future<void> updateBill(Bill bill) async {
    await StorageService.updateBill(bill);
    await loadBills(projectId: bill.projectId);
  }

  Future<void> deleteBill(String id) async {
    final bill = _bills.firstWhereOrNull((b) => b.id == id);

    if (bill != null) {
      await StorageService.deleteBill(id);
      await loadBills(projectId: bill.projectId);
    }
  }
}
