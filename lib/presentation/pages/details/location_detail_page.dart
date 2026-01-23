import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';
import '../../blocs/bookmark_bloc.dart';
import '../../blocs/review_bloc.dart';
import '../../domain/entities/location.dart';
import '../../widgets/review_modal.dart';

class LocationDetailPage extends StatefulWidget {
  final String id;

  const LocationDetailPage({super.key, required this.id});

  @override
  State<LocationDetailPage> createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends State<LocationDetailPage> {
  bool _isLocationValid = true;

  @override
  void initState() {
    super.initState();
    // Validate location ID
    _validateLocationId();
    // Load reviews when page opens (only if valid)
    if (_isLocationValid) {
      context.read<ReviewBloc>().add(LoadReviewsRequested(widget.id));
    }
  }

  void _validateLocationId() {
    // For demo: simulate validation (e.g., check if ID is numeric and within range)
    // In real app, this would be an API call to verify location exists
    final isValid = widget.id.isNotEmpty &&
                   widget.id != '0' &&
                   RegExp(r'^\d+$').hasMatch(widget.id) &&
                   int.tryParse(widget.id) != null &&
                   int.parse(widget.id) > 0 &&
                   int.parse(widget.id) <= 10; // Simulate max ID
    setState(() => _isLocationValid = isValid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // For demo purposes, create location based on id
    // In real app, this would be fetched from repository
    final location = Location(
      id: widget.id,
      title: 'Gourmet Kitchen', // Hardcoded for demo
      category: 'Food & Dining',
      score: 0.98,
      imageUrl: null,
      isBookmarked: false,
    );

    if (!_isLocationValid) {
      // Show 404 page for invalid location IDs
      return Scaffold(
        appBar: AppBar(
          title: const Text('Location Not Found'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'), // Go to home instead of pop
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Location not found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'The location you\'re looking for doesn\'t exist.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<BookmarkBloc>()),
        BlocProvider.value(value: context.read<ReviewBloc>()),
      ],
      child: BlocBuilder<BookmarkBloc, BookmarkState>(
        builder: (context, bookmarkState) {
          bool isBookmarked = false;
          if (bookmarkState is BookmarksLoaded) {
            isBookmarked = bookmarkState.bookmarks.any((b) => b.id == widget.id);
          }

          return Scaffold(
            body: CustomScrollView(
              key: PageStorageKey<String>('location_detail_${widget.id}'),
              slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Gourmet Kitchen',
                style: TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: colorScheme.primaryContainer),
                  const Icon(Icons.restaurant, size: 100, color: Colors.white),
                  // Gradient overlay for text readability
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
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
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {},
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Food & Dining',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      BlocBuilder<ReviewBloc, ReviewState>(
                        builder: (context, reviewState) {
                          double averageRating = 4.8; // Default
                          int totalReviews = 120; // Default

                          if (reviewState is ReviewsLoaded) {
                            averageRating = reviewState.averageRating;
                            totalReviews = reviewState.totalReviews;
                          }

                          return Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '${averageRating.toStringAsFixed(1)} ($totalReviews reviews)',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'About',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Experience the finest local ingredients prepared by world-class chefs. Our kitchen offers a unique blend of traditional and contemporary flavors in a cozy, modern atmosphere.',
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoTile(context, Icons.location_on, '123 Discovery Way, City Center'),
                  _buildInfoTile(context, Icons.access_time, 'Open today: 09:00 - 22:00'),
                  _buildInfoTile(context, Icons.phone, '+1 234 567 890'),
                  const SizedBox(height: 32),
                   // Write Review Button
                   BlocBuilder<AuthBloc, AuthState>(
                     builder: (context, authState) {
                       if (authState is! Authenticated) {
                         return const SizedBox.shrink();
                       }

                       return Padding(
                         padding: const EdgeInsets.only(bottom: 16),
                         child: SizedBox(
                           width: double.infinity,
                           height: 48,
                           child: OutlinedButton.icon(
                             onPressed: () => _showReviewModal(context),
                             icon: const Icon(Icons.rate_review),
                             label: const Text('Write a Review'),
                             style: OutlinedButton.styleFrom(
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(12),
                               ),
                             ),
                           ),
                         ),
                       );
                     },
                   ),
                   SizedBox(
                     width: double.infinity,
                     height: 56,
                     child: FilledButton.icon(
                       onPressed: () {},
                       icon: const Icon(Icons.directions),
                       label: const Text('Get Directions'),
                     ),
                   ),
                  const SizedBox(height: 32),
                   Text(
                     'Reviews',
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
                               child: Text('No reviews yet. Be the first to review!'),
                             ),
                           );
                         }
                         return Column(
                           children: state.reviews.map((review) => _buildReviewItem(context, review)).toList(),
                         );
                       } else if (state is ReviewError) {
                         return Center(
                           child: Column(
                             children: [
                               Text('Error loading reviews: ${state.message}'),
                               ElevatedButton(
                                 onPressed: () => context.read<ReviewBloc>().add(LoadReviewsRequested(widget.id)),
                                 child: const Text('Retry'),
                               ),
        ],
      ),
    );
      },
    );
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
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, review) {
    final String userName = review.user?.username ?? 'Anonymous';
    final String text = review.comment;
    final int rating = review.rating;
    final DateTime createdAt = review.createdAt;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: review.user?.avatarUrl != null
                    ? NetworkImage(review.user!.avatarUrl!)
                    : null,
                child: review.user?.avatarUrl == null ? Text(userName[0]) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: List.generate(5, (index) => Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      )),
                    ),
                  ],
                ),
              ),
              Text(
                _formatTimeAgo(createdAt),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(text),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  void _showReviewModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ReviewModal(locationId: widget.id),
    );
  }
}
