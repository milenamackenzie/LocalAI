import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/bookmark_bloc.dart';
import '../../domain/entities/location.dart';
import '../../widgets/recommendation_card.dart';
import '../../widgets/category_scroller.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _selectedCategory = 'All';
  bool _isRefreshing = false;

  final List<Location> topRatedLocations = [
    Location(id: '1', title: 'Gourmet Kitchen', category: 'Food & Dining', score: 0.98, imageUrl: null, isBookmarked: false),
    Location(id: '2', title: 'Sunny Beach Resort', category: 'Travel & Leisure', score: 0.95, imageUrl: null, isBookmarked: false),
    Location(id: '3', title: 'Mountain Hiking Trail', category: 'Nature', score: 0.92, imageUrl: null, isBookmarked: false),
  ];

  final List<Location> personalizedLocations = [
    Location(id: '4', title: 'Central City Park', category: 'Nature', score: 0.85, imageUrl: null, isBookmarked: false),
    Location(id: '5', title: 'Historic Museum', category: 'Culture', score: 0.88, imageUrl: null, isBookmarked: false),
    Location(id: '6', title: 'Riverside Cafe', category: 'Food & Dining', score: 0.90, imageUrl: null, isBookmarked: false),
    Location(id: '7', title: 'Art Gallery Downtown', category: 'Arts', score: 0.87, imageUrl: null, isBookmarked: false),
    Location(id: '8', title: 'Tech Conference Center', category: 'Education', score: 0.89, imageUrl: null, isBookmarked: false),
  ];

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<BookmarkBloc, BookmarkState>(
      builder: (context, state) {
        List<Location> bookmarks = [];
        if (state is BookmarksLoaded) {
          bookmarks = state.bookmarks;
        }

        bool isBookmarked(String id) => bookmarks.any((b) => b.id == id);

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: _handleRefresh,
        child: CustomScrollView(
          slivers: [
            // App Bar / Header
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: colorScheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back,',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                      Text(
                        'Milena Mackenzie',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: IconButton(
                      icon: Icon(Icons.person_outline, color: colorScheme.primary),
                      onPressed: () => context.push('/profile'),
                    ),
                  ),
                ),
              ],
            ),

            // AI Search Bar (Tap to Search)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Hero(
                  tag: 'search_bar',
                  child: GestureDetector(
                    onTap: () => context.push('/search'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 56,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: colorScheme.primary),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Where do you want to go today?',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.tune, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Category Scroller
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: CategoryScroller(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() => _selectedCategory = category);
                  },
                ),
              ),
            ),

            // Top Rated Section Header
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Top Rated Near You', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => context.push('/top-rated'),
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
            ),

            // Horizontal Top Rated Carousel
            SliverToBoxAdapter(
              child: SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: topRatedLocations.length,
                  itemBuilder: (context, index) {
                    final location = topRatedLocations[index];
                    return SizedBox(
                      width: 300,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: RecommendationCard(
                          id: location.id,
                          title: location.title,
                          category: location.category,
                          score: location.score,
                          imageUrl: location.imageUrl,
                          isBookmarked: isBookmarked(location.id),
                          onTap: () => context.push('/recommendation/${location.id}'),
                          onBookmarkToggle: () => context.read<BookmarkBloc>().add(ToggleBookmarkRequested(location)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Main Feed Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                child: Text('Personalized for You', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ),

            // Vertical Recommendation Feed
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final location = personalizedLocations[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: RecommendationCard(
                        id: location.id,
                        title: location.title,
                        category: location.category,
                        score: location.score,
                        imageUrl: location.imageUrl,
                        isBookmarked: isBookmarked(location.id),
                        onTap: () => context.push('/recommendation/${location.id}'),
                        onBookmarkToggle: () => context.read<BookmarkBloc>().add(ToggleBookmarkRequested(location)),
                      ),
                    );
                  },
                  childCount: personalizedLocations.length,
                ),
              ),
            ),
            
            // Bottom Padding for FAB
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/search'),
            backgroundColor: colorScheme.primary,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Ask AI'),
          ),
        );
      },
    );
  }
}
