import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/location.dart';

abstract class BookmarkRepository {
  Future<Either<Failure, List<Location>>> getBookmarks();
  Future<Either<Failure, bool>> addBookmark(Location location);
  Future<Either<Failure, bool>> removeBookmark(String id);
  Future<Either<Failure, bool>> syncWithBackend();
}
