import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/local_database.dart';
import '../../../injection_container.dart';

class SearchOverlay extends StatefulWidget {
  const SearchOverlay({super.key});

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  final _searchController = TextEditingController();
  final List<String> _trending = [
    'Quiet study spots',
    'Best coffee in CBD',
    'Outdoor gyms',
    'Dog friendly parks',
    'Late night ramen'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    if (query.isNotEmpty) {
      // Save to history
      sl<LocalDatabase>().insertChat(query, 'Simulated AI Response');
      context.push('/search-results', extra: query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Animated Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Hero(
                tag: 'search_bar',
                child: Material(
                  color: Colors.transparent,
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Ask LocalAI anything...',
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.auto_awesome),
                        onPressed: () => _submitSearch(_searchController.text),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: _submitSearch,
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9)),
            ),

            // Trending Suggestions
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Trending Now',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideX(),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _trending.map((item) {
                        return ActionChip(
                          label: Text(item),
                          onPressed: () => _submitSearch(item),
                          backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ).animate().fadeIn(delay: 300.ms).scale();
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('View Chat History'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/chat-history'),
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
