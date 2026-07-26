import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/project_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../models/transaction.dart';
import '../../models/enums.dart';

class AddTransactionScreen extends StatefulWidget {
  final String projectId;
  final TransactionType? defaultType;

  const AddTransactionScreen({
    super.key,
    required this.projectId,
    this.defaultType,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  DateTime _date = DateTime.now();
  String? _selectedVendorId;
  String? _selectedCategory;

  final List<String> _categories = [
    'Materials',
    'Labor',
    'Equipment',
    'Transport',
    'Rent',
    'Utilities',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.defaultType != null) {
      _type = widget.defaultType!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendorProvider = context.watch<VendorProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _type == TransactionType.income ? 'Add Income' : 'Add Expense',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type Toggle
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTypeButton(
                          'Expense',
                          TransactionType.expense,
                          Colors.red,
                        ),
                      ),
                      Expanded(
                        child: _buildTypeButton(
                          'Income',
                          TransactionType.income,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g., Cement Purchase',
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

              // Payment Method
              DropdownButtonFormField<PaymentMethod>(
                value: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: PaymentMethod.values.map((method) {
                  return DropdownMenuItem<PaymentMethod>(
                    value: method,
                    child: Text(
                      method == PaymentMethod.cash ? 'Cash' : 'Bank Transfer',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _paymentMethod = value);
                  }
                },
              ),
              const SizedBox(height: 12),

              // Date
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date: ${DateFormat('dd MMM yyyy').format(_date)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Change'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Category (for expenses)
              if (_type == TransactionType.expense)
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint: const Text('Select Category'),
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value),
                ),
              if (_type == TransactionType.expense) const SizedBox(height: 12),

              // Vendor (optional)
              DropdownButtonFormField<String?>(
                value: _selectedVendorId,
                hint: const Text('Select Vendor (Optional)'),
                decoration: const InputDecoration(labelText: 'Vendor'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('None'),
                  ),
                  ...vendorProvider.vendors.map((vendor) {
                    return DropdownMenuItem<String?>(
                      value: vendor.id,
                      child: Text(vendor.name),
                    );
                  }).toList(),
                ],
                onChanged: (value) => setState(() => _selectedVendorId = value),
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Additional details about this transaction',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Save Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, TransactionType type, Color color) {
    final isSelected = _type == type;
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? color.withOpacity(0.2) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => setState(() => _type = type),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? color : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _date) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final transaction = Transaction(
      projectId: widget.projectId,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text),
      type: _type,
      paymentMethod: _paymentMethod,
      date: _date,
      category: _type == TransactionType.expense ? _selectedCategory : null,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      vendorId: _selectedVendorId,
    );

    await context.read<TransactionProvider>().addTransaction(transaction);
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_type == TransactionType.income ? 'Income' : 'Expense'} added successfully',
          ),
        ),
      );
    }
  }
}
