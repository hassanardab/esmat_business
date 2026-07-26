import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../models/project.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddProjectDialog(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: projectProvider.projects.length,
        itemBuilder: (context, index) {
          final project = projectProvider.projects[index];
          return _buildProjectCard(context, project);
        },
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.folder, color: Colors.blue),
        title: Text(project.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Starting Balance: ${project.totalStartingBalance.toStringAsFixed(2)} SDG',
            ),
            if (project.description.isNotEmpty)
              Text(
                project.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              'Created: ${project.createdAt.day}/${project.createdAt.month}/${project.createdAt.year}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () => _showEditProjectDialog(context, project),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteProjectDialog(context, project.id),
            ),
          ],
        ),
        onTap: () {
          context.read<ProjectProvider>().selectProject(project);
          Navigator.pop(context);
        },
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
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Add Project'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditProjectDialog(
    BuildContext context,
    Project project,
  ) async {
    final nameController = TextEditingController(text: project.name);
    final cashController = TextEditingController(
      text: project.startingCashBalance.toString(),
    );
    final bankController = TextEditingController(
      text: project.startingBankBalance.toString(),
    );
    final descriptionController = TextEditingController(
      text: project.description,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Project'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Project Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cashController,
                  decoration: const InputDecoration(
                    labelText: 'Starting Cash Balance (SDG)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bankController,
                  decoration: const InputDecoration(
                    labelText: 'Starting Bank Balance (SDG)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
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

                final updatedProject = Project(
                  id: project.id,
                  name: name,
                  startingCashBalance:
                      double.tryParse(cashController.text) ?? 0,
                  startingBankBalance:
                      double.tryParse(bankController.text) ?? 0,
                  description: descriptionController.text.trim(),
                  createdAt: project.createdAt,
                );
                await context.read<ProjectProvider>().updateProject(
                  updatedProject,
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Update Project'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteProjectDialog(
    BuildContext context,
    String projectId,
  ) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Project'),
          content: const Text(
            'Are you sure you want to delete this project? All related transactions, bills, and payroll data will also be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await context.read<ProjectProvider>().deleteProject(projectId);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
