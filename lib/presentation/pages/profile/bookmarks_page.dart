import 'package:flutter/material.dart';
import '../../widgets/recommendation_card.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulated data
    final List<Map<String, dynamic>> bookmarks = [
      {'title': 'Innovation Hub', 'category': 'Work', 'score': 0.94},
      {'title': 'Central Park', 'category': 'Nature', 'score': 0.88},
    ];

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Bookmarks'),
        centerTitle: true,
      ),
      body: bookmarks.isEmpty
          ? _buildEmptyState(context)
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final item = bookmarks[index];
                return RecommendationCard(
                  title: item['title'],
                  category: item['category'],
                  score: item['score'],
                  onTap: () {}, // Navigate to details
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'No bookmarks yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          const Text('Items you save will appear here.'),
          const SizedBox(height: 30),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Explore Places'),
          ),
        ],
      ),
    );
  }
}
