import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/project_provider.dart';
import '../../providers/bill_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../models/bill.dart';
import '../../models/enums.dart';

class AddBillScreen extends StatefulWidget {
  final String projectId;

  const AddBillScreen({super.key, required this.projectId});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedVendorId;
  BillStatus _status = BillStatus.pending;
  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  PaymentMethod? _paymentMethod;

  @override
  Widget build(BuildContext context) {
    final vendorProvider = context.watch<VendorProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Bill')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vendor
              DropdownButtonFormField<String?>(
                value: _selectedVendorId,
                decoration: const InputDecoration(labelText: 'Vendor'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Select Vendor'),
                  ),
                  ...vendorProvider.vendors.map((vendor) {
                    return DropdownMenuItem<String?>(
                      value: vendor.id,
                      child: Text(vendor.name),
                    );
                  }).toList(),
                ],
                onChanged: (value) => setState(() => _selectedVendorId = value),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a vendor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g., Cement Delivery',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (SDG)',
                  hintText: '0.00',
                  prefixText: 'SDG ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Issue Date
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Issue Date: ${DateFormat('dd MMM yyyy').format(_issueDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context, true),
                    child: const Text('Change'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Due Date
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Due Date: ${DateFormat('dd MMM yyyy').format(_dueDate)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: _dueDate.isBefore(DateTime.now())
                            ? Colors.red
                            : null,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context, false),
                    child: const Text('Change'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Status
              DropdownButtonFormField<BillStatus>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: BillStatus.values.map((status) {
                  return DropdownMenuItem<BillStatus>(
                    value: status,
                    child: Text(status.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),
              const SizedBox(height: 12),

              // Payment Method (if paid)
              if (_status == BillStatus.paid)
                DropdownButtonFormField<PaymentMethod?>(
                  value: _paymentMethod,
                  hint: const Text('Select Payment Method'),
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                  ),
                  items: [
                    const DropdownMenuItem<PaymentMethod?>(
                      value: null,
                      child: Text('Not Specified'),
                    ),
                    ...PaymentMethod.values.map((method) {
                      return DropdownMenuItem<PaymentMethod?>(
                        value: method,
                        child: Text(
                          method == PaymentMethod.cash
                              ? 'Cash'
                              : 'Bank Transfer',
                        ),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) => setState(() => _paymentMethod = value),
                ),
              if (_status == BillStatus.paid) const SizedBox(height: 12),

              // Payment Date (if paid)
              if (_status == BillStatus.paid)
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Payment Date',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _selectPaymentDate(context),
                      child: Text(
                        _paymentMethod != null
                            ? DateFormat('dd MMM yyyy').format(_issueDate)
                            : 'Select Date',
                      ),
                    ),
                  ],
                ),
              if (_status == BillStatus.paid) const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Additional details about this bill',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Save Bill'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isIssueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isIssueDate ? _issueDate : _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isIssueDate) {
          _issueDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  Future<void> _selectPaymentDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _issueDate,
      firstDate: _issueDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _issueDate = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVendorId == null) return;

    final bill = Bill(
      projectId: widget.projectId,
      vendorId: _selectedVendorId!,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text),
      status: _status,
      issueDate: _issueDate,
      dueDate: _dueDate,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      paymentMethod: _paymentMethod,
      paymentDate: _status == BillStatus.paid ? _issueDate : null,
    );

    await context.read<BillProvider>().addBill(bill);
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bill added successfully')));
    }
  }
}
