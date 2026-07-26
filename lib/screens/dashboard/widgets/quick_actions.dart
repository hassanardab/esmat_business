//lib/screens/dashboard/widgets/project_selector.dart
import 'package:esmat_business/models/enums.dart';
import 'package:esmat_business/models/vendor.dart';
import 'package:esmat_business/providers/vendor_provider.dart';
import 'package:esmat_business/services/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/project_provider.dart';
import '../../../screens/transactions/add_transaction_screen.dart';
import '../../../screens/bills/add_bill_screen.dart';
import '../../../screens/payroll/add_payroll_screen.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();

    if (projectProvider.selectedProject == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.add,
                label: 'Add\nExpense',
                color: Colors.red,
                onTap: () => _navigateToAddScreen(
                  context,
                  AddTransactionScreen(
                    projectId: projectProvider.selectedProject!.id,
                    defaultType: TransactionType.expense,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.add,
                label: 'Add\nIncome',
                color: Colors.green,
                onTap: () => _navigateToAddScreen(
                  context,
                  AddTransactionScreen(
                    projectId: projectProvider.selectedProject!.id,
                    defaultType: TransactionType.income,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.receipt,
                label: 'Add\nBill',
                color: Colors.orange,
                onTap: () => _navigateToAddScreen(
                  context,
                  AddBillScreen(projectId: projectProvider.selectedProject!.id),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.people,
                label: 'Add\nPayroll',
                color: Colors.purple,
                onTap: () => _navigateToAddScreen(
                  context,
                  AddPayrollScreen(
                    projectId: projectProvider.selectedProject!.id,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.person_add,
                label: 'Add\nVendor',
                color: Colors.teal,
                onTap: () => _showAddVendorDialog(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.print,
                label: 'Generate\nReport',
                color: Colors.blue,
                onTap: () {
                  if (projectProvider.selectedProject != null) {
                    _showReportTypeDialog(
                      context,
                      projectProvider.selectedProject!.id,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAddScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _showAddVendorDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Vendor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Vendor Name',
                    hintText: 'e.g., ABC Supplies',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contactController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                    hintText: 'e.g., +249 123 456789',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email (Optional)',
                    hintText: 'e.g., vendor@example.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address (Optional)',
                    hintText: 'Vendor address',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a vendor name')),
                  );
                  return;
                }

                final vendor = Vendor(
                  name: name,
                  contact: contactController.text.trim().isEmpty
                      ? null
                      : contactController.text.trim(),
                  email: emailController.text.trim().isEmpty
                      ? null
                      : emailController.text.trim(),
                  address: addressController.text.trim().isEmpty
                      ? null
                      : addressController.text.trim(),
                );

                await context.read<VendorProvider>().addVendor(vendor);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Add Vendor'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showReportTypeDialog(
    BuildContext context,
    String projectId,
  ) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Generate Report'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select the type of report you want to generate:'),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.summarize, color: Colors.blue),
                title: Text('Summary Report'),
                subtitle: Text('Basic financial summary'),
              ),
              ListTile(
                leading: Icon(Icons.description, color: Colors.green),
                title: Text('Detailed Report'),
                subtitle: Text('All transactions, bills, and payroll'),
              ),
              ListTile(
                leading: Icon(Icons.people, color: Colors.purple),
                title: Text('Vendor Balances'),
                subtitle: Text('Only vendor balance information'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Default to detailed report
                PdfService.generateProjectReport(
                  projectId: projectId,
                  type: ReportType.detailed,
                );
              },
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );
  }
}
