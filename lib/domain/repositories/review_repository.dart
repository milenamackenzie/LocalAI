import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/review.dart';

abstract class ReviewRepository {
  Future<Either<Failure, List<Review>>> getReviews(String locationId);
  Future<Either<Failure, Review>> submitReview(Review review);
  Future<Either<Failure, bool>> hasUserReviewed(String locationId, String userId);
}