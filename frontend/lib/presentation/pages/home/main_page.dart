import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/bookmark_bloc.dart';
import '../../blocs/user_hub_bloc.dart';
import 'package:localai_frontend/domain/entities/location.dart';
import '../../widgets/recommendation_card.dart';
import '../../widgets/category_scroller.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<UserHubBloc>().add(LoadRecommendationsRequested(authState.user.id));
      context.read<BookmarkBloc>().add(LoadBookmarksRequested());
      context.read<BookmarkBloc>().add(SyncBookmarksRequested());
    }
  }

  Future<void> _handleRefresh() async {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<UserHubBloc, UserHubState>(
      builder: (context, hubState) {
        return BlocBuilder<BookmarkBloc, BookmarkState>(
          builder: (context, bookmarkState) {
            List<Location> bookmarks = [];
            if (bookmarkState is BookmarksLoaded) {
              bookmarks = bookmarkState.bookmarks;
            }

            bool isBookmarked(String id) => bookmarks.any((b) => b.id == id);

            List<Location> recommendations = [];
            if (hubState is UserHubLoaded) {
              recommendations = hubState.recommendations;
            }

            // Filter by category
            final filteredRecommendations = _selectedCategory == 'All'
                ? recommendations
                : recommendations.where((l) => l.category == _selectedCategory).toList();

            return Scaffold(
              body: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: CustomScrollView(
                  key: const PageStorageKey<String>('main_hub_scroll'),
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
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  String name = 'User';
                                  if (state is Authenticated) {
                                    name = state.user.username;
                                  }
                                  return Text(
                                    name,
                                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                  );
                                },
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

                    // AI Search Bar
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

                    // Personalized Section Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Personalized for You', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            if (hubState is UserHubLoading)
                              const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                          ],
                        ),
                      ),
                    ),

                    // Vertical Recommendation Feed
                    if (filteredRecommendations.isEmpty && hubState is! UserHubLoading)
                      const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Text('No recommendations found. Try syncing your preferences!'),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final location = filteredRecommendations[index];
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
                            childCount: filteredRecommendations.length,
                          ),
                        ),
                      ),

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
      },
    );
  }
}
