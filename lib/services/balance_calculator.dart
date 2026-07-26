import 'package:esmat_business/models/enums.dart';

import 'storage_service.dart';

class BalanceCalculator {
  static Map<String, double> calculateProjectBalances(String projectId) {
    final project = StorageService.getProject(projectId);
    if (project == null) {
      return {'cash': 0, 'bank': 0, 'total': 0};
    }

    final transactions = StorageService.getTransactions(projectId: projectId);
    final bills = StorageService.getBills(projectId: projectId);
    final payrolls = StorageService.getPayrolls(projectId: projectId);

    double cashBalance = project.startingCashBalance;
    double bankBalance = project.startingBankBalance;

    // Process transactions
    for (final t in transactions) {
      if (t.isCash) {
        cashBalance += t.isIncome ? t.amount : -t.amount;
      } else {
        bankBalance += t.isIncome ? t.amount : -t.amount;
      }
    }

    // Process bills (only paid bills affect balance)
    for (final b in bills) {
      if (b.isPaid && b.paymentMethod != null) {
        if (b.paymentMethod == PaymentMethod.cash) {
          cashBalance -= b.amount;
        } else {
          bankBalance -= b.amount;
        }
      }
    }

    // Process payrolls (only paid payrolls affect balance)
    for (final p in payrolls) {
      if (p.isPaid) {
        if (p.isCash) {
          cashBalance -= p.amount;
        } else {
          bankBalance -= p.amount;
        }
      }
    }

    return {
      'cash': cashBalance,
      'bank': bankBalance,
      'total': cashBalance + bankBalance,
    };
  }

  static double calculateVendorBalance(String vendorId) {
    final bills = StorageService.getBills().where(
      (b) => b.vendorId == vendorId,
    );
    final transactions = StorageService.getTransactions().where(
      (t) => t.vendorId == vendorId && t.isExpense,
    );

    double balance = 0;

    // Add from bills (only unpaid)
    for (final b in bills) {
      if (!b.isPaid) {
        balance += b.amount;
      }
    }

    // Subtract from payments (transactions to this vendor)
    for (final t in transactions) {
      balance -= t.amount;
    }

    return balance;
  }

  static Map<String, dynamic> getProjectFinancialSummary(String projectId) {
    final balances = calculateProjectBalances(projectId);
    final transactions = StorageService.getTransactions(projectId: projectId);
    final bills = StorageService.getBills(projectId: projectId);
    final payrolls = StorageService.getPayrolls(projectId: projectId);

    // Calculate totals
    double totalIncome = 0;
    double totalExpense = 0;
    double totalBills = 0;
    double totalPaidBills = 0;
    double totalPayroll = 0;
    double totalPaidPayroll = 0;

    for (final t in transactions) {
      if (t.isIncome) totalIncome += t.amount;
      if (t.isExpense) totalExpense += t.amount;
    }

    for (final b in bills) {
      totalBills += b.amount;
      if (b.isPaid) totalPaidBills += b.amount;
    }

    for (final p in payrolls) {
      totalPayroll += p.amount;
      if (p.isPaid) totalPaidPayroll += p.amount;
    }

    return {
      'balances': balances,
      'transactions': {
        'income': totalIncome,
        'expense': totalExpense,
        'net': totalIncome - totalExpense,
      },
      'bills': {
        'total': totalBills,
        'paid': totalPaidBills,
        'pending': totalBills - totalPaidBills,
      },
      'payroll': {
        'total': totalPayroll,
        'paid': totalPaidPayroll,
        'pending': totalPayroll - totalPaidPayroll,
      },
    };
  }
}
