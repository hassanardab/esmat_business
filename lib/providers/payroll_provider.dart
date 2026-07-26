//lib/providers/payroll_provider.dart
import 'package:flutter/material.dart';
import '../models/payroll.dart';
import '../services/storage_service.dart';
import 'package:collection/collection.dart';

class PayrollProvider with ChangeNotifier {
  List<Payroll> _payrolls = [];

  List<Payroll> get payrolls => _payrolls;

  Future<void> loadPayrolls({String? projectId}) async {
    _payrolls = StorageService.getPayrolls(projectId: projectId);
    notifyListeners();
  }

  Future<void> addPayroll(Payroll payroll) async {
    await StorageService.addPayroll(payroll);
    await loadPayrolls(projectId: payroll.projectId);
  }

  Future<void> updatePayroll(Payroll payroll) async {
    await StorageService.updatePayroll(payroll);
    await loadPayrolls(projectId: payroll.projectId);
  }

  Future<void> deletePayroll(String id) async {
    final payroll = _payrolls.firstWhereOrNull((p) => p.id == id);

    if (payroll != null) {
      await StorageService.deletePayroll(id);
      await loadPayrolls(projectId: payroll.projectId);
    }
  }
}
