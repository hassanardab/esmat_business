//lib/services/pdf_service.dart
import 'dart:io';
import 'package:esmat_business/models/enums.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/project.dart';
import '../models/transaction.dart';
import '../models/bill.dart';
import '../models/payroll.dart';
import '../models/vendor.dart';
import 'storage_service.dart';
import 'balance_calculator.dart';

class PdfService {
  static const _primaryColor = PdfColors.blue800;
  static const _secondaryColor = PdfColors.grey600;
  static const _textColor = PdfColors.black;
  static const _backgroundColor = PdfColors.white;

  static Future<void> generateProjectReport({
    required String projectId,
    required ReportType type,
  }) async {
    final project = StorageService.getProject(projectId);
    if (project == null) return;

    final summary = BalanceCalculator.getProjectFinancialSummary(projectId);
    final transactions = StorageService.getTransactions(projectId: projectId)
      ..sort((a, b) => b.date.compareTo(a.date));
    final bills = StorageService.getBills(projectId: projectId)
      ..sort((a, b) => b.dueDate.compareTo(a.dueDate));
    final payrolls = StorageService.getPayrolls(projectId: projectId)
      ..sort((a, b) => b.date.compareTo(a.date));
    final vendors = StorageService.getVendors();

    final pdf = pw.Document();

    // Add pages based on report type
    pdf.addPage(_buildCoverPage(project, summary));
    pdf.addPage(_buildSummaryPage(project, summary));

    if (type == ReportType.detailed || type == ReportType.summary) {
      pdf.addPage(_buildTransactionsPage(transactions, summary));
    }

    if (type == ReportType.detailed) {
      pdf.addPage(_buildBillsPage(bills));
      pdf.addPage(_buildPayrollPage(payrolls));
    }

    if (type == ReportType.vendorBalance || type == ReportType.detailed) {
      pdf.addPage(_buildVendorBalancesPage(vendors, projectId));
    }

    // Save and share
    final bytes = await pdf.save();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/esmat_report_$projectId.pdf');
    await file.writeAsBytes(bytes);

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Esmat_Report_${project.name}.pdf',
    );
  }

  static pw.Page _buildCoverPage(
    Project project,
    Map<String, dynamic> summary,
  ) {
    final balances = summary['balances'] as Map<String, double>;
    final now = DateTime.now();
    final formattedDate = '${now.day}/${now.month}/${now.year}';

    return pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.SizedBox(height: 40),
            pw.Text(
              'ESMAT FINANCIAL REPORT',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              project.name,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              'Generated on: $formattedDate',
              style: pw.TextStyle(fontSize: 12, color: _secondaryColor),
            ),
            pw.SizedBox(height: 40),
            pw.Divider(color: _primaryColor, thickness: 2),
            pw.SizedBox(height: 20),
            pw.Text(
              'CURRENT BALANCES',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            pw.SizedBox(height: 15),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                _buildBalanceCard('Cash Balance', balances['cash']!),
                _buildBalanceCard('Bank Balance', balances['bank']!),
                _buildBalanceCard('Total Balance', balances['total']!),
              ],
            ),
            pw.SizedBox(height: 30),
            pw.Text(
              'Starting Balances:',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Cash: ${project.startingCashBalance.toStringAsFixed(2)} SDG',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(width: 20),
                pw.Text(
                  'Bank: ${project.startingBankBalance.toStringAsFixed(2)} SDG',
                  style: pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Note: Verify these balances against your physical cash and bank statements',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.red600,
                fontStyle: pw.FontStyle.italic,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  static pw.Widget _buildBalanceCard(String title, double amount) {
    return pw.Container(
      width: 100,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _primaryColor, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: _secondaryColor,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            '${amount.toStringAsFixed(2)} SDG',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: _primaryColor,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  static pw.Page _buildSummaryPage(
    Project project,
    Map<String, dynamic> summary,
  ) {
    final balances = summary['balances'] as Map<String, double>;
    final transactions = summary['transactions'] as Map<String, dynamic>;
    final bills = summary['bills'] as Map<String, dynamic>;
    final payroll = summary['payroll'] as Map<String, dynamic>;

    return pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 1,
              child: pw.Text(
                'FINANCIAL SUMMARY',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ),
            pw.Divider(color: _primaryColor, thickness: 1),
            pw.SizedBox(height: 15),

            // Income & Expenses
            pw.Text(
              'Income & Expenses',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            _buildSummaryRow('Total Income', transactions['income'] as double),
            _buildSummaryRow(
              'Total Expenses',
              transactions['expense'] as double,
            ),
            _buildSummaryRow('Net Income', transactions['net'] as double),
            pw.SizedBox(height: 10),

            // Bills
            pw.Text(
              'Bills',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            _buildSummaryRow('Total Bills', bills['total'] as double),
            _buildSummaryRow('Paid Bills', bills['paid'] as double),
            _buildSummaryRow('Pending Bills', bills['pending'] as double),
            pw.SizedBox(height: 10),

            // Payroll
            pw.Text(
              'Payroll',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            _buildSummaryRow('Total Payroll', payroll['total'] as double),
            _buildSummaryRow('Paid Payroll', payroll['paid'] as double),
            _buildSummaryRow('Pending Payroll', payroll['pending'] as double),
            pw.SizedBox(height: 10),

            // Final Balances
            pw.Divider(color: _primaryColor, thickness: 1),
            pw.SizedBox(height: 10),
            pw.Text(
              'FINAL BALANCES',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            _buildSummaryRow('Cash Balance', balances['cash']!),
            _buildSummaryRow('Bank Balance', balances['bank']!),
            _buildSummaryRow(
              'Total Balance',
              balances['total']!,
              isHighlighted: true,
            ),
          ],
        );
      },
    );
  }

  static pw.Widget _buildSummaryRow(
    String label,
    double value, {
    bool isHighlighted = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: isHighlighted
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,
            ),
          ),
        ),
        pw.Text(
          '${value.toStringAsFixed(2)} SDG',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: isHighlighted
                ? pw.FontWeight.bold
                : pw.FontWeight.normal,
            color: isHighlighted ? _primaryColor : _textColor,
          ),
          textAlign: pw.TextAlign.right,
        ),
      ],
    );
  }

  static pw.Page _buildTransactionsPage(
    List<Transaction> transactions,
    Map<String, dynamic> summary,
  ) {
    return pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 1,
              child: pw.Text(
                'TRANSACTIONS',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ),
            pw.Divider(color: _primaryColor, thickness: 1),
            pw.SizedBox(height: 10),

            // Summary
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Total Transactions: ${transactions.length}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  'Net: ${(summary['transactions'] as Map)['net'].toStringAsFixed(2)} SDG',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),

            // Table
            pw.Table.fromTextArray(
              headers: [
                'Date',
                'Title',
                'Type',
                'Amount',
                'Method',
                'Category',
              ],
              data: transactions.map((t) {
                return [
                  '${t.date.day}/${t.date.month}/${t.date.year}',
                  t.title,
                  t.type == TransactionType.income ? 'Income' : 'Expense',
                  '${t.amount.toStringAsFixed(2)} SDG',
                  t.paymentMethod == PaymentMethod.cash ? 'Cash' : 'Bank',
                  t.category ?? '',
                ];
              }).toList(),
              border: pw.TableBorder.all(color: _secondaryColor),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: _primaryColor,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(5),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey100,
              ),
              oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey50),
            ),
          ],
        );
      },
    );
  }

  static pw.Page _buildBillsPage(List<Bill> bills) {
    return pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 1,
              child: pw.Text(
                'BILLS',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ),
            pw.Divider(color: _primaryColor, thickness: 1),
            pw.SizedBox(height: 10),

            pw.Text(
              'Total Bills: ${bills.length}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 10),

            pw.Table.fromTextArray(
              headers: [
                'Vendor',
                'Title',
                'Amount',
                'Due Date',
                'Status',
                'Paid',
              ],
              data: bills.map((b) {
                final vendor =
                    StorageService.getVendor(b.vendorId)?.name ?? 'Unknown';
                return [
                  vendor,
                  b.title,
                  '${b.amount.toStringAsFixed(2)} SDG',
                  '${b.dueDate.day}/${b.dueDate.month}/${b.dueDate.year}',
                  b.status.toString().split('.').last,
                  b.isPaid ? 'Yes' : 'No',
                ];
              }).toList(),
              border: pw.TableBorder.all(color: _secondaryColor),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: _primaryColor,
              ),
              cellPadding: const pw.EdgeInsets.all(5),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey100,
              ),
              oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey50),
            ),
          ],
        );
      },
    );
  }

  static pw.Page _buildPayrollPage(List<Payroll> payrolls) {
    return pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 1,
              child: pw.Text(
                'PAYROLL',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ),
            pw.Divider(color: _primaryColor, thickness: 1),
            pw.SizedBox(height: 10),

            pw.Text(
              'Total Payroll Entries: ${payrolls.length}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 10),

            pw.Table.fromTextArray(
              headers: ['Employee', 'Amount', 'Date', 'Method', 'Paid'],
              data: payrolls.map((p) {
                return [
                  p.employeeName,
                  '${p.amount.toStringAsFixed(2)} SDG',
                  '${p.date.day}/${p.date.month}/${p.date.year}',
                  p.isCash ? 'Cash' : 'Bank',
                  p.isPaid ? 'Yes' : 'No',
                ];
              }).toList(),
              border: pw.TableBorder.all(color: _secondaryColor),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: _primaryColor,
              ),
              cellPadding: const pw.EdgeInsets.all(5),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey100,
              ),
              oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey50),
            ),
          ],
        );
      },
    );
  }

  static pw.Page _buildVendorBalancesPage(
    List<Vendor> vendors,
    String projectId,
  ) {
    final bills = StorageService.getBills(projectId: projectId);
    final transactions = StorageService.getTransactions(projectId: projectId);

    return pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 1,
              child: pw.Text(
                'VENDOR BALANCES',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ),
            pw.Divider(color: _primaryColor, thickness: 1),
            pw.SizedBox(height: 10),
            pw.Text(
              'This shows how much you owe to or have paid each vendor for this project.',
              style: pw.TextStyle(fontSize: 10, color: _secondaryColor),
            ),
            pw.SizedBox(height: 15),

            pw.Table.fromTextArray(
              headers: [
                'Vendor',
                'Contact',
                'Pending Bills',
                'Paid to Vendor',
                'Current Balance',
              ],
              data: vendors.map((v) {
                final vendorBills = bills.where((b) => b.vendorId == v.id);
                final vendorTransactions = transactions.where(
                  (t) => t.vendorId == v.id && t.isExpense,
                );

                double pendingBills = 0;
                double paidToVendor = 0;

                for (final b in vendorBills) {
                  if (!b.isPaid) pendingBills += b.amount;
                }

                for (final t in vendorTransactions) {
                  paidToVendor += t.amount;
                }

                final balance = pendingBills - paidToVendor;

                return [
                  v.name,
                  v.contact ?? '',
                  '${pendingBills.toStringAsFixed(2)} SDG',
                  '${paidToVendor.toStringAsFixed(2)} SDG',
                  '${balance.toStringAsFixed(2)} SDG',
                ];
              }).toList(),
              border: pw.TableBorder.all(color: _secondaryColor),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: _primaryColor,
              ),
              cellPadding: const pw.EdgeInsets.all(5),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey100,
              ),
              oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey50),
            ),
          ],
        );
      },
    );
  }
}
