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
      final bookmarks = localData.map((map) => Location.fromJson({
        'id': map['id'],
        'title': map['title'],
        'category': map['category'],
        'score': map['score'],
        'imageUrl': map['imageUrl'],
        'isBookmarked': true,
      })).toList();
      return Right(bookmarks);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> addBookmark(Location location) async {
    try {
      // Local first
      await localDatabase.insertBookmark({
        'id': location.id,
        'title': location.title,
        'category': location.category,
        'score': location.score,
        'imageUrl': location.imageUrl,
      });

      // Remote call
      try {
        await apiClient.post('/users/bookmarks', data: {
          'itemId': location.id,
          'itemType': 'location',
          'itemTitle': location.title,
          'itemCategory': location.category,
          'itemScore': location.score,
          'itemImageUrl': location.imageUrl,
        });
        return const Right(true);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
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
        return const Right(true);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> syncWithBackend() async {
    try {
      final response = await apiClient.get('/users/bookmarks');
      if (response.statusCode == 200) {
        final List<dynamic> remoteData = response.data['data'] ?? [];
        
        // Simple sync strategy: Remote is source of truth for now
        // In a more complex app, we'd merge and handle conflicts
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
      return const Left(ServerFailure('Failed to sync'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
