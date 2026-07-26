import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/project_provider.dart';
import '../../providers/payroll_provider.dart';
import '../../models/payroll.dart';
import '../../models/enums.dart';

class AddPayrollScreen extends StatefulWidget {
  final String projectId;

  const AddPayrollScreen({super.key, required this.projectId});

  @override
  State<AddPayrollScreen> createState() => _AddPayrollScreenState();
}

class _AddPayrollScreenState extends State<AddPayrollScreen> {
  final _formKey = GlobalKey<FormState>();
  final _employeeController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  PaymentMethod _paymentMethod = PaymentMethod.cash;
  DateTime _date = DateTime.now();
  bool _isPaid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Payroll')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Employee Name
              TextFormField(
                controller: _employeeController,
                decoration: const InputDecoration(
                  labelText: 'Employee Name',
                  hintText: 'e.g., Ahmed Mohammed',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter employee name';
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

              // Paid Status
              CheckboxListTile(
                title: const Text('Mark as Paid'),
                value: _isPaid,
                onChanged: (value) => setState(() => _isPaid = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Additional details about this payroll',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Save Payroll'),
              ),
            ],
          ),
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

    final payroll = Payroll(
      projectId: widget.projectId,
      employeeName: _employeeController.text.trim(),
      amount: double.parse(_amountController.text),
      date: _date,
      paymentMethod: _paymentMethod,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      isPaid: _isPaid,
    );

    await context.read<PayrollProvider>().addPayroll(payroll);
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payroll added successfully')),
      );
    }
  }
}
