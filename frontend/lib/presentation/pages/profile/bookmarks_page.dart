import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/bookmark_bloc.dart';
import '../../widgets/recommendation_card.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookmarkBloc, BookmarkState>(
      listener: (context, state) {
        if (state is BookmarkError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Saved Bookmarks'),
          centerTitle: true,
        ),
        body: BlocBuilder<BookmarkBloc, BookmarkState>(
          builder: (context, state) {
            if (state is BookmarkLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BookmarksLoaded) {
              final bookmarks = state.bookmarks;
              if (bookmarks.isEmpty) {
                return _buildEmptyState(context);
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: bookmarks.length,
                itemBuilder: (context, index) {
                  final location = bookmarks[index];
                  return RecommendationCard(
                    id: location.id,
                    title: location.title,
                    category: location.category,
                    score: location.score,
                    imageUrl: location.imageUrl,
                    isBookmarked: true,
                    onTap: () => context.push('/recommendation/${location.id}'),
                    onBookmarkToggle: () => context.read<BookmarkBloc>().add(ToggleBookmarkRequested(location)),
                  );
                },
              );
            }

            return _buildEmptyState(context);
          },
        ),
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
            onPressed: () => context.pop(),
            child: const Text('Explore Places'),
          ),
        ],
      ),
    );
  }
}
