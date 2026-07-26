import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../services/storage_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();
    final vendorProvider = context.watch<VendorProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Esmat',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Business Owner',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Statistics
            const Text(
              'Your Data',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Projects',
                    projectProvider.projects.length.toString(),
                    Icons.folder,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Vendors',
                    vendorProvider.vendors.length.toString(),
                    Icons.people,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Actions
            const Text(
              'Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.backup, color: Colors.blue),
                    title: const Text('Backup Data'),
                    subtitle: const Text('Export all data to a file'),
                    onTap: () => _showBackupDialog(context),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.restore, color: Colors.orange),
                    title: const Text('Restore Data'),
                    subtitle: const Text('Import data from a backup file'),
                    onTap: () => _showRestoreDialog(context),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
                    title: const Text('Clear All Data'),
                    subtitle: const Text(
                      'Delete all projects and transactions',
                    ),
                    onTap: () => _showClearDataDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Future<void> _showBackupDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Backup Data'),
          content: const Text(
            'This will create a backup of all your data. You can use this file to restore your data later.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement backup functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup feature coming soon!')),
                );
                Navigator.pop(context);
              },
              child: const Text('Backup Now'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRestoreDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Restore Data'),
          content: const Text(
            'Select a backup file to restore your data. This will overwrite all existing data.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement restore functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Restore feature coming soon!')),
                );
                Navigator.pop(context);
              },
              child: const Text('Select File'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showClearDataDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
            'Are you sure you want to delete all projects, transactions, bills, and payroll data? This action cannot be undone.',
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
                await StorageService.clearAll();
                context.read<ProjectProvider>().loadProjects();
                context.read<VendorProvider>().loadVendors();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data has been cleared')),
                  );
                }
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }
}
