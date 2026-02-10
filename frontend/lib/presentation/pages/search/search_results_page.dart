import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/recommendation_card.dart';
import '../../widgets/filter_drawer.dart';
import '../../blocs/bookmark_bloc.dart';
import 'package:localai_frontend/domain/entities/location.dart';



class SearchResultsPage extends StatefulWidget {
  final String query;

  const SearchResultsPage({super.key, required this.query});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  // Mock search results based on query
  List<Location> _getSearchResults() {
    return [
      const Location(id: '9', title: 'The Innovation Hub', category: 'Coworking Space', score: 0.94, imageUrl: null, isBookmarked: false),
      const Location(id: '10', title: 'Creative Studio', category: 'Arts', score: 0.89, imageUrl: null, isBookmarked: false),
      const Location(id: '11', title: 'Tech Library', category: 'Education', score: 0.91, imageUrl: null, isBookmarked: false),
      const Location(id: '12', title: 'Urban Cafe', category: 'Food & Dining', score: 0.87, imageUrl: null, isBookmarked: false),
    ];
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final results = _getSearchResults();

    return BlocBuilder<BookmarkBloc, BookmarkState>(
      builder: (context, bookmarkState) {
        List<Location> bookmarks = [];
        if (bookmarkState is BookmarksLoaded) {
          bookmarks = bookmarkState.bookmarks;
        }

        bool isBookmarked(String id) => bookmarks.any((b) => b.id == id);

        return Scaffold(
          appBar: AppBar(
            title: Text('Results for "${widget.query}"'),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const FilterDrawer(),
                  );
                },
              ),
            ],
          ),
          body: CustomScrollView(
            key: PageStorageKey<String>('search_results_${widget.query}'),
            slivers: [
              // AI Reasoning Header
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primaryContainer, colorScheme.surface],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'AI Reasoning',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Based on your interest in "${widget.query}", I found these spots that offer a productive atmosphere with high-speed internet and comfortable seating.',
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.1),
              ),

              // Results List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final location = results[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: RecommendationCard(
                          id: location.id,
                          title: location.title,
                          category: location.category,
                          score: location.score,
                          imageUrl: location.imageUrl,
                          isBookmarked: isBookmarked(location.id),
                          onTap: () => context.push('/recommendation/${location.id}'),
                          onBookmarkToggle: () => context.read<BookmarkBloc>().add(ToggleBookmarkRequested(location)),
                        ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.05),
                      );
                    },
                    childCount: results.length,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
