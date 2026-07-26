import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/bill_provider.dart';
import '../../providers/payroll_provider.dart';
import '../../services/pdf_service.dart';
import '../../models/enums.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportType _selectedReportType = ReportType.summary;

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Select Report Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...ReportType.values.map(
                      (type) => _buildReportTypeTile(type),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: projectProvider.selectedProject == null
                          ? null
                          : () {
                              PdfService.generateProjectReport(
                                projectId: projectProvider.selectedProject!.id,
                                type: _selectedReportType,
                              );
                            },
                      child: const Text('Generate Report'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (projectProvider.selectedProject != null)
              _buildReportPreview(projectProvider.selectedProject!.id),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypeTile(ReportType type) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          type == ReportType.summary
              ? Icons.summarize
              : type == ReportType.detailed
              ? Icons.description
              : Icons.people,
          color: _selectedReportType == type
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
        ),
        title: Text(
          type == ReportType.summary
              ? 'Summary Report'
              : type == ReportType.detailed
              ? 'Detailed Report'
              : 'Vendor Balances',
        ),
        subtitle: Text(
          type == ReportType.summary
              ? 'Basic financial summary with key metrics'
              : type == ReportType.detailed
              ? 'All transactions, bills, and payroll details'
              : 'Vendor-specific balance information',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Radio<ReportType>(
          value: type,
          groupValue: _selectedReportType,
          onChanged: (value) => setState(() => _selectedReportType = value!),
        ),
        onTap: () => setState(() => _selectedReportType = type),
      ),
    );
  }

  Widget _buildReportPreview(String projectId) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Report Preview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'This is a preview of what will be included in your report:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ..._getPreviewContent(_selectedReportType),
          ],
        ),
      ),
    );
  }

  List<Widget> _getPreviewContent(ReportType type) {
    final previews = <Widget>[];

    if (type == ReportType.summary || type == ReportType.detailed) {
      previews.addAll([
        const ListTile(
          leading: Icon(Icons.assessment, color: Colors.blue),
          title: Text('Financial Summary'),
          subtitle: Text('Income, expenses, bills, and payroll overview'),
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.receipt, color: Colors.green),
          title: Text('Current Balances'),
          subtitle: Text('Cash, bank, and total balances'),
        ),
        const Divider(),
      ]);
    }

    if (type == ReportType.detailed) {
      previews.addAll([
        const ListTile(
          leading: Icon(Icons.list, color: Colors.orange),
          title: Text('All Transactions'),
          subtitle: Text('Detailed list of all income and expenses'),
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.description, color: Colors.purple),
          title: Text('Bills'),
          subtitle: Text('All bills with their status'),
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.people, color: Colors.teal),
          title: Text('Payroll'),
          subtitle: Text('All payroll entries'),
        ),
        const Divider(),
      ]);
    }

    if (type == ReportType.vendorBalance || type == ReportType.detailed) {
      previews.add(
        const ListTile(
          leading: Icon(Icons.balance, color: Colors.deepPurple),
          title: Text('Vendor Balances'),
          subtitle: Text('How much you owe to each vendor'),
        ),
      );
    }

    return previews;
  }
}
