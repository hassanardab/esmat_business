import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/bill_provider.dart';
import '../../providers/payroll_provider.dart';
import '../../services/balance_calculator.dart';
import 'widgets/balance_card.dart';
import 'widgets/project_selector.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_transactions.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final projectProvider = context.read<ProjectProvider>();
    if (projectProvider.selectedProject != null) {
      await context.read<TransactionProvider>().loadTransactions(
        projectId: projectProvider.selectedProject!.id,
      );
      await context.read<BillProvider>().loadBills(
        projectId: projectProvider.selectedProject!.id,
      );
      await context.read<PayrollProvider>().loadPayrolls(
        projectId: projectProvider.selectedProject!.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ProjectSelector(),
            const SizedBox(height: 20),
            Consumer2<ProjectProvider, TransactionProvider>(
              builder: (context, projectProvider, transactionProvider, child) {
                if (projectProvider.selectedProject == null) {
                  return const Center(
                    child: Text(
                      'Please select a project to view dashboard',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                final project = projectProvider.selectedProject!;
                final balances = BalanceCalculator.calculateProjectBalances(
                  project.id,
                );
                final summary = BalanceCalculator.getProjectFinancialSummary(
                  project.id,
                );

                return Column(
                  children: [
                    // Balance Cards
                    Row(
                      children: [
                        Expanded(
                          child: BalanceCard(
                            title: 'Cash Balance',
                            amount: balances['cash']!,
                            icon: Icons.money,
                            color: Colors.green,
                            onTap: () => _showBalanceVerificationDialog(
                              context,
                              'Cash',
                              project.startingCashBalance,
                              balances['cash']!,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: BalanceCard(
                            title: 'Bank Balance',
                            amount: balances['bank']!,
                            icon: Icons.account_balance,
                            color: Colors.blue,
                            onTap: () => _showBalanceVerificationDialog(
                              context,
                              'Bank',
                              project.startingBankBalance,
                              balances['bank']!,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    BalanceCard(
                      title: 'Total Balance',
                      amount: balances['total']!,
                      icon: Icons.account_balance_wallet,
                      color: Colors.purple,
                      isTotal: true,
                    ),
                    const SizedBox(height: 20),

                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Income',
                            (summary['transactions'] as Map)['income']
                                as double,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'Expenses',
                            (summary['transactions'] as Map)['expense']
                                as double,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Pending Bills',
                            (summary['bills'] as Map)['pending'] as double,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'Pending Payroll',
                            (summary['payroll'] as Map)['pending'] as double,
                            Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Quick Actions
                    const QuickActions(),
                    const SizedBox(height: 20),

                    // Recent Transactions
                    RecentTransactions(projectId: project.id),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${amount.toStringAsFixed(2)} SDG',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBalanceVerificationDialog(
    BuildContext context,
    String type,
    double startingBalance,
    double currentBalance,
  ) async {
    final difference = currentBalance - startingBalance;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$type Balance Verification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Starting Balance: ${startingBalance.toStringAsFixed(2)} SDG',
              ),
              const SizedBox(height: 8),
              Text('Current Balance: ${currentBalance.toStringAsFixed(2)} SDG'),
              const SizedBox(height: 8),
              Text(
                'Difference: ${difference.toStringAsFixed(2)} SDG',
                style: TextStyle(
                  color: difference >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please verify this against your physical cash or bank statement.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
