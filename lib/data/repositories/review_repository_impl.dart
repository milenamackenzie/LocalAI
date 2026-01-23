import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ApiClient apiClient;

  ReviewRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, List<Review>>> getReviews(String locationId) async {
    try {
      final response = await apiClient.get('/locations/$locationId/reviews');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['reviews'] ?? [];
        final reviews = data.map((json) => Review.fromJson(json)).toList();
        return Right(reviews);
      } else {
        return Left(ServerFailure('Failed to load reviews'));
      }
    } on ServerException {
      return Left(ServerFailure('Server error'));
    }
  }

  @override
  Future<Either<Failure, Review>> submitReview(Review review) async {
    try {
      final response = await apiClient.post('/reviews', data: {
        'locationId': review.locationId,
        'rating': review.rating,
        'comment': review.comment,
      });

      if (response.statusCode == 201) {
        final reviewData = response.data['review'];
        final submittedReview = Review.fromJson(reviewData);
        return Right(submittedReview);
      } else {
        return Left(ServerFailure('Failed to submit review'));
      }
    } on ServerException {
      return Left(ServerFailure('Server error'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasUserReviewed(String locationId, String userId) async {
    try {
      final response = await apiClient.get('/locations/$locationId/reviews?userId=$userId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['reviews'] ?? [];
        return Right(data.isNotEmpty);
      } else {
        return Left(ServerFailure('Failed to check review status'));
      }
    } on ServerException {
      return Left(ServerFailure('Server error'));
    }
  }
}