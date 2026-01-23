import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../core/database/local_database.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/bookmark_repository.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  final ApiClient apiClient;
  final LocalDatabase localDatabase;

  BookmarkRepositoryImpl({
    required this.apiClient,
    required this.localDatabase,
  });

  @override
  Future<Either<Failure, List<Location>>> getBookmarks() async {
    try {
      final localData = await localDatabase.getBookmarks();
      final bookmarks = localData.map((map) => Location(
        id: map['id'],
        title: map['title'],
        category: map['category'],
        score: map['score'],
        imageUrl: map['imageUrl'],
        isBookmarked: true,
      )).toList();
      return Right(bookmarks);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> addBookmark(Location location) async {
    try {
      // Local first (Optimistic)
      await localDatabase.insertBookmark({
        'id': location.id,
        'title': location.title,
        'category': location.category,
        'score': location.score,
        'imageUrl': location.imageUrl,
      });

      // Remote call in background (simulated or real)
      // For this task, we assume the UI handles optimistic update via Bloc
      try {
        await apiClient.post('/users/bookmarks', data: {'locationId': location.id});
      } on ServerException {
        // In a real app, we might want to flag this for retry
      }

      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> removeBookmark(String id) async {
    try {
      await localDatabase.removeBookmark(id);
      try {
        await apiClient.delete('/users/bookmarks/$id');
      } on ServerException {
        // Handle failure
      }
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> syncWithBackend() async {
    try {
      final response = await apiClient.get('/users/bookmarks');
      if (response.statusCode == 200) {
        // Clear and replace local bookmarks with server data
        // TODO: Implement sophisticated sync (merge)
        final List<dynamic> remoteData = response.data['bookmarks'] ?? [];
        for (var item in remoteData) {
          await localDatabase.insertBookmark({
            'id': item['id'],
            'title': item['title'],
            'category': item['category'],
            'score': item['score'],
            'imageUrl': item['imageUrl'],
          });
        }
        return const Right(true);
      }
      return Left(ServerFailure('Failed to sync'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
