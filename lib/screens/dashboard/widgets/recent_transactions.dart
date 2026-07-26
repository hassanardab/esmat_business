import 'package:esmat_business/models/enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/transaction_provider.dart';
import '../../../models/transaction.dart';

class RecentTransactions extends StatelessWidget {
  final String projectId;

  const RecentTransactions({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final transactions = transactionProvider
        .getTransactionsByProject(projectId)
        .where((t) => t.type == TransactionType.expense)
        .take(5)
        .toList();

    if (transactions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No recent transactions'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Recent Expenses',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...transactions.map((t) => _buildTransactionItem(context, t)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Navigate to all transactions
              },
              child: const Text('View All Transactions'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final color = transaction.type == TransactionType.income
        ? Colors.green
        : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            transaction.paymentMethod == PaymentMethod.cash
                ? Icons.money
                : Icons.account_balance,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              transaction.title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${transaction.amount.toStringAsFixed(2)} SDG',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            dateFormat.format(transaction.date),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
