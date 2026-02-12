import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/local_database.dart';
import '../../../injection_container.dart';

class ChatHistoryPage extends StatelessWidget {
  const ChatHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final db = sl<LocalDatabase>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarked Searches'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: db.getBookmarkedChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No bookmarked searches yet', style: TextStyle(color: Colors.grey[400])),
                  const SizedBox(height: 8),
                  Text(
                    'Bookmark searches from the history panel',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
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
              
              final isBookmarked = item['bookmarked'] == 1;
              
              return Card(
                elevation: isBookmarked ? 2 : 0,
                color: isBookmarked ? colorScheme.primaryContainer.withOpacity(0.3) : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      isBookmarked ? Icons.bookmark : Icons.auto_awesome,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['query'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isBookmarked)
                        Icon(
                          Icons.bookmark,
                          color: colorScheme.primary,
                          size: 16,
                        ),
                    ],
                  ),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy • HH:mm').format(date),
                    style: theme.textTheme.labelSmall,
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {
                    // Navigate back to main page
                    // The search will be triggered on the main page with the query
                    context.go('/', extra: item['query']);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
