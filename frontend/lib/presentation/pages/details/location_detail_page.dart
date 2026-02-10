import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/bookmark_bloc.dart';
import '../../blocs/review_bloc.dart';
import '../../blocs/user_hub_bloc.dart';
import '../../widgets/review_modal.dart';

class LocationDetailPage extends StatefulWidget {
  final String id;

  const LocationDetailPage({super.key, required this.id});

  @override
  State<LocationDetailPage> createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends State<LocationDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<UserHubBloc>().add(LoadRecommendationDetailRequested(widget.id));
    context.read<ReviewBloc>().add(LoadReviewsRequested(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<UserHubBloc, UserHubState>(
      builder: (context, hubState) {
        if (hubState is UserHubLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (hubState is UserHubError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(hubState.message),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Go back Home'),
                  ),
                ],
              ),
            ),
          );
        }

        if (hubState is UserHubDetailLoaded) {
          final location = hubState.location;

          return BlocBuilder<BookmarkBloc, BookmarkState>(
            builder: (context, bookmarkState) {
              bool isBookmarked = false;
              if (bookmarkState is BookmarksLoaded) {
                isBookmarked = bookmarkState.bookmarks.any((b) => b.id == location.id);
              }

              return Scaffold(
                body: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 250,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          location.title,
                          style: const TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 4, color: Colors.black)]),
                        ),
                        background: Container(
                          color: colorScheme.primary,
                          child: const Icon(Icons.map, size: 80, color: Colors.white),
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: Colors.white,
                          ),
                          onPressed: () => context.read<BookmarkBloc>().add(ToggleBookmarkRequested(location)),
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Chip(label: Text(location.category)),
                                BlocBuilder<ReviewBloc, ReviewState>(
                                  builder: (context, reviewState) {
                                    if (reviewState is ReviewsLoaded) {
                                      return Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 20),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${reviewState.averageRating.toStringAsFixed(1)} (${reviewState.totalReviews} reviews)',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Match Score',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: location.score,
                              backgroundColor: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                              minHeight: 10,
                            ),
                            Text('${(location.score * 100).toInt()}% match with your interests'),
                            const SizedBox(height: 32),
                            Text(
                              'Description',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'This is a featured location in your city. Explore the local culture and attractions here.',
                              style: TextStyle(fontSize: 16, height: 1.5),
                            ),
                            const SizedBox(height: 32),
                            
                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.directions),
                                    label: const Text('Directions'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, authState) {
                                    if (authState is! Authenticated) return const SizedBox.shrink();
                                    return Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _showReviewModal(context),
                                        icon: const Icon(Icons.rate_review),
                                        label: const Text('Review'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 40),
                            Text(
                              'User Reviews',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            
                            BlocBuilder<ReviewBloc, ReviewState>(
                              builder: (context, state) {
                                if (state is ReviewLoading) {
                                  return const Center(child: CircularProgressIndicator());
                                } else if (state is ReviewsLoaded) {
                                  if (state.reviews.isEmpty) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: Text('No reviews yet. Be the first!'),
                                      ),
                                    );
                                  }
                                  return ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: state.reviews.length,
                                    separatorBuilder: (context, index) => const Divider(),
                                    itemBuilder: (context, index) {
                                      final review = state.reviews[index];
                                      return _buildReviewItem(context, review);
                                    },
                                  );
                                } else if (state is ReviewError) {
                                  return Center(child: Text('Error: ${state.message}'));
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }

        return const Scaffold(body: Center(child: Text('Loading location...')));
      },
    );
  }

  Widget _buildReviewItem(BuildContext context, review) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                child: Text(review.user?.username[0] ?? 'U'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.user?.username ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < review.rating ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      )),
                    ),
                  ],
                ),
              ),
              Text(
                '${DateTime.now().difference(review.createdAt).inDays}d ago',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.comment),
        ],
      ),
    );
  }

  void _showReviewModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ReviewModal(locationId: widget.id),
    );
  }
}
