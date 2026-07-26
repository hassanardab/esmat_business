//lib/services/storage_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/project.dart';
import '../models/transaction.dart';
import '../models/bill.dart';
import '../models/payroll.dart';
import '../models/vendor.dart';

class StorageService {
  static const String _projectsBox = 'projects';
  static const String _transactionsBox = 'transactions';
  static const String _billsBox = 'bills';
  static const String _payrollsBox = 'payrolls';
  static const String _vendorsBox = 'vendors';

  static late Box<Project> _projects;
  static late Box<Transaction> _transactions;
  static late Box<Bill> _bills;
  static late Box<Payroll> _payrolls;
  static late Box<Vendor> _vendors;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(ProjectAdapter());
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(BillAdapter());
    Hive.registerAdapter(PayrollAdapter());
    Hive.registerAdapter(VendorAdapter());

    // Open boxes
    _projects = await Hive.openBox<Project>(_projectsBox);
    _transactions = await Hive.openBox<Transaction>(_transactionsBox);
    _bills = await Hive.openBox<Bill>(_billsBox);
    _payrolls = await Hive.openBox<Payroll>(_payrollsBox);
    _vendors = await Hive.openBox<Vendor>(_vendorsBox);
  }

  // Project CRUD
  static List<Project> getProjects() => _projects.values.toList();
  static Project? getProject(String id) => _projects.get(id);
  static Future<void> addProject(Project project) => _projects.add(project);
  static Future<void> updateProject(Project project) =>
      _projects.put(project.id, project);
  static Future<void> deleteProject(String id) => _projects.delete(id);

  // Transaction CRUD
  static List<Transaction> getTransactions({String? projectId}) {
    final all = _transactions.values.toList();
    if (projectId == null) return all;
    return all.where((t) => t.projectId == projectId).toList();
  }

  static Future<void> addTransaction(Transaction transaction) =>
      _transactions.add(transaction);
  static Future<void> updateTransaction(Transaction transaction) =>
      _transactions.put(transaction.id, transaction);
  static Future<void> deleteTransaction(String id) => _transactions.delete(id);

  // Bill CRUD
  static List<Bill> getBills({String? projectId}) {
    final all = _bills.values.toList();
    if (projectId == null) return all;
    return all.where((b) => b.projectId == projectId).toList();
  }

  static Future<void> addBill(Bill bill) => _bills.add(bill);
  static Future<void> updateBill(Bill bill) => _bills.put(bill.id, bill);
  static Future<void> deleteBill(String id) => _bills.delete(id);

  // Payroll CRUD
  static List<Payroll> getPayrolls({String? projectId}) {
    final all = _payrolls.values.toList();
    if (projectId == null) return all;
    return all.where((p) => p.projectId == projectId).toList();
  }

  static Future<void> addPayroll(Payroll payroll) => _payrolls.add(payroll);
  static Future<void> updatePayroll(Payroll payroll) =>
      _payrolls.put(payroll.id, payroll);
  static Future<void> deletePayroll(String id) => _payrolls.delete(id);

  // Vendor CRUD
  static List<Vendor> getVendors() => _vendors.values.toList();
  static Vendor? getVendor(String id) => _vendors.get(id);
  static Future<void> addVendor(Vendor vendor) => _vendors.add(vendor);
  static Future<void> updateVendor(Vendor vendor) =>
      _vendors.put(vendor.id, vendor);
  static Future<void> deleteVendor(String id) => _vendors.delete(id);

  // Clear all data (for testing)
  static Future<void> clearAll() async {
    await _projects.clear();
    await _transactions.clear();
    await _bills.clear();
    await _payrolls.clear();
    await _vendors.clear();
  }
}
