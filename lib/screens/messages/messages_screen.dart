import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMessageItem(
                  context,
                  'Ahmed Mohammed',
                  'About the material delivery for Project A',
                  '2 hours ago',
                  isRead: true,
                ),
                _buildMessageItem(
                  context,
                  'Sara Ali',
                  'Payment confirmation for Invoice #1234',
                  '1 day ago',
                  isRead: true,
                ),
                _buildMessageItem(
                  context,
                  'ABC Supplies',
                  'New price list for building materials',
                  '3 days ago',
                  isRead: false,
                ),
                _buildMessageItem(
                  context,
                  'Mohammed Hassan',
                  'Meeting reminder for tomorrow at 10 AM',
                  '1 week ago',
                  isRead: true,
                ),
                _buildMessageItem(
                  context,
                  'Bank of Sudan',
                  'Your account statement for June 2026',
                  '2 weeks ago',
                  isRead: true,
                ),
              ],
            ),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildMessageItem(
    BuildContext context,
    String sender,
    String message,
    String time, {
    bool isRead = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            sender.isNotEmpty ? sender[0] : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          sender,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isRead
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        trailing: isRead
            ? null
            : Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () {
          // Navigate to message detail
        },
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardTheme.color,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(icon: const Icon(Icons.attach_file), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {},
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
