import 'package:esmat_business/providers/bill_provider.dart';
import 'package:esmat_business/providers/payroll_provider.dart';
import 'package:esmat_business/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/project_provider.dart';
import '../../../models/project.dart';

class ProjectSelector extends StatelessWidget {
  const ProjectSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.folder, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButton<Project?>(
                value: projectProvider.selectedProject,
                hint: const Text('Select a Project'),
                isExpanded: true,
                underline: const SizedBox(),
                items: projectProvider.projects.map((project) {
                  return DropdownMenuItem<Project>(
                    value: project,
                    child: Text(project.name),
                  );
                }).toList(),
                onChanged: (project) {
                  projectProvider.selectProject(project);
                  if (project != null) {
                    context.read<TransactionProvider>().loadTransactions(
                      projectId: project.id,
                    );
                    context.read<BillProvider>().loadBills(
                      projectId: project.id,
                    );
                    context.read<PayrollProvider>().loadPayrolls(
                      projectId: project.id,
                    );
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: () => _showAddProjectDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddProjectDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final cashController = TextEditingController(text: '0');
    final bankController = TextEditingController(text: '0');
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Project'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Project Name',
                    hintText: 'e.g., Construction Project',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cashController,
                  decoration: const InputDecoration(
                    labelText: 'Starting Cash Balance (SDG)',
                    hintText: '0.00',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bankController,
                  decoration: const InputDecoration(
                    labelText: 'Starting Bank Balance (SDG)',
                    hintText: '0.00',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Brief description of the project',
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
                    const SnackBar(
                      content: Text('Please enter a project name'),
                    ),
                  );
                  return;
                }

                final project = Project(
                  name: name,
                  startingCashBalance:
                      double.tryParse(cashController.text) ?? 0,
                  startingBankBalance:
                      double.tryParse(bankController.text) ?? 0,
                  description: descriptionController.text.trim(),
                );

                await context.read<ProjectProvider>().addProject(project);
                context.read<ProjectProvider>().selectProject(project);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Add Project'),
            ),
          ],
        );
      },
    );
  }
}
