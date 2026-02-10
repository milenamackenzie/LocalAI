import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:localai_frontend/core/database/local_database.dart';
import 'package:localai_frontend/injection_container.dart' as di;

class ChatHistoryPage extends StatelessWidget {
  const ChatHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final db = di.sl<LocalDatabase>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation History'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: db.getChatHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No history yet', style: TextStyle(color: Colors.grey[400])),
                ],
              ),
            );
          }

          final history = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = history[index];
              final date = DateTime.parse(item['timestamp']);
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(Icons.auto_awesome, color: colorScheme.primary, size: 20),
                ),
                title: Text(
                  item['query'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy • HH:mm').format(date),
                  style: theme.textTheme.labelSmall,
                ),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {
                  context.push('/search-results', extra: item['query']);
                },
              );
            },
          );
        },
      ),
    );
  }
}
